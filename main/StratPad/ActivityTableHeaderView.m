//
//  ActivityTableHeaderView.m
//  StratPad
//
//  Created by Eric on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityTableHeaderView.h"
#import "SkinManager.h"

@implementation ActivityTableHeaderView

@synthesize lblAction = lblAction_;
@synthesize lblResponsible = lblResponsible_;
@synthesize lblUpfrontCost = lblUpfrontCost_;
@synthesize lblOngoingCost = lblOngoingCost_;

- (void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblAction.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblAction.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblResponsible.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblResponsible.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblOngoingCost.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblOngoingCost.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblUpfrontCost.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblUpfrontCost.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
}

- (void)dealloc
{
    [lblAction_ release];
    [lblResponsible_ release];
    [lblUpfrontCost_ release];
    [lblOngoingCost_ release];
    
    [super dealloc];
}

@end
