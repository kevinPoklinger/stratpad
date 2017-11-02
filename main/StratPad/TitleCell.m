//
//  TitleCell.m
//  StratPad
//
//  Created by Kevin on 8/9/17.
//  Copyright © 2017 Glassey Strategy. All rights reserved.
//

#import "TitleCell.h"

@implementation TitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc {
    [_titleText release];
    [super dealloc];
}
@end
