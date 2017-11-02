//
//  CSVFileWriter.h
//  StratPad
//
//  Created by Julian Wood on 12-02-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Builds 2d arrays representing rows of a csv file, and then saves them to file using NSArray+CHCSVAdditions

#import <Foundation/Foundation.h>
#import "Theme.h"
#import "StratFile.h"

@interface CSVFileWriter : NSObject

- (BOOL)exportConsolidatedReportToCsvAtPath:(NSString*)path stratFile:(StratFile*)stratFile;
- (BOOL)exportThemeToCsvAtPath:(NSString*)path theme:(Theme*)theme;

@end

@interface CSVFileWriter (Experimental)

-(void)exportIncomeStatementToCsvAtPath:(NSString*)path json:(NSDictionary*)json;

@end
