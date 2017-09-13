//
//  MBReportView.h
//  StratPad
//
//  Created by Julian Wood on 11-09-30.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"

typedef enum {
    PageOrientationLandscape,
    PageOrientationPortrait
} PageOrientation;


@interface MBReportView : UIView {
@protected            
    id<ScreenReportDelegate> screenDelegate_;
    id<PrintReportDelegate> printDelegate_;
}

@property(nonatomic, retain) id<ScreenReportDelegate> screenDelegate;
@property(nonatomic, retain) id<PrintReportDelegate> printDelegate;

// parallels drawRect for onscreen presentation, called by a VC when printing
- (void)drawPDFPagesWithOrientation:(PageOrientation)orientation;

@end
