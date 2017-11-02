//
//  ActivityTableViewCell.m
//  StratPad
//
//  Created by Eric on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import "SkinManager.h"

@implementation ActivityTableViewCell

@synthesize lblAction = lblAction_;
@synthesize lblResponsible = lblResponsible_;
@synthesize lblDateRange = lblDateRange_;
@synthesize lblUpfrontCost = lblUpfrontCost_;
@synthesize lblOngoingCost = lblOngoingCost_;

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    
    self.lblAction.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblAction.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];

    self.lblResponsible.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblResponsible.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblOngoingCost.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblOngoingCost.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblUpfrontCost.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblUpfrontCost.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblDateRange.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellSmallFontSize forMediaType:MediaTypeScreen];
    self.lblDateRange.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
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
                self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
            }        
        }];        
    } else {
        if (selected) {
            self.roundedView.backgroundColor = [[skinMan colorForProperty:kSkinTableCellHighlightColor] colorWithAlphaComponent:0.5];
        } else {
            self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
        }                
    }
}

- (void)dealloc
{
    [lblAction_ release];
    [lblResponsible_ release];
    [lblDateRange_ release];
    [lblUpfrontCost_ release];
    [lblOngoingCost_ release];
    
    [super dealloc];
}

@end
