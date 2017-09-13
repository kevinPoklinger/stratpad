//
//  DefineObjectivesHeaderView.m
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DefineObjectivesHeaderView.h"
#import "SkinManager.h"

@implementation DefineObjectivesHeaderView

@synthesize lblObjectiveType = lblObjectiveType_;
@synthesize lblInstructions = lblInstructions;

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    self.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblObjectiveType.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellExtraLargeFontSize];
    self.lblObjectiveType.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];
    
    self.lblInstructions.font = [skinMan fontWithName:kSkinSection2TableCellBoldFontName andSize:kSkinSection2TableCellSmallFontSize];
    self.lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor];    
}


- (void)dealloc
{
    [lblObjectiveType_ release];
    [lblInstructions_ release];
    [super dealloc];
}

@end
