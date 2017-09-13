//
//  MBFormInstructionsLabel.h
//  StratPad
//
//  Created by Julian Wood on 11-10-03.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBLabel.h"

@interface MBFormInstructionsLabel : MBLabel {
@private
    UIColor *strokeColor_;
}

@property(nonatomic, retain) UIColor *strokeColor;

@end
