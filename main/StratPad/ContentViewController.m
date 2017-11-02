//
//  ContentViewController.m
//  StratPad
//
//  Created by Eric on 11-07-27.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ContentViewController.h"
#import "MBRoundedTextField.h"
#import "ThemeOptionsViewController.h"
#import "ObjectiveDetailViewController.h"
#import "ActivityDetailViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "Chapter.h"
#import "Page.h"
#import "StrategyMapViewController.h"
#import "StrategyFinancialAnalysisMonthViewController.h"
#import "StrategyFinancialAnalysisThemeViewController.h"
#import "ThemeFinancialAnalysisMonthViewController.h"
#import "ThemeDetailReportViewController.h"
#import "GanttViewController.h"
#import "ProjectPlanViewController.h"
#import "MeetingAgendaViewController.h"
#import "BusinessPlanViewController.h"
#import "Tracking.h"
#import "AdViewController.h"
#import "CalculationsViewController.h"
#import "Settings.h"
#import "DataManager.h"
#import "EditionManager.h"
#import "YammerCommentManager.h"
#import "MBReportHeader.h"
#import "UIImage-Expanded.h"
#import "YammerCommentsViewController.h"
#import "Chart.h"
#import "IncomeStatementDetailViewController.h"
#import "IncomeStatementSummaryViewController.h"
#import "CashFlowDetailViewController.h"
#import "CashFlowSummaryViewController.h"
#import "BalanceSheetDetailViewController.h"
#import "BalanceSheetSummaryViewController.h"
#import "FormViewController.h"
#import "ReportViewController.h"
#import "ReferenceViewController.h"
#import "Reachability.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

// we can't get the keyboard height until after the first text field is being edited.
// so default it to the general keyboard height for the iPad.
static NSUInteger sKeyboardHeight = 352;  

@interface ContentViewController ()
@end

@implementation ContentViewController

@synthesize chapter, pageNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {        
        stratFileManager_ = [StratFileManager sharedManager];
    }
    return self;
}

- (void)dealloc
{
    [chapter release];
    [responderChain_ release];
    [disabledView_ release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];


    // every time we open a page, update the dateLastAccessed
    [[stratFileManager_ currentStratFile] setDateLastAccessed:[NSDate date]];
    
    if ([self isEnabled]) {    
        [disabledView_ removeFromSuperview];
    } else {
        [disabledView_ showInView:self.view];
    }
    
    isKeyboardShowing_ = NO;
    
    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // force the current view to end editing
    [self.view endEditing:YES];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // remove the observers here since doing so in viewWillDisappear may lead to doing so before the keyboard actually hides.
    // also, want to make sure these are gone when this view is still around, but not the current view
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    // remove the yammer comments button
    UIView *btnView = [self.view viewWithTag:8721];
    [btnView removeFromSuperview];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // add swiping hand to views
    NSArray *viewControllersWithNoHands = [NSArray arrayWithObjects:
                                           [ThemeOptionsViewController class], 
                                           [ObjectiveDetailViewController class], 
                                           [ActivityDetailViewController class],
                                           [CalculationsViewController class],
                                           nil];
    
    // we don't add swiping hands to any view controllers defined in the array above...
    if (![viewControllersWithNoHands containsObject:[self class]]) {
        [self addSwipingHandToView];
    }

    // get PageViewController from the RootViewController
    AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];

    // record an event
    [Tracking pageView:[chapter.title stringByReplacingOccurrencesOfString:@"\n" withString:@" "] chapter:chapter pageNum:pageVC.pageNumber+1];
            
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    disabledView_ = [[MBDisabledView alloc] initWithFrame:self.view.bounds andTitle:[self messageWhenDisabled]];
                    
    // this gets us set up for next/prev where required
    [self configureResponderChain];
    
    // add a video icon if necessary
    if ([self hasVideo]) {
        CGSize btnSize = CGSizeMake(70, 33);
        
        if ([self isKindOfClass:[ReferenceViewController class]]) {
            
            UIEdgeInsets margin = UIEdgeInsetsMake(5, 0, 0, 5);
            UIButton *btn = [self helpVideoButton];
            btn.frame = CGRectMake(self.view.frame.size.width-btnSize.width-margin.right, margin.top, btnSize.width, btnSize.height);
            [self.view addSubview:btn];
            
        }
        else if ([self isKindOfClass:[FormViewController class]]) {
            UIEdgeInsets margin = UIEdgeInsetsMake(5, 0, 0, 20);
            UIButton *btn = [self helpVideoButton];
            btn.frame = CGRectMake(self.view.frame.size.width-btnSize.width-margin.right, margin.top, btnSize.width, btnSize.height);
            [self.view addSubview:btn];

        }
        else if ([self isKindOfClass:[ReportViewController class]]) {
            
            // reports can go right-aligned under the 104px header
            UIEdgeInsets margin = UIEdgeInsetsMake(104+10, 0, 0, 15);
            CGRect f = CGRectMake(self.view.frame.size.width-btnSize.width-margin.right, margin.top, btnSize.width, btnSize.height);
            
            UIButton *btn = [self helpVideoButton];
            btn.frame = f;

            // R5 to R9 must scroll with content
            // in each of these reports, the first subview of the VC's view is a scrollview, or a webview (in R8) with the same bounds as the VC.view (ie includes the header area)
            if (self.chapter.chapterIndex >= ChapterIndexThemeDetailReport && self.chapter.chapterIndex <= ChapterIndexBusinessPlan) {
                UIView *subview = [[self.view subviews] objectAtIndex:0];
                if ([subview isKindOfClass:[UIWebView class]]) {
                    [[(UIWebView*)subview scrollView] addSubview:btn];
                }
                else {
                    [subview addSubview:btn];
                }
            }
            else {
                [self.view addSubview:btn];
            }
            
        }
        // stratboard has its own video help button
    }

    [super viewDidLoad];
}

