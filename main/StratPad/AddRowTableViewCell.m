//
//  AddThemeTableViewCell.m
//  StratPad
//
//  Created by Julian Wood on 11-08-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AddRowTableViewCell.h"
#import "SkinManager.h"

@implementation AddRowTableViewCell

@synthesize lblAddRow = lblAddRow_;

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

-(void)dealloc
{
    [lblAddRow_ release];
    [super dealloc];
}

@end
