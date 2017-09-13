//
//  AboutYourStrategyViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AboutYourStrategyViewController.h"
#import "StratFileManager.h"
#import "EventManager.h"
#import "NSString-Expanded.h"
#import "ApplicationSkin.h"
#import "UIColor-Expanded.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "PermissionChecker.h"

@interface AboutYourStrategyViewController ()
@property (nonatomic,retain) PermissionChecker *permissionChecker;
@end

@implementation LinedView

- (void)drawRect:(CGRect)rect
{   
    CGContextRef context = UIGraphicsGetCurrentContext();    

    // draw horizontal lines across the view undernath each row, except for the last.    
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    int numRows = 6;
    int rowHeight = self.bounds.size.height / numRows;
    
    for (int i = 1; i < numRows; i++) {
        int y = i * rowHeight;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, self.frame.size.width, y);
    }
	CGContextStrokePath(context);
}


@end

@implementation AboutYourStrategyViewController

@synthesize viewFieldset = viewFieldset_;
@synthesize lblTitle = lblTitle_;
@synthesize lblSubTitle = lblSubTitle_;
@synthesize lblInstructions = lblInstructions_;

@synthesize lblStratFileName = lblStratFileName_;
@synthesize lblCompanyName = lblCompanyName_;
@synthesize lblCity = lblCity_;
@synthesize lblProvinceState = lblProvinceState_;
@synthesize lblCountry = lblCountry_;
@synthesize lblIndustry = lblIndustry_;

@synthesize txtStratFileName = txtStratFileName_;
@synthesize txtCompanyName = txtCompanyName_;
@synthesize txtCity = txtCity_;
@synthesize txtProvinceState = txtProvinceState_;
@synthesize txtCountry = txtCountry_;
@synthesize txtIndustry = txtIndustry_;

- (void)dealloc
{
    [_permissionChecker release];
    [viewFieldset_ release];
    
    [lblTitle_ release];
    [lblSubTitle_ release];
    [lblInstructions_ release];
    
    [lblStratFileName_ release];
    [lblCompanyName_ release];
    [lblCity_ release];
    [lblProvinceState_ release];
    [lblCountry_ release];
    [lblIndustry_ release];
    
    [txtStratFileName_ release];
    [txtCompanyName_ release];
    [txtCity_ release];
    [txtProvinceState_ release];
    [txtCountry_ release];
    [txtIndustry_ release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    stratFile_ = stratFileManager_.currentStratFile;
    
    PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:stratFile_];
    self.permissionChecker = checker;
    [checker release];
            
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    self.viewFieldset.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2FormBackgroundColor];
    
    self.lblTitle.font = [UIFont fontWithName:skin.section2TitleFontName size:[skin.section2TitleFontSize floatValue]];
    self.lblTitle.textColor = [UIColor colorWithHexString:skin.section2TitleFontColor];

    self.lblSubTitle.font = [UIFont fontWithName:skin.section2SubtitleFontName size:[skin.section2SubtitleFontSize floatValue]];
    self.lblSubTitle.textColor = [UIColor colorWithHexString:skin.section2SubtitleFontColor];

    self.lblInstructions.backgroundColor = [UIColor colorWithHexString:skin.section2InfoBoxBackgroundColor];
    self.lblInstructions.strokeColor = [UIColor colorWithHexString:skin.section2InfoBoxStrokeColor];
    self.lblInstructions.font = [UIFont fontWithName:skin.section2InfoBoxFontName size:[skin.section2InfoBoxFontSize floatValue]];
    self.lblInstructions.textColor = [UIColor colorWithHexString:skin.section2InfoBoxFontColor];

    self.lblStratFileName.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblStratFileName.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.lblCompanyName.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblCompanyName.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.lblCity.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblCity.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.lblProvinceState.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblProvinceState.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.lblCountry.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblCountry.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    self.lblIndustry.font = [UIFont fontWithName:skin.section2F1F3FieldLabelFontName size:[skin.section2F1F3FieldLabelFontSize floatValue]];
    self.lblIndustry.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    
    // we want to know when the title changes; the RootViewController is ultimately listening
    self.txtStratFileName.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtStratFileName.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.txtStratFileName.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    [self.txtStratFileName addTarget:self action:@selector(stratFileNameDidChange) forControlEvents:UIControlEventEditingChanged];

    self.txtCompanyName.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtCompanyName.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.txtCompanyName.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    
    self.txtCity.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtCity.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.txtCity.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    
    self.txtProvinceState.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtProvinceState.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.txtProvinceState.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    
    self.txtCountry.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtCountry.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.txtCountry.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    
    self.txtIndustry.font = [UIFont fontWithName:skin.section2F1TextValueFontName size:[skin.section2F1TextValueFontSize floatValue]];
    self.txtIndustry.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    self.txtIndustry.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
        
    StratFile *stratFile = stratFileManager_.currentStratFile;
    self.txtStratFileName.text = stratFile.name;
    self.txtCompanyName.text = stratFile.companyName;
    self.txtCity.text = stratFile.city;
    self.txtProvinceState.text = stratFile.provinceState;
    self.txtCountry.text = stratFile.country;
    self.txtIndustry.text = stratFile.industry;
    
    [super viewDidLoad];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [_permissionChecker checkReadWrite];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *value = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Note: txtStratFileName data is taken care of in stratFileNameDidChange
    
    if (textField == self.txtCompanyName) {
        stratFile_.companyName = [value isBlank] ? textField.placeholder : value;
        
    } else if (textField == self.txtCity) {
        stratFile_.city = value;
        
    } else if (textField == self.txtProvinceState) {
        stratFile_.provinceState = value;
        
    } else if (textField == self.txtCountry) {
        stratFile_.country = value;
        
    } else if (textField == self.txtIndustry) {
        stratFile_.industry = value;        
    }
    
    [stratFileManager_ saveCurrentStratFile];
    
}

- (void)configureResponderChain
{    
    // all of the input fields on this page
    responderChain_ = [[NSArray arrayWithObjects:
                        self.txtStratFileName,
                        self.txtCompanyName,
                        self.txtCity,
                        self.txtProvinceState,
                        self.txtCountry,
                        self.txtIndustry,
                        nil] retain];
    
    // all text fields (ie keyboard up) use next button in KB
    for (int i=0, ct = [responderChain_ count]; i<ct; ++i) {
        UIResponder *responder = [responderChain_ objectAtIndex:i];
        if ([responder isKindOfClass:[UITextField class]]) {
            // if a textfield is last, it can use done button in KB, which will dismiss the keyboard
            [(UITextField*)responder setReturnKeyType:(i == ct-1) ? UIReturnKeyDone : UIReturnKeyNext];
        }            
    }
}


#pragma mark - Event Listeners

- (void)stratFileNameDidChange
{
    stratFile_.name = [self.txtStratFileName.text isBlank] ? self.txtStratFileName.placeholder : [self.txtStratFileName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];        
    
    [EventManager fireStratFileTitleChangedEvent];
}

#pragma mark - Video

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70574880.m3u8?p=high,standard,mobile&s=80bf9330b006bf67e2a6f9897f0f3cf8";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F1.mov" ofType:@"mp4"];
    return path;
}


@end