- (void)addBackgroundImageToView:(UIImage*)backgroundImage
{
    if (backgroundImage) {
        UIImageView *pageBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        pageBackgroundView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, backgroundImage.size.width, backgroundImage.size.height);
        [self.view insertSubview:pageBackgroundView atIndex:0];
        [pageBackgroundView release];    
    }
}

- (void)addSwipingHandToView
{
    NSArray *viewControllersWithTopRightRect = [NSArray arrayWithObjects:
                                                [IncomeStatementDetailViewController class],
                                                [CashFlowDetailViewController class],
                                                [BalanceSheetDetailViewController class],
                                                nil];
    
    UIImage *swipingHand = [UIImage imageNamed:@"hand-swipe-red"];
    CGSize handSize = swipingHand.size;

    // default position
    CGRect bottomRightRect = CGRectMake(self.view.frame.size.width - handSize.width,
                                       self.view.frame.size.height - handSize.height,
                                       handSize.width,
                                       handSize.height);
    
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    BOOL isStratCard = [self.chapter.chapterNumber isEqualToString:@"S1"] && self.pageNumber == 0;
    BOOL didAddLogo = [[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport] && settings.consultantLogo && !isStratCard;
    CGFloat spaceForLogo = didAddLogo ? 100 : 0;
    CGRect topRightRect = CGRectMake(self.view.frame.size.width - handSize.width - spaceForLogo,
                                     self.view.frame.origin.y + 10,
                                     handSize.width,
                                     handSize.height);
    
    CGRect rect = [viewControllersWithTopRightRect containsObject:[self class]] ? topRightRect : bottomRightRect;
    UIImageView *swipingHandView = [[UIImageView alloc] initWithImage:swipingHand];
    swipingHandView.frame = rect;

    swipingHandView.alpha = 0;
        
    // remove hand after 5s
    [UIView animateWithDuration:1.0
                     animations:^{
                         swipingHandView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0 delay:5 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              swipingHandView.alpha = 0;
                                          } 
                                          completion:^(BOOL finished) {
                                              if (finished) {
                                                  [swipingHandView removeFromSuperview];
                                              }
                                          }];

                     }
     ];
    
    [self.view addSubview:swipingHandView];
    [swipingHandView release];
}

