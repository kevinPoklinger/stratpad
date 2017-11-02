//
//  TestSupport.h
//  StratPad
//
//  Created by Eric on 11-09-22.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFile.h"
#import "Theme.h"
#import "Objective.h"

@interface TestSupport : NSObject {
    
}

// creates a StratFile with its required fields populated.
+ (StratFile*)createEmptyStratFile;

// big one fairly filled out
+(StratFile*)createTestStratFile;

+ (Theme*)createTheme1;
+ (Theme*)createTheme2;
+ (Theme*)createTheme3;
+ (Theme*)createThemeWithTitle:(NSString*)title andFinancialWidth:(NSUInteger)width andOrder:(NSUInteger)order;

// date with zeroed time, using the format:  2011-12-01 ie. yyyy-mm-dd
+ (NSDate*)dateFromString:(NSString*)dateString;

@end


@interface NSDate (TestSupport)
- (NSString*)utcFormattedDateTime;
- (NSString*)localFormattedDateTime;
- (NSString*)localFormattedDate;
@end
