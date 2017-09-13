//
//  YammerComment.m
//  StratPad
//
//  Created by Julian Wood on 12-09-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerComment.h"
#import "NSDate-StratPad.h"

#define YammerDateFormat @"yyyy/MM/dd HH:mm:ss Z"

@implementation NSDate (YammerComment)
+(NSDate*)dateTimeFromYammer:(NSString *)str
{
    // 2012/09/24 07:06:16 +0000
    static NSDateFormatter* sDateFormatYammer = nil;
    
    if (!sDateFormatYammer) {
        sDateFormatYammer = [[NSDateFormatter alloc] init];
        [sDateFormatYammer setTimeStyle:NSDateFormatterFullStyle];
        [sDateFormatYammer setDateFormat:YammerDateFormat];
        // tz is in the str
    }
    
    // remove any extraneous Z's
    if ([str hasSuffix:@"Z"]) {
        str = [str substringToIndex:(str.length-1)];
    }
    
    return [sDateFormatYammer dateFromString:str];
}

-(NSString*)stringForYammerDateTime
{
    static NSDateFormatter* sISO8601Formatter = nil;
    
    if (!sISO8601Formatter) {
        sISO8601Formatter = [[NSDateFormatter alloc] init];
        [sISO8601Formatter setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601Formatter setDateFormat:YammerDateFormat];
        // yammer likes UTC - stay consistent
        [sISO8601Formatter setTimeZone:[NSTimeZone utcTimeZone]];
    }
    return[sISO8601Formatter stringFromDate:self];
}
@end

@implementation YammerComment

@synthesize sender, group, network, threadId, commentId, text, creationDate, isUnread;

- (NSString*)description
{
    return [NSString stringWithFormat: @"[networkName: %@, groupName:%@, sender: %@, threadId: %u, commentId: %u, text: %@, creationDate: %@, isUnread: %i]",
            self.network.name, self.group.groupName, self.sender.fullname, self.threadId, self.commentId, self.text, self.creationDate, self.isUnread];
}

-(NSDictionary*)dictionaryForPrefs
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.commentId], @"id",
            [self.creationDate stringForYammerDateTime], @"date",
            nil];
}

+(YammerComment*)commentFromPrefs:(NSDictionary*)yammerCommentDict
{
    YammerComment *comment = [[YammerComment alloc] init];
    comment.commentId = [[yammerCommentDict objectForKey:@"id"] unsignedIntegerValue];
    comment.creationDate = [NSDate dateTimeFromYammer:[yammerCommentDict objectForKey:@"date"]];
    return [comment autorelease];
}

+(YammerComment*)commentFromDict:(NSDictionary*)yammerCommentDict
{
    YammerComment *comment = [[YammerComment alloc] init];
    comment.commentId = [[yammerCommentDict objectForKey:@"id"] unsignedIntegerValue];
    comment.threadId = [[yammerCommentDict objectForKey:@"thread_id"] unsignedIntegerValue];
    comment.creationDate = [NSDate dateTimeFromYammer:[yammerCommentDict objectForKey:@"created_at"]];
    comment.text = [[yammerCommentDict objectForKey:@"body"] objectForKey:@"plain"];
    return [comment autorelease];
}


#pragma mark - Override

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToYammerComment:object];
}

- (BOOL)isEqualToYammerComment:(YammerComment *)comment
{
    if (self == comment)
        return YES;
    if (self.commentId != comment.commentId)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    int hash = 7;
    hash = 31 * hash + commentId;
    return hash;
}



@end
