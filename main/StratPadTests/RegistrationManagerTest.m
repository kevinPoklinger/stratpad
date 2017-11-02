//
//  RegistrationManagerTest.m
//  StratPad
//
//  Created by Julian Wood on 2013-02-05.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RegistrationManager.h"

@interface RegistrationManagerTest : SenTestCase

@end


@implementation RegistrationManagerTest

-(void)testRegKey
{
    RegistrationManager *regMan = [RegistrationManager sharedManager];
    NSString *regKey = [regMan performSelector:@selector(regKey:) withObject:@"julian@mobilesce.com"];
    STAssertEqualObjects(regKey, @"e511fd2cee77e6a7edbf1561c67831ec", @"Oops");
}

@end
