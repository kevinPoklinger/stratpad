//
//  StratFileBasicsViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-07.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileBasicsViewController.h"
#import "UIColor-Expanded.h"
#import "ApplicationSkin.h"
#import "PermissionChecker.h"

@interface StratFileBasicsViewController ()
@property (nonatomic,retain) PermissionChecker *permissionChecker;
@end

@implementation StratFileBasicsViewController

@synthesize lblTitle = lblTitle_;
@synthesize lblSubTitle = lblSubTitle_;
@synthesize lblInstructions = lblInstructions_;
@synthesize roundedRectView = roundedRectView_;
@synthesize txtViewBasic = txtViewBasic_;
@synthesize fieldName = fieldName_;

#pragma mark - Memory Management

- (void)dealloc
{
    [_permissionChecker release];
    [lblTitle_ release];
    [lblSubTitle_ release];
    [lblInstructions_ release];
    [roundedRectView_ release];
    [txtViewBasic_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    StratFile *stratFile = stratFileManager_.currentStratFile;

    PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:stratFile];
    self.permissionChecker = checker;
    [checker release];

    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    self.roundedRectView.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2FormBackgroundColor];
    
    self.lblTitle.font = [UIFont fontWithName:skin.section2TitleFontName size:[skin.section2TitleFontSize floatValue]];
    self.lblTitle.textColor = [UIColor colorWithHexString:skin.section2TitleFontColor];
    
    self.lblSubTitle.font = [UIFont fontWithName:skin.section2SubtitleFontName size:[skin.section2SubtitleFontSize floatValue]];
    self.lblSubTitle.textColor = [UIColor colorWithHexString:skin.section2SubtitleFontColor];

    self.lblInstructions.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblInstructions.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.txtViewBasic.placeholder = LocalizedString(@"TEXTVIEW_PLACEHOLDER", nil);
    self.txtViewBasic.font = [UIFont fontWithName:skin.section2F2F3TextValueFontName size:[skin.section2F2F3TextValueFontSize floatValue]];
    self.txtViewBasic.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.txtViewBasic.placeholderColor = [UIColor colorWithHexString:skin.section2PlaceHolderFontColor];
    self.txtViewBasic.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];

    self.txtViewBasic.text = [stratFile valueForKey:self.fieldName];
    self.txtViewBasic.tag = TextViewTag;
        
    // part of MBPlaceHolderTextView placeholder impl
    NSNotification *notification = [NSNotification notificationWithName:UITextViewTextDidChangeNotification object:nil userInfo:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];		
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Sometimes when the text view is loaded off screen, it will not render its text properly.  Therefore,
    // we have to fake a slight scroll to get it to render.
    // See: http://stackoverflow.com/questions/133243/text-from-uitextview-does-not-display-in-uiscrollview
    CGPoint contentOffset = self.txtViewBasic.contentOffset;
    self.txtViewBasic.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + 1);
    self.txtViewBasic.contentOffset = contentOffset;
    [self.txtViewBasic setNeedsDisplay];

    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.lblTitle = nil;
    self.lblSubTitle = nil;
    self.lblInstructions = nil;
    self.txtViewBasic = nil;
    self.roundedRectView = nil;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [_permissionChecker checkReadWrite];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [stratFileManager_.currentStratFile setValue:self.txtViewBasic.text forKey:self.fieldName];
    [stratFileManager_ saveCurrentStratFile];
    [super textViewDidEndEditing:textView];
}

@end
