//
//  AllowingUsToProgressDataSource.h
//  StratPad
//
//  Created by Eric Rogers on September 25, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Stores the date of each quarter, and financial calculations for each.

#import "StratFile.h"
#import "ChartDataSource.h"

@interface AllowingUsToProgressDataSource : ChartDataSource {
@private
    // stores dates corresponding to the beginning of each quarter for a total of 24 months.
    NSArray *columnDates_;
        
    NSMutableArray *revenueValues_;
    NSMutableArray *cogsValues_;
    NSMutableArray *grossMarginValues_;
    
    NSMutableArray *radValues_;
    NSMutableArray *gaaValues_;
    NSMutableArray *samValues_;
    NSMutableArray *totalExpenseValues_;
    
    NSMutableArray *contributionValues_;
    NSMutableArray *cumulativeContributionValues_;
    
    NSUInteger interval_;
    
    BOOL significantDigitsTruncated_;    
}

@property(nonatomic, retain) NSArray *columnDates;
@property(nonatomic, retain) NSArray *orderedFinancialHeadings;

@property(nonatomic, retain) NSArray *revenueValues;
@property(nonatomic, retain) NSArray *cogsValues;
@property(nonatomic, retain) NSArray *grossMarginValues;

@property(nonatomic, retain) NSArray *radValues;
@property(nonatomic, retain) NSArray *gaaValues;
@property(nonatomic, retain) NSArray *samValues;
@property(nonatomic, retain) NSArray *totalExpenseValues;

@property(nonatomic, retain) NSArray *contributionValues;
@property(nonatomic, retain) NSArray *cumulativeContributionValues;

@property(nonatomic, readonly) BOOL significantDigitsTruncated;

- (id)initWithStratFile:(StratFile*)stratFile;

// convenience method to return the array of financial values corresponding to the given heading
- (NSArray*)financialValuesForHeading:(NSString*)financialHeading;

@end