//
//  StrategicGoalViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 5, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StrategicGoalViewController.h"

@implementation StrategicGoalViewController

-(void) viewDidLoad
{
    self.fieldName = @"mediumTermStrategicGoal";
    [super viewDidLoad];
}

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70574879.m3u8?p=high,standard,mobile&s=aee5667e89218b999c13e37877262794";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F3.mov" ofType:@"mp4"];
    return path;
}


@end
