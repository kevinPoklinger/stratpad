//
//  PdfService.h
//  StratPad
//
//  Created by Julian Wood on 2013-07-02.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteReport.h"

@interface PdfService : NSObject

// this will initiate a fetch of json from our reports server, create the html from that json, then send that html for conversion to pdf
// action will be invoked on target with the path to the pdf
// error will be non-nil if anything goes wrong (you should pass in a pointer assigned to nil)
// nil is always returned
-(id)fetchFinancialReportAsPDF:(id<RemoteReport>)remoteReport target:(id)target action:(SEL)action error:(NSError**)error;

@end
