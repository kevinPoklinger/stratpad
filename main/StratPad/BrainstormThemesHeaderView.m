//
//  BrainstormThemesHeaderView.m
//  StratPad
//
//  Created by Eric on 11-11-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "BrainstormThemesHeaderView.h"
#import "SkinManager.h"

@implementation BrainstormThemesHeaderView 

@synthesize lblTheme = lblTheme_;
@synthesize lblMandatory = lblMandatory_;
@synthesize lblEnhanceCustomerValue = lblEnhanceCustomerValue_;
@synthesize lblEnhanceUniqueness = lblEnhanceUniqueness_;

- (void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblTheme.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblTheme.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblMandatory.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblMandatory.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblEnhanceCustomerValue.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblEnhanceCustomerValue.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblEnhanceUniqueness.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellMediumFontSize];
    self.lblEnhanceUniqueness.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
}



-(void)dealloc 
{
    [lblTheme_ release];
    [lblMandatory_ release];
    [lblEnhanceCustomerValue_ release];
    [lblEnhanceUniqueness_ release];
    [super dealloc];
}

@end
