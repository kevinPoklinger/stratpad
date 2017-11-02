//
//  RegisterWelcomeViewController.m
//  StratPad
//
//  Created by Julian Wood on 2012-10-18.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "RegisterWelcomeViewController.h"
#import "AppDelegate.h"
#import "RegisterOrSkipViewController.h"
#import "NSLocale+Expanded.h"
#import "UserNotificationDisplayManager.h"
#import "NSUserDefaults+StratPad.h"
#import "StratFileManager.h"
#import "DataManager.h"

@interface RegisterWelcomeViewController () {
    @private
    UIPopoverController *popoverController_;
}

@property (retain, nonatomic) IBOutlet UITableView *tblLanguages;
@property (retain, nonatomic) IBOutlet UIButton *btnRestartNow;
@property (retain, nonatomic) IBOutlet UIButton *btnNext;

@property (nonatomic, retain) NSArray *languages;

- (IBAction)restartStratPad;
- (IBAction)nextPage:(id)sender;

@end

@implementation RegisterWelcomeViewController


#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LocalizedString(@"REGISTER_WELCOME", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.languages = [[LocalizedManager sharedManager] supportedLanguages];
    
    // transparent table background
    self.tblLanguages.backgroundColor = [UIColor clearColor];
    self.tblLanguages.opaque = NO;
    self.tblLanguages.backgroundView = nil;
    
    // shift the content up inside the tables frame (which is being stretched vertically by constraints)
    UIEdgeInsets inset = UIEdgeInsetsMake(-15, 0, 0, 0);
    self.tblLanguages.contentInset = inset;
    
    UIImage *btnNextImg = [[UIImage imageNamed:@"btn-large-green-modern"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [_btnNext setBackgroundImage:btnNextImg forState:UIControlStateNormal];
    [_btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnNext setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_btnNext.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnNext.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];

    UIImage *btnRestartImg = [[UIImage imageNamed:@"btn-large-blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [_btnRestartNow setBackgroundImage:btnRestartImg forState:UIControlStateNormal];
    [_btnRestartNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRestartNow setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_btnRestartNow.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnRestartNow.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];

    // keep restart hidden until language is changed
    _btnRestartNow.alpha = 0;
    
    self.preferredContentSize = CGSizeMake(850, 650);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [popoverController_ release];
    [_languages release];
    [_tblLanguages release];
    [_btnRestartNow release];
    [_btnNext release];
    [super dealloc];
}

-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(850, 650);
}

#pragma mark - Actions

- (IBAction)restartStratPad
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"RESTART_STRATPAD_TITLE", nil)
                                                    message:LocalizedString(@"RESTART_STRATPAD_MESSAGE", nil)
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"CANCEL", nil)
                                          otherButtonTitles:LocalizedString(@"RESTART_STRATPAD_BUTTON", nil), nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // restart pressed
        
        // in this one place, we want to make sure you get the sample files for your chosen language
        // sample files have a UUID now
        
        NSDictionary *sampleUUIDs = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSArray arrayWithObjects:@"D9B2E928-8889-4D49-964E-33C6470D5ED5", @"C1E16579-3677-4739-9ADF-43E10CD47FCB", @"5DB99E48-58F9-44F2-84BC-827272D7E2F9", nil], @"en", // SMB, 2012, Get to Market
                                     [NSArray arrayWithObjects:@"EFBC8DEA-2F79-4766-9D9C-6BC340EFBC8D", @"B22F1891-C5B4-40F2-A36B-858FCB431B59", @"0DB37052-5C4F-48D3-A5D9-40439FC28CFB", nil], @"es",
                                     [NSArray arrayWithObjects:@"41525C1E-484E-4A20-AE78-FED050EFE609", @"8D67D40A-8244-4D58-AD42-D6D2A5181709", @"9C8D51F4-27B9-4C11-8F7A-F6D5996EAF91", nil], @"es-MX",
                                     nil];
        NSMutableArray *sampleFilenames = [NSMutableArray arrayWithObjects:@"SMB Market Focus", @"2012_2013 Expansion Strategy",  @"Get to Market!", nil];


        // just add them if necessary
        // use case is it starts up in english, but then you choose spanish
        NSString *localeIdentifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSArray *uuids = [sampleUUIDs objectForKey:localeIdentifier];
        
        for (int i=0; i<uuids.count;++i) {
            NSString *uuid = [uuids objectAtIndex:i];
            
            // see if stratfile exists
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid=%@", uuid];
            StratFile *stratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                                       sortDescriptorsOrNil:nil
                                                             predicateOrNil:predicate];
            if (!stratFile) {
                NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:localeIdentifier ofType:@"lproj"]];
                
                NSString *filename = [sampleFilenames objectAtIndex:i];
                NSString *path = [bundle pathForResource:filename ofType:@"xml"];
                
                // this places the stratfile into the db
                StratFile *stratFile = [[StratFileManager sharedManager] stratFileFromXmlAtPath:path];
                stratFile.permissions = @"0400";

                [DataManager saveManagedInstances];
            }
        }

        // we want to make sure that you see the second dialog (the form) when you restart, so reset
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:keyLastShownDate];
        
        AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
        [appDelegate applicationWillTerminate:[UIApplication sharedApplication]];
        
        exit(0);
    }
}

- (IBAction)nextPage:(id)sender
{
    RegisterOrSkipViewController *registerOrSkipVC = [[RegisterOrSkipViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:registerOrSkipVC animated:YES];
    [registerOrSkipVC release];
}

#pragma mark - UITableView delegate and datasource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_languages count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString *localeIdentifier = [_languages objectAtIndex:indexPath.row];
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:localeIdentifier];
    NSString *language = [locale displayNameForKey:NSLocaleLanguageCode value:localeIdentifier];
    // uppercase first letter
    language = [language stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[language substringToIndex:1] capitalizedString]];
    
    // if we also specify the region in the identifier, then look up the country name and append
    if (localeIdentifier.length > 2) {
        language = [language stringByAppendingFormat:@" - %@", [locale displayNameForKeyExpanded:NSLocaleCountryCode value:localeIdentifier]];
    }
    
    [locale release];
    
    cell.textLabel.text =language;
    
    if([localeIdentifier isEqualToString:[[LocalizedManager sharedManager] localeIdentifier]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (UITableViewCell *cell in [tableView visibleCells]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSString *localeIdentifier = [_languages objectAtIndex:indexPath.row];
    [[LocalizedManager sharedManager]setLocaleIdentifier:localeIdentifier];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _btnRestartNow.alpha = 1.f;
                     }];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"REGISTER_ANYTIME", nil)];
    
    [popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - Public

- (void)showPopoverInView:(UIView*)view
{
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.modalInPopover = YES;
    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController];
    [navController release];
    
    popoverController_.delegate = self;
    [popoverController_ presentPopoverFromRect:view.bounds
                                        inView:view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];
}


- (void)dismissPopover
{
    [popoverController_ dismissPopoverAnimated:YES];
	[popoverController_ release];
	popoverController_ = nil;
}


@end