// subview must be a subview of self.view
// method should be called in viewDidAppear from the relevant CVC subclass
- (void)addYammerCommentsButtonToView:(UIView*)subview
{    
    // make sure that the feature is enabled and that this report has been published
    // it is available regardless of the number of unread comments (ie. you might want to post one, or review)
    StratFile *stratfile = [[StratFileManager sharedManager] currentStratFile];
    
    // sanity
    BOOL shouldDrawYammerCommentsItem = self.chapter.chapterNumber && self.pageNumber < INT_MAX;
    shouldDrawYammerCommentsItem &= [stratfile isPublishedToYammer:self.chapter.chapterNumber pageNumber:self.pageNumber];
    
    // yammer comments (MBDrawable doesn't support buttons, so draw here)
    if (shouldDrawYammerCommentsItem) {        
        Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                                sortDescriptorsOrNil:nil
                                                      predicateOrNil:nil];
        BOOL isChart = [self.chapter.chapterNumber isEqualToString:@"S1"] && self.pageNumber > 0;
        BOOL isStratCard = [self.chapter.chapterNumber isEqualToString:@"S1"] && self.pageNumber == 0;
        BOOL didAddLogo = [[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport] && settings.consultantLogo && !isStratCard;
        
        // see if we have a company logo; draw yammer to the left of that logo
        UIImage *imgYammerLogo = [UIImage imageNamed:@"yammer-icon.png"];
        CGPoint origin;
        CGRect f = subview.frame;
        UIEdgeInsets margin = UIEdgeInsetsMake(7, 8, 7, 8);
        
        CGFloat offsetX = 0;
        if (didAddLogo) {
            // figure out how big the logo was
            UIImage *imgLogo = settings.consultantLogo;
            CGSize sizeForLogo = [imgLogo sizeForProportionalImageWithMaxDim:logoMaxDim];
            offsetX = sizeForLogo.width + logoMargin;
        }
        
        // we don't show the company logo on any stratboard pages, but we do have one or two buttons in the way
        else if (isStratCard) {
            // 1 button widths and 1 margin
            offsetX = 1*81.f + 1*8.f;
            margin = UIEdgeInsetsMake(8, 8, 7, 8);
        }
        else if (isChart) {
            // 2 button widths and 2 margins
            offsetX = 2*81.f + 8.f + 10.f;
            margin = UIEdgeInsetsMake(9, 8, 7, 8);
        }
        origin = CGPointMake(CGRectGetMaxX(f)- offsetX - margin.right - imgYammerLogo.size.width, f.origin.y + margin.top);
        
        CGRect rectForYamLogo = CGRectMake(origin.x, origin.y, imgYammerLogo.size.width, imgYammerLogo.size.height);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:imgYammerLogo forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showYammerConversationsView:) forControlEvents:UIControlEventTouchUpInside];
        btn.alpha = 0;
        btn.tag = 8721;
        btn.frame = rectForYamLogo;
        [subview addSubview:btn];
        
        [UIView animateWithDuration:0.5 animations:^{
            btn.alpha = 1.0;
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)willShowKeyboard:(NSNotification*)notification
{
    // note this is only called for virtual keyboards, not physical ones
    isKeyboardShowing_ = YES;
    
    NSValue *keyboardInfo = [notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [keyboardInfo CGRectValue].size;
    
    // since we are in landscape orientation, the width contains the actual height of the keyboard.
    sKeyboardHeight = keyboardSize.height;
    
    TLog(@"Keyboard height is %i", sKeyboardHeight);
    
    // scroll to the active textfield, and reduce the scrollview so it doesn't go under the keyboard
    // note that in F2, we don't set up a responderChain
    if ([responderChain_ count] > 0) {
        // first one is always a text field
        UITextField *textField = [responderChain_ objectAtIndex:0];
        UIScrollView *scrollView = (UIScrollView*)[textField superview];
        [self shrinkViewIfKeyboardCoversTargetView:scrollView];    
        
        // find the currentResponder
        for (UIResponder *responder in responderChain_) {
            if ([responder isFirstResponder] && [responder isKindOfClass:[MBTextField class]]) {
                [self scrollForTextField:(MBTextField*)responder];
                break;
            }
        }
    }
    // look for a textview
    else {
        UITextView *textView = (UITextView*)[self.view viewWithTag:TextViewTag];
        [self shrinkViewIfKeyboardCoversTargetView:textView];
    }
}

- (void)willHideKeyboard:(NSNotification*)notification
{
    isKeyboardShowing_ = NO;
    
    if ([responderChain_ count] > 0) {
        // first one is always a text field
        UITextField *textField = [responderChain_ objectAtIndex:0];
        UIScrollView *scrollView = (UIScrollView*)[textField superview];
        [self restoreViewToOriginalSize:scrollView];    
    }
    // look for a textview
    else {
        UITextView *textView = (UITextView*)[self.view viewWithTag:TextViewTag];
        [self restoreViewToOriginalSize:textView];
    }

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // should always be YES
    // notify the next responder and dismiss this one
    for (int i=0, ct=[responderChain_ count]; i<ct; ++i) {
        UIResponder *responder = [responderChain_ objectAtIndex:i];
        if ([responder isEqual:textField]) {
            if (i+1 < ct) {
                // we don't always want to resign the first responder, because we might be going to
                // another text field, and don't want to reset the scroll, etc
                UIResponder *newResponder = [responderChain_ objectAtIndex:i+1];
                if (![newResponder isKindOfClass:[MBTextField class]]) {
                    [responder resignFirstResponder];
                }
                [newResponder becomeFirstResponder];
                return YES;
            } else {
                // last one; will have a done button; just dismiss keyboard
                [responder resignFirstResponder];
            }
        }
    }
    WLog(@"Couldn't find this field in the responderchain: %@", textField);
    return YES;
}


#pragma mark - Private


- (void)scrollForTextField:(MBTextField*)textField
{
    UIScrollView *scrollView = (UIScrollView*)textField.superview;
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    UILabel *label = textField.label;
        
    // we want to scroll to the top of either the label or the textfield, depending on 
    // which one is higher up in the view.  This way, they are both visible when editing.
    CGFloat scrollY;
    if (label.frame.origin.y < textField.frame.origin.y) {
        scrollY = label.frame.origin.y;
    } else {
        scrollY = textField.frame.origin.y;
    }
    
    // set the offset to the origin of the label, not the textfield.
    [scrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];    
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self shrinkViewIfKeyboardCoversTargetView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self restoreViewToOriginalSize:textView];
}


#pragma mark - Support

- (void)shrinkViewIfKeyboardCoversTargetView:(UIScrollView*)targetView
{
    // don't bother if we're not UIScrollView or UITextView
    if (![targetView isKindOfClass:[UIScrollView class]]) {
        return;
    }

    targetView.clipsToBounds = YES;
    
    // don't bother if we're a physical kb (ie the virtual kb never showed)
    if (!isKeyboardShowing_) {
        return;
    }
    
    UIView *rootView = (UIView*)[self.view.window.subviews objectAtIndex:0];
 
    if (originalHeight_ == 0) {    
        originalHeight_ = targetView.frame.size.height;        
    }
        
    CGRect convertedRect = [rootView convertRect:targetView.frame fromView:targetView.superview];    
    CGFloat keyboardTopY = rootView.bounds.size.height - sKeyboardHeight;
    
    if ((convertedRect.origin.y + targetView.frame.size.height) > keyboardTopY) {
        
        CGFloat adjustedHeight = keyboardTopY - convertedRect.origin.y;        
        [UIView animateWithDuration:0.2
                         animations:^{
                             targetView.center = CGPointMake(targetView.center.x, targetView.frame.origin.y + adjustedHeight/2);
                             targetView.bounds = CGRectMake(0, 0, targetView.bounds.size.width, adjustedHeight);                             
                         } completion:^(BOOL finished) {
                             // scrolling won't work after resizing unless we explicitly set the frame.
                             targetView.frame = CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height);                             
                         }
         ];
    }
}

