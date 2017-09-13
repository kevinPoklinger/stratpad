//
//  RemoteReport.h
//  StratPad
//
//  Created by Julian Wood on 2013-05-11.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RemoteReport <NSObject>
@required

// the js method which will create the html content in its parent, given some json
-(NSString*)jsMethodNameToLoadTable;

// the path part of the URL (endPoint)
-(NSString*)reportUrlPath;

// eg Income Statement
-(NSString*)reportName;

// qualified name. eg Summary Financials - Income Statement
-(NSString*)fullReportName;

// the dictionary to use for localizing keys in the json
-(NSDictionary*)localizedStringsAndKeys;

@end
