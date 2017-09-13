//
//  AddObjectiveTableViewCell.m
//  StratPad
//
//  Created by Eric on 11-08-17.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AddObjectiveTableViewCell.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"

@implementation AddObjectiveTableViewCell

@synthesize lblAddObjective = lblAddObjective_;

- (void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
    self.lblAddObjective.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblAddObjective.textColor = [skinMan colorForProperty:kSkinSection2PlaceHolderFontColor];
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
    [lblAddObjective_ release];
    [super dealloc];
}

@end