- (void)restoreViewToOriginalSize:(UIScrollView*)targetView
{
    if (![targetView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    // don't try to restore an original height of 0.
    if (originalHeight_ > 0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             // the original height for the target view was cached
                             targetView.center = CGPointMake(targetView.center.x, targetView.frame.origin.y + originalHeight_/2);
                             targetView.bounds = CGRectMake(0, 0, targetView.frame.size.width, originalHeight_);                             
                         } completion:^(BOOL finished) {
                             targetView.frame = CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height);                             
                         }
         ];    
    }    
}

- (NSUInteger)keyboardHeight
{
    return sKeyboardHeight;
}

#pragma mark - Protected

- (void)exportToPDF
{
    WLog(@"Override!! %@", NSStringFromClass([self class]));
    @throw [NSException exceptionWithName:@"Invalid Implementation" reason:@"You're lazy" userInfo:nil];
}

- (BOOL)isEnabled
{
    return YES;
}

- (NSString*)messageWhenDisabled
{
    return @"DISABLED";
}

-(BOOL)hasVideo
{
    return NO;
}

-(void)playHelpVideo:(UIButton*)button
{
    player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[self helpVideoURL]]];
    //player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[self helpVideoURL]]];
    [player.view setBounds:self.view.bounds];
    [player.moviePlayer prepareToPlay];
    [player.moviePlayer setFullscreen:YES animated:YES];
    [player.moviePlayer setShouldAutoplay:YES];
    [player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayingErrorNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:player.moviePlayer];
    
    UIViewController* rootController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] window].rootViewController;
    if (rootController != NULL)
        [rootController presentMoviePlayerViewControllerAnimated:player];
    else
        [self presentMoviePlayerViewControllerAnimated:player];
    
    [player release];
