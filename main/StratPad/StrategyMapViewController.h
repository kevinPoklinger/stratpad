//
//  StrategyMapViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-18.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportViewController.h"
#import "StrategyMapView.h"
#import "MBReportView.h"
#import "MBReportHeaderView.h"
#import "ReportPrintFonts.h"

// these are the number of rows shown, not the total available
#define numStratMapRows 6

// this is the number of objectives that can fit on 1 page
extern uint const maxWidth;

// how many themes can we place on a page?
extern uint const maxThemesPerPage;

@interface StrategyMapViewController : ReportViewController {
    UIScrollView *scrollView_;
        
    MBReportHeaderView *reportHeaderView_;
    
    StrategyMapView *strategyMapView_;
    
    NSUInteger pageNumber_;
    
    id<PrintReportDelegate> printDelegate_;
}

@property (nonatomic,retain) IBOutlet MBReportHeaderView *reportHeaderView;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet StrategyMapView *strategyMapView;

@property(nonatomic, retain) id<PrintReportDelegate> printDelegate;

@property (retain, nonatomic) IBOutlet UILabel *lblStrategy;
@property (retain, nonatomic) IBOutlet UILabel *lblThemes;
@property (retain, nonatomic) IBOutlet UILabel *lblFinancial;
@property (retain, nonatomic) IBOutlet UILabel *lblCustomer;
@property (retain, nonatomic) IBOutlet UILabel *lblProcess;
@property (retain, nonatomic) IBOutlet UILabel *lblStaff;

@property (nonatomic,retain) IBOutlet UILabel *lblThemesDescription;
@property (nonatomic,retain) IBOutlet UILabel *lblFinancialDescription;
@property (nonatomic,retain) IBOutlet UILabel *lblCustomerDescription;
@property (nonatomic,retain) IBOutlet UILabel *lblProcessDescription;
@property (nonatomic,retain) IBOutlet UILabel *lblStaffDescription;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPageNumber:(NSUInteger)pageNumber;

// @return pageNum -> nsarray of stratMapTheme
+ (NSDictionary*)createStratMapThemes:(StratFile*)stratFile;
+ (NSUInteger)numberOfPages:(StratFile*)stratFile;

@end

#pragma mark -

@interface SplitTheme : NSObject {
@private
    Theme *theme_;
    NSSet *objectives_;
}
@property(nonatomic,retain) Theme *theme;
@property(nonatomic,retain) NSSet *objectives;

// look through objectives for each objective type, in order, and collect all up to width
+ (NSSet*)subSetOfObjectivesForTheme:(Theme*)theme forWidth:(uint)width forRemainder:(BOOL)forRemainder;
+ (NSSet*)subSetOfObjectives:(NSSet*)objectives forWidth:(uint)width forRemainder:(BOOL)forRemainder;

// measure the themeWidth of whatever remaining objectives we have, rather than the theme's objectives
- (NSUInteger)themeWidth;
@end

#pragma mark -

@interface StratMapTheme : NSObject {
@private
    Theme *theme_;
    uint pageNum_;
    NSSet *objectives_;
}
@property(nonatomic,retain) Theme *theme;
@property(nonatomic,assign) uint pageNum;
// these are the objectives that fit on a page for a particular theme
@property(nonatomic,retain) NSSet *objectives;
@end

