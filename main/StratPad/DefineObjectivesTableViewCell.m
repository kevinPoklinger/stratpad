//
//  DefineObjectivesTableViewCell.m
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DefineObjectivesTableViewCell.h"
#import "SkinManager.h"

@implementation DefineObjectivesTableViewCell

@synthesize lblDescription = lblDescription_;
@synthesize lblMetric = lblMetric_;
@synthesize lblTargetValue = lblTargetValue_;
@synthesize lblTargetDate = lblTargetDate_;
@synthesize lblFrequency = lblFrequency_;

- (void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
    
    self.lblDescription.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblDescription.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblMetric.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblMetric.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblTargetValue.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblTargetValue.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblTargetDate.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblTargetDate.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];

    self.lblFrequency.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblFrequency.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    if (animated) {
        NSTimeInterval duration = selected ? 0.5 : 0.2;
        [UIView animateWithDuration:duration animations:^{
            if (selected) {
                self.roundedView.backgroundColor = [[skinMan colorForProperty:kSkinTableCellHighlightColor] colorWithAlphaComponent:0.5];
            } else {
                self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
            }        
        }];        
    } else {
        if (selected) {
            self.roundedView.backgroundColor = [[skinMan colorForProperty:kSkinTableCellHighlightColor] colorWithAlphaComponent:0.5];
        } else {
            self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
        }                
    }
}

- (void)dealloc
{
    [lblDescription_ release];
    [lblMetric_ release];
    [lblTargetValue_ release];
    [lblTargetDate_ release];
    [lblFrequency_ release];
    
    [super dealloc];
}

@end