/*
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (reachability.isReachable) {
        

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"OFFLINE", nil)
                                                        message:LocalizedString(@"HelpVideoOffline", nil)
                                                       delegate:nil
                                              cancelButtonTitle:LocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
*/
}

-(void)playerPlayingErrorNotification:(NSNotification*)notif
{
    NSNumber* reason = [[notif userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"Playback Ended");
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"Playback Error");
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"User Exited");
            break;
        default:
            break;
    }
}


-(NSString*)helpVideoURL
{
    WLog(@"Override!!!");
    
    // this is a generic StratPad video
    // this is the "http live streaming url" from vimeo; not sure it makes any difference from the other URL's (they appear the same)
    //return @"http://player.vimeo.com/external/70247560.m3u8?p=high,standard,mobile&s=3b3d72b01ffd1dffb9926d3fca087c89";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F1.mov" ofType:@"mp4"];
    return path;
}

-(UIButton*) helpVideoButton
{
    UIImage *btnGrey = [[UIImage imageNamed:@"button-grey.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:btnGrey forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btn.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn setTitle:LocalizedString(@"HelpVideoButtonText", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(playHelpVideo:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (void)configureResponderChain
{
    // set up the next's for the textfields
    // implement - (BOOL)textFieldShouldReturn:(UITextField *)textField, called when you hit next
    // becomeFirstResponder on next text field
    // override becomefirstResponder on MBCalendarButton to show the popover
    // set next responder on MBCalendar button
    // call becomefirstresponder when hitting next in date popover
    
    // all of the input fields on this page (none by default)
    responderChain_ = [[NSArray array] retain];
}

#pragma mark - Private

-(void)showYammerConversationsView:(UIControl*)control
{
    StratFile *stratfile = [stratFileManager_ currentStratFile];
    NSPredicate *predicate;
    if ([self.chapter.chapterNumber isEqualToString:@"S1"]) {
        if (self.pageNumber == 0) {
            // stratcard
            predicate = [NSPredicate predicateWithFormat:@"chapterNumber=%@ && stratFile=%@", self.chapter.chapterNumber, stratfile];
        }
        else {
            Chart *chart = [Chart chartAtPage:self.pageNumber stratFile:[stratFileManager_ currentStratFile]];
            predicate = [NSPredicate predicateWithFormat:@"chapterNumber=%@ && chart.uuid=%@ && stratFile=%@", self.chapter.chapterNumber, chart.uuid, stratfile];
        }
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"chapterNumber=%@ && stratFile=%@", self.chapter.chapterNumber, stratfile];
    }
    
    YammerPublishedReport *yamReport = (YammerPublishedReport*)[DataManager objectForEntity:NSStringFromClass([YammerPublishedReport class])
                                                     sortDescriptorsOrNil:nil
                                                           predicateOrNil:predicate];
    
    YammerCommentsViewController *vc = [[YammerCommentsViewController alloc] initWithYammerPublishedReport:yamReport];
    NSString *title = [NSString stringWithFormat:LocalizedString(@"YAMMER_COMMENTS_WINDOW_TITLE", nil), self.chapter.title];
    [vc showPopoverFromControl:control title:title];
    [vc release];
}


@end
