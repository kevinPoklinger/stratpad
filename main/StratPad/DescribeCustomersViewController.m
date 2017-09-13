//
//  DescribeCustomersViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 5, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DescribeCustomersViewController.h"

@implementation DescribeCustomersViewController

-(void) viewDidLoad
{
    self.fieldName = @"customersDescription";
    [super viewDidLoad];
}

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70574878.m3u8?p=high,standard,mobile&s=631fe9919d9bd28bb7c9ac4ceb876605";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F2.mov" ofType:@"mp4"];
    return path;
}

@end
