//
//  Chapter.m
//  StratPad
//
//  Created by Eric Rogers on July 28, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Chapter.h"
#import "Page.h"
#import "HTMLPage.h"
#import "FormPage.h"
#import "ReportPage.h"
#import "EditionManager.h"
#import "AdPage.h"
#import "AdManager.h"

@implementation Chapter

- (void) dealloc
{
    [_pages release];
    [_chapterNumber release];
    [_title release];
    [super dealloc];
}

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.title = LocalizedString([dict objectForKey:@"TitleKey"], nil);
        self.chapterNumber = [dict objectForKey:@"ChapterNumber"];
        
        // load up pages for this chapter, inserting ads if necessary
        NSMutableArray *pageDicts = [[dict objectForKey:@"Pages"] mutableCopy];
        [[AdManager sharedManager] insertAdsIntoPageDictionaries:pageDicts forChapter:self];
        self.pages = [NSMutableArray arrayWithCapacity:[pageDicts count]];
        
        // create appropriate type of page, for all pages in this chapter
        for (NSDictionary *pageDict in pageDicts) {
            
            NSString *pageType = [pageDict objectForKey:@"Type"];
            
            if ([pageType isEqualToString:@"HTML"]) {
                Page *page = [[HTMLPage alloc] initWithDictionary:pageDict];
                [self.pages addObject:page];
                [page release];
                
            } else if ([pageType isEqualToString:@"Ad"]) {
                Page *page = [[AdPage alloc] initWithDictionary:pageDict];
                [self.pages addObject:page];
                [page release];
                
            } else if ([pageType isEqualToString:@"Form"]) {
                Page *page = [[FormPage alloc] initWithDictionary:pageDict];
                [self.pages addObject:page];
                [page release];
                
            } else if ([pageType isEqualToString:@"Report"]) {
                Page *page = [[ReportPage alloc] initWithDictionary:pageDict];
                [self.pages addObject:page];
                [page release];
                
            }
        
        }
        [pageDicts release];
    }
    return self;
}

-(BOOL) isPrintable
{
    if (self.chapterIndex == ChapterIndexFinancialStatementDetail) {
        return NO;
    }
    else {
        for (Page *page in self.pages) {
            if ([page isKindOfClass:[ReportPage class]]) {
                return YES;
            }
        }
        return NO;
    }
}

- (BOOL) isReport
{
    return [self isPrintable];
}

- (NSString*)description
{
    return [NSString stringWithFormat:
            @"{title: %@, chapterNumber: %@}",
            _title, _chapterNumber];
}

@end
