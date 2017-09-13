//
//  SideBarButton.h
//  StratPad
//
//  Created by Julian Wood on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface SideBarButton : UIButton
{
@private
    UILabel *chapterNumberLabel_;
    UIImageView *arrowView_;
    NSInteger chapterIndex_;
    NSString *section_;
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString*)title 
 chapterNumberLabel:(UILabel*)chapterNumberLabel 
       chapterIndex:(NSUInteger)chapterIndex 
            section:(NSString*)section;

// show/hide a little badge with a number in the top right corner of the button (representing unread comments on yammer)
-(void)showBadge:(NSUInteger)value;
-(NSUInteger)badgeValue;

// show/hide a little triangle in the top left corner of the button
-(void)showYammerPublicationStatus:(BOOL)isPublished;

@property (nonatomic,retain) UILabel *chapterNumberLabel;
@property (nonatomic,assign) NSInteger chapterIndex;
@property (nonatomic,retain) NSString *section;

@end
