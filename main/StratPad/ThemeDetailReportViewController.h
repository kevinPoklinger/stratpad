//
//  ThemeDetailReportViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 30, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ReportViewController.h"
#import "Theme.h"
#import "MBPDFView.h"

@interface ThemeDetailReportViewController : ReportViewController {
@private
    UIScrollView *scrollView_;
    
    MBPDFView *pdfView_;
    
    Theme *theme_;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet MBPDFView *pdfView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme;

@end


@interface ThemeDetailReportViewController (Private)

// Returns a description of the person responsible for the current theme with the example formats;
// Nobody is responsible for this theme which starts on September 1, 2011 and ends on March 31, 2012.
// Mary Martin is responsible for this theme which has no start date and ends on March 31, 2012.
// Mary Martin is responsible for this theme which starts on September 1, 2011 and has no end date.
// Nobody is responsible for this theme which has no start date and has no end date.
- (NSString*)responsibleDescriptionForCurrentTheme;

// Returns a description of the theme with the following format:
// “This theme is [not]mandatory, [enhances/does not enhance] uniqueness, and [improves/does not improve] customer value.”
- (NSString*)descriptionForCurrentTheme;

@end
