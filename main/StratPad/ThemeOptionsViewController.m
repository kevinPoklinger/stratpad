//
//  ThemeDetailViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 9, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeOptionsViewController.h"
#import "NSString-Expanded.h"
#import "StratFileManager.h"
#import "ApplicationSkin.h"
#import "UIColor-Expanded.h"
#import "BooleanTableViewCell.h"

@implementation ThemeOptionsViewController

@synthesize roundedRectView = roundedRectView_;
@synthesize titleItem = titleItem_;
@synthesize lblTitle = lblTitle_;
@synthesize lblOptions = lblOptions_;
@synthesize txtTitle = txtTitle_;
@synthesize tblOptions = tblOptions_;
@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTheme:(Theme*)theme
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        theme_ = theme;
    }
    return self;
}

- (void)dealloc
{
    [roundedRectView_ release];
    [titleItem_ release];
    [lblTitle_ release];
    [lblOptions_ release];
    [txtTitle_ release];
    [tblOptions_ release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    self.roundedRectView.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2FormBackgroundColor];

    self.lblTitle.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];
    self.lblOptions.textColor = [UIColor colorWithHexString:skin.section2FieldLabelFontColor];

    self.txtTitle.textColor = [UIColor colorWithHexString:skin.section2TextValueFontColor];
    self.txtTitle.roundedRectBackgroundColor = [UIColor colorWithHexString:skin.section2TextFieldBackgroundColor];
    
    self.tblOptions.backgroundColor = [UIColor colorWithHexString:skin.section2TableCellBackgroundColor];
    
    self.titleItem.title = theme_.title;
    self.txtTitle.text = theme_.title;

    tblOptions_.clipsToBounds = YES;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.roundedRectView = nil;
    self.titleItem = nil;
    self.lblTitle = nil;
    self.lblOptions = nil;
    self.txtTitle = nil;
    self.tblOptions = nil;
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self.txtTitle becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // ensure we hide the keyboard
    [self.view endEditing:YES];

    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    BooleanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BooleanTableViewCell"];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BooleanTableViewCell class]) owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    // skin
    ApplicationSkin *skin = [ApplicationSkin currentSkin];
    cell.contentView.backgroundColor = [UIColor colorWithHexString:skin.section2TableCellBackgroundColor];
    cell.lblName.font = [UIFont fontWithName:skin.section2TableCellFontName size:[skin.section2TableCellMediumFontSize floatValue]];
    cell.lblName.textColor = [UIColor colorWithHexString:skin.section2TableCellFontColor];

    // setup
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.switchOption.onText = LocalizedString(@"SWITCH_YES", nil);
    cell.switchOption.offText = LocalizedString(@"SWITCH_NO", nil);        
    [cell.switchOption sizeToFit];
    [cell.switchOption addTarget:self action:@selector(saveSwitchSetting:) forControlEvents:UIControlEventValueChanged];
    
    switch ([indexPath row]) {
        case 0:   
            cell.lblName.text = LocalizedString(@"MANDATORY", nil);
            cell.switchOption.on = [theme_.mandatory boolValue];
            cell.switchOption.binding = @"mandatory";
            break;

        case 1:            
            cell.lblName.text = LocalizedString(@"ENHANCE_UNIQUENESS", nil);
            cell.switchOption.on = [theme_.enhanceUniqueness boolValue];
            cell.switchOption.binding = @"enhanceUniqueness";
            break;

        case 2:            
            cell.lblName.text = LocalizedString(@"CREATE_CUSTOMER_VALUE", nil);
            cell.switchOption.on = [theme_.enhanceCustomerValue boolValue];
            cell.switchOption.binding = @"enhanceCustomerValue";
            break;

        default:
            WLog(@"No option defined for row %i", [indexPath row]);
            break;
    }
        
    return cell;    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.titleItem.title = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    theme_.title = self.txtTitle.text;
    [[StratFileManager sharedManager] saveCurrentStratFile]; 
}

- (void)configureResponderChain
{    
    // all of the input fields on this page
    responderChain_ = [[NSArray arrayWithObjects:
                        self.txtTitle,
                        self.tblOptions,
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

#pragma mark - Actions

- (IBAction)done
{    
    [self.delegate editingCompleteForTheme:theme_];
}

- (void)saveSwitchSetting:(MBBindableRoundSwitch*)sender
{
    [theme_ setValue:[NSNumber numberWithBool:sender.isOn] forKey:sender.binding];
    [[StratFileManager sharedManager] saveCurrentStratFile];
}


@end
