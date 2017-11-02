//
//  ReportHelper.h
//  StratPad
//
//  Created by Julian Wood on 12-04-09.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Use this class instead of extending AbstractReportDelegate to help with implementing Report

#import <Foundation/Foundation.h>
#import "Report.h"

@interface ReportHelper : NSObject<Report> {
    // standard insets for page layout on screen
    UIEdgeInsets screenInsets_;
    
    // standard insets for page layout in print, across reports
    UIEdgeInsets printInsets_;        
}

@property (nonatomic,assign) UIEdgeInsets screenInsets;
@property (nonatomic,assign) UIEdgeInsets printInsets;

@end
