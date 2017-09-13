//
//  MeetingAgendaViewController.h
//  StratPad
//
//  Created by Julian Wood on 9/15/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPDFView.h"
#import "ReportViewController.h"


@interface MeetingAgendaViewController : ReportViewController;

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
