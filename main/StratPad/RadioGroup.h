//
//  MBRadioGroup.h
//  Experimental
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Mobilesce Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBRadioLabel;

@protocol MBRadioGroup <NSObject>

// this is the current selected radioLabel, not necessarily the one which was tapped
// can also be nil
-(void)updateGrouping:(MBRadioLabel*)radioLabel;

@end
