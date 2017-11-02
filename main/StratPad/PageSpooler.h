//
//  PageSpooler.h
//  StratPad
//
//  Created by Eric on 11-10-19.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  Provides the basis for page numbering for printed reports.

@interface PageSpooler : NSObject {
@private
    NSUInteger cumulativePageNumber_;
}

+ (PageSpooler*)sharedManager;

// resets the cumulative page number to 1.
- (void)resetCumulativePageNumber;

// returns the cumulative page number. Each call to this method will cause it 
// to be incremented as well.
- (NSUInteger)cumulativePageNumberForReport;

@end
