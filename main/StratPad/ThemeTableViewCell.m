//
//  ThemeTableViewCell.m
//  StratPad
//
//  Created by Eric on 11-08-05.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeTableViewCell.h"
#import "SkinManager.h"

@implementation ThemeTableViewCell

@synthesize lblTitle = lblTitle_;
@synthesize lblMandatory = lblMandatory_;
@synthesize lblEnhanceUniqueness = lblEnhanceUniqueness_;
@synthesize lblEnhanceCustomerValue = lblEnhanceCustomerValue_;

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    
    self.lblTitle.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblMandatory.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblMandatory.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblEnhanceUniqueness.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblEnhanceUniqueness.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];
    
    self.lblEnhanceCustomerValue.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen];
    self.lblEnhanceCustomerValue.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];    
}


- (void)dealloc
{
    [lblTitle_ release];
    [lblMandatory_ release];
    [lblEnhanceUniqueness_ release];
    [lblEnhanceCustomerValue_ release];
    
    [super dealloc];
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


@end
