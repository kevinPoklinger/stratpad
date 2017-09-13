//
//  AboutYourStrategyViewController.h
//  StratPad
//
//  Created by Eric Rogers on August 4, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "MBLabel.h"
#import "MBRoundedScrollView.h"
#import "MBRoundedTextField.h"
#import "MBFormInstructionsLabel.h"

@interface LinedView : UIView 
@end

@interface AboutYourStrategyViewController : FormViewController<UITextFieldDelegate> {
 @private    
    MBRoundedScrollView *viewFieldset_;

    UILabel *lblTitle_;
    UILabel *lblSubTitle_;

    MBFormInstructionsLabel *lblInstructions_;
    
    UILabel *lblStratFileName_;
    UILabel *lblCompanyName_;
    UILabel *lblCity_;
    UILabel *lblProvinceState_;
    UILabel *lblCountry_;
    UILabel *lblIndustry_;    
    
    MBRoundedTextField *txtStratFileName_;
    MBRoundedTextField *txtCompanyName_;
    MBRoundedTextField *txtCity_;
    MBRoundedTextField *txtProvinceState_;
    MBRoundedTextField *txtCountry_;
    MBRoundedTextField *txtIndustry_;    
    
    StratFile *stratFile_;
}

@property(nonatomic, retain) IBOutlet MBRoundedScrollView *viewFieldset;

@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblSubTitle;
@property(nonatomic, retain) IBOutlet MBFormInstructionsLabel *lblInstructions;

@property(nonatomic, retain) IBOutlet UILabel *lblStratFileName;
@property(nonatomic, retain) IBOutlet UILabel *lblCompanyName;
@property(nonatomic, retain) IBOutlet UILabel *lblCity;
@property(nonatomic, retain) IBOutlet UILabel *lblProvinceState;
@property(nonatomic, retain) IBOutlet UILabel *lblCountry;
@property(nonatomic, retain) IBOutlet UILabel *lblIndustry;

@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtStratFileName;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtCompanyName;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtCity;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtProvinceState;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtCountry;
@property(nonatomic, retain) IBOutlet MBRoundedTextField *txtIndustry;

@end
