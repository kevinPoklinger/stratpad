//
//  YammerOAuth2LoginViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-08-08.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YammerOAuth2LoginViewController : UIViewController <UITextFieldDelegate> {
    @private
    NSString *reportName_;
    NSString *path_;
}

- (id)initWithPath:(NSString *)path reportName:(NSString *)reportName;

@property (retain, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (retain, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnSignIn;
@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) IBOutlet UILabel *lblErrorMessage;

@end
