//
//  ChartViewTest.m
//  StratPad
//
//  Created by Julian Wood on 12-03-16
//  Copyright 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestSupport.h"
#import "CoreDataTestCase.h"
#import "ChartView.h"
#import "DataManager.h"

#import "LinearRegression.h"
#import "Measurement.h"
#import "Metric.h"
#import "NSDate-StratPad.h"

@interface ChartViewTest : CoreDataTestCase {    
}
@end

@implementation ChartViewTest

-(void)testAbbreviationForComment
{
    NSString *abbrev = [ChartView abbreviationForComment:0];
    STAssertEqualObjects(abbrev, @"A", @"Oops");

    abbrev = [ChartView abbreviationForComment:8];
    STAssertEqualObjects(abbrev, @"I", @"Oops");

    abbrev = [ChartView abbreviationForComment:25];
    STAssertEqualObjects(abbrev, @"Z", @"Oops");
    
    abbrev = [ChartView abbreviationForComment:26];
    STAssertEqualObjects(abbrev, @"AA", @"Oops");

    abbrev = [ChartView abbreviationForComment:30];
    STAssertEqualObjects(abbrev, @"EE", @"Oops");
    
}

-(void)testGetPointsForGradient
{
    // need slope and y-intercept in grid coords, gridrect, dy 
    
    // some measurements - remember TLO - these are screen coords
    NSArray *pts = [NSArray arrayWithObjects:
                    [NSValue valueWithCGPoint:CGPointMake(50, 450)], 
                    [NSValue valueWithCGPoint:CGPointMake(100, 420)], 
                    [NSValue valueWithCGPoint:CGPointMake(150, 400)], 
                    [NSValue valueWithCGPoint:CGPointMake(200, 410)], 
                    [NSValue valueWithCGPoint:CGPointMake(250, 380)], 
                    [NSValue valueWithCGPoint:CGPointMake(300, 390)], 
                    [NSValue valueWithCGPoint:CGPointMake(350, 350)], 
                    [NSValue valueWithCGPoint:CGPointMake(400, 370)], 
                    nil];
    CGFloat xMax = 400;
    CGFloat xMin = 50;
    CGFloat gh = 500;
    
    // best fit
    CGFloat sumxy=0, sumx=0, sumy=0, sumx2=0, n=8;
    for (int i=0; i<n; ++i) {
                
        CGFloat x = [[pts objectAtIndex:i] CGPointValue].x;
        CGFloat y = [[pts objectAtIndex:i] CGPointValue].y;
        
        sumxy += x*y;
        sumx += x;
        sumy += y;
        sumx2 += x*x;
    }
    
    // y = mx + b; line l1
    CGFloat slope = (n*sumxy - sumx*sumy)/(n*sumx2 - sumx*sumx);
    CGFloat yintercept = (sumy - slope*sumx)/n;

    // now calculate dY
    CGFloat dY = 0;
    for (int i=0; i<n; ++i) {
        CGFloat x = [[pts objectAtIndex:i] CGPointValue].x;
        CGFloat y = [[pts objectAtIndex:i] CGPointValue].y;
        CGFloat ylr = slope*x + yintercept;
        dY = MAX(dY, ylr-y);
    }
    
    // re-calculate yintercept to describe new line l2, given dY (remember TLO)
    yintercept -= dY;
    
    // p1 is the half way point on l2
    CGFloat x1 = xMin+(xMax-xMin)/2;
    CGPoint p1 = CGPointMake(x1, slope*x1+yintercept);
    
    // now we want a yintercept to describe l3, which is a line that includes p3 (xMax,gh) and the same slope; y=mx+b, b=y-mx
    CGFloat yintercept3 = gh-slope*xMax;
    
    // now we want to figure out the point p2 along l3 which bisects l2 at p1, at right angles
    
    // p4 is directly below p1 on l3
    CGPoint p4 = CGPointMake(p1.x, slope*p1.x+yintercept3);
    
    // sides of the triangle defined by p1, p2 and p4
    CGFloat c = p4.y - p1.y;
    
    // compute angle of all lines l1, l2, l3
    CGFloat theta = atanf(p1.y/p1.x);
    
    // use this to figure out P2
    CGFloat a = c * sinf(theta);

    CGFloat p4xoffset = a * cosf(theta);
    CGFloat p4yoffset = a * sinf(theta);
    
    CGPoint p2 = CGPointOffset(p4, p4xoffset, p4yoffset);
    
    DLog(@"p1: %@", NSStringFromCGPoint(p1));
    DLog(@"p2: %@", NSStringFromCGPoint(p2));
    
    STAssertEqualsWithAccuracy(p1.x, 225.f, 0.1f, @"Oops");
    STAssertEqualsWithAccuracy(p1.y, 378.9f, 0.1f, @"Oops");
    STAssertEqualsWithAccuracy(p2.x, 295.9f, 0.1f, @"Oops");
    STAssertEqualsWithAccuracy(p2.y, 659.8f, 0.1f, @"Oops");
    
    [DataManager rollback];
}

@end
