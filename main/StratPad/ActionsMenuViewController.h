//
//  ActionsMenuViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MenuNavController.h"
#import <MessageUI/MessageUI.h>
#import "Chapter.h"
#import "LMViewController.h"
#import "PdfHelper.h"

@interface ActionsMenuViewController : LMViewController <UITableViewDelegate, UITableViewDataSource, TableBasedMenu, MFMailComposeViewControllerDelegate> {
@private
    
    BOOL isPrintable_;
    
    Chapter *printChapter_;
    
    NSString *reportName_;
            
}

// amounts to are we on a page that supports printing (ie a report)
// currently true if the current page is a report
@property (nonatomic, assign) BOOL isPrintable;

// the chapter to be printed
@property (nonatomic, assign) Chapter *printChapter;

// the base name of the report, initially decided by RootViewController -> title of current chapter
// a name for the report, if we print or email it
@property (nonatomic, assign) NSString *reportName;

// 0-based index of the page in the chapter to be printed
@property (nonatomic, assign) NSInteger pageNumber;

// so that we can get rid of it, when we press another toolbar item
-(void)dismissPrintInteractionController;

// used after selecting charts
-(void)emailStratCard;
-(void)printStratCard;

@end


@interface ActionsMenuViewController (Testable)

// craft an email with a pdf attachment
-(void)emailPdf:(NSString*)path reportSize:(ReportSize)reportSize;
    
@end
