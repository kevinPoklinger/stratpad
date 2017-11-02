//
//  StratFileBasicsViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-07.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "FormViewController.h"
#import "MBPlaceHolderTextView.h"
#import "MBRoundedRectView.h"

@interface StratFileBasicsViewController : FormViewController {
@protected
    UILabel *lblTitle_;
    UILabel *lblSubTitle_;
    UILabel *lblInstructions_;
    
    MBRoundedRectView *roundedRectView_;
    MBPlaceHolderTextView *txtViewBasic_;  
    NSString *fieldName_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblSubTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblInstructions;
@property(nonatomic, retain) IBOutlet MBRoundedRectView *roundedRectView;
@property(nonatomic, retain) IBOutlet MBPlaceHolderTextView *txtViewBasic;
@property(nonatomic, copy) NSString *fieldName;

@end
