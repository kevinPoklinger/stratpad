//
//  RegistrationKeyEntryViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-02-05.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "RegistrationKeyEntryViewController.h"
#import "RegistrationManager.h"
#import "NSString-Expanded.h"
#import "MenuNavController.h"

@interface RegistrationKeyEntryViewController ()
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UITextField *txtRegKey;
@property (retain, nonatomic) IBOutlet UILabel *lblValid;
@property (retain, nonatomic) IBOutlet UIButton *btnDone;
- (IBAction)done;

@end

@implementation RegistrationKeyEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = LocalizedString(@"REGISTRATION_ENTER_KEY", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // for form view
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [_btnDone setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [_btnDone.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    _txtRegKey.delegate = self;
    _txtEmail.delegate = self;
    
    [_txtEmail setText:[[NSUserDefaults standardUserDefaults] stringForKey:keyEmail]];
    
    _lblValid.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_btnDone setEnabled:NO];
    [_txtRegKey becomeFirstResponder];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    // stay the same as the parent menu
    return CGSizeMake(self.view.bounds.size.width, 100);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_txtEmail release];
    [_txtRegKey release];
    [_btnDone release];
    [_lblValid release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setTxtEmail:nil];
    [self setTxtRegKey:nil];
    [self setBtnDone:nil];
    [self setLblValid:nil];
    [super viewDidUnload];
}

- (IBAction)done {
    // only enabled once we get the key right
    
    // go to thank you page
    [[RegistrationManager sharedManager] validateEmail:_txtEmail.text regKey:_txtRegKey.text];
    
    // dismiss
    [(MenuNavController*)self.navigationController dismissMenu];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_btnDone.enabled && [textField isEqual:_txtEmail]) {
        [_txtRegKey becomeFirstResponder];
    }
    else if ([textField isEqual:_txtRegKey]) {
        [self done];
    }    
    return NO;
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    if (![_txtEmail.text isBlank] && ![_txtRegKey.text isBlank] ) {
        RegistrationManager *regMan = [RegistrationManager sharedManager];
        NSString *regKey = [regMan performSelector:@selector(regKey:) withObject:_txtEmail.text];
        
        _btnDone.enabled = [regKey isEqualToString:_txtRegKey.text];
    }
    else {
        _btnDone.enabled = NO;
    }
    _lblValid.hidden = !_btnDone.enabled;
}

@end
