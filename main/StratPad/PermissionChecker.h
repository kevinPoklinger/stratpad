//
//  PermissionChecker.h
//  StratPad
//
//  Created by Julian Wood on 2013-06-13.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StratFile.h"

@interface PermissionChecker : NSObject

- (id)initWithStratFile:(StratFile*)stratFile;
-(BOOL)isReadWrite;
- (BOOL)checkReadWrite;

@end
