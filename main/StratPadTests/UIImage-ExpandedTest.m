//
//  MBReportHeaderTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "UIImage-Expanded.h"

@interface MBReportHeaderTest : SenTestCase
@end

@implementation MBReportHeaderTest

- (void)testSizeForImage
{    
    // 61x33
    CGSize size = [[UIImage imageNamed:@"button-grey.png"] sizeForProportionalImageWithMaxDim:90.f];
    STAssertTrue(CGSizeEqualToSize(size, CGSizeMake(61, 33)), @"Oops, got: %@", NSStringFromCGSize(size));

    // 124x145
    size = [[UIImage imageNamed:@"starthere-nav-sidebar.png"] sizeForProportionalImageWithMaxDim:90.f];
    STAssertEqualsWithAccuracy(size.width, 77.0f, 0.1f, @"Oops");
    STAssertEqualsWithAccuracy(size.height, 90.0f, 0.1f, @"Oops");
        
    // 667x488
    size = [[UIImage imageNamed:@"strategy-pyramid.png"] sizeForProportionalImageWithMaxDim:90.f];
    STAssertEqualsWithAccuracy(size.width, 90.0f, 0.1f, @"Oops");
    STAssertEqualsWithAccuracy(size.height, 65.8f, 0.1f, @"Oops");

}

@end
