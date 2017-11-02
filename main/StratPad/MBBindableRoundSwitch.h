//
//  MBBindableRoundSwitch.h
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DCRoundSwitch.h"

@interface MBBindableRoundSwitch : DCRoundSwitch {
    NSString *binding_;
}

@property (nonatomic, retain) NSString *binding;

-(void)sizeToFit;

@end
