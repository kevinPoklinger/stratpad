//
//  ObjectiveHeaderTableViewCell.m
//  StratPad
//
//  Created by Eric on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ObjectiveHeaderTableViewCell.h"
#import "SkinManager.h"

@implementation ObjectiveHeaderTableViewCell

@synthesize lblObjectiveDescription = lblObjectiveDescription_;
@synthesize lblMetric = lblMetric_;
@synthesize lblTargetDate = lblTargetDate_;
@synthesize lblTargetValue = lblTargetValue_;
@synthesize lblReviewFrequency = lblReviewFrequency_;

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblObjectiveDescription.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblObjectiveDescription.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblMetric.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblMetric.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblTargetValue.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblTargetValue.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblTargetDate.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblTargetDate.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblTargetValue.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblTargetValue.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblReviewFrequency.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblReviewFrequency.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    [lblObjectiveDescription_ release];
    [lblMetric_ release];
    [lblTargetValue_ release];
    [lblTargetDate_ release];
    [lblReviewFrequency_ release];
    
    [super dealloc];
}

@end
