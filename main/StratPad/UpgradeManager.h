//
//  UpgradeManager.h
//  StratPad
//
//  Created by Julian Wood on 12-01-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
// changes needing to be made to get from one version to another

#import <Foundation/Foundation.h>

@interface UpgradeManager : NSObject


+(void)upgradeToPlus;

+(void)upgradeToPremium;

+(void)upgradeToStratBoard;

+(void)addOneReadWriteFile;

+(void)upgradeToPlusWithStratBoard;

@end
