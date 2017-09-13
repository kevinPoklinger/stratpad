//
//  LanguageViewController.m
//  StratPad
//
//  Created by Vitaliy Nevgadaylov on 12.07.12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "LanguageViewController.h"
#import "NSLocale+Expanded.h"
#import "AppDelegate.h"


@interface LanguageViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *btnQuitNow;
@end


@implementation LanguageViewController
@synthesize tableView = tableView_;
@synthesize btnQuitNow;


- (void)dealloc
{
    [tableView_ release];
    [btnQuitNow release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LocalizedString(@"LANGUAGE", nil);
    
    languages_ = [[LocalizedManager sharedManager] supportedLanguages];
    
    // there is a view on top of the clear background, so let the view color show through
    tableView_.backgroundView = nil;

    UILabel *lblFooter = [[UILabel alloc] init];
    lblFooter.font = [UIFont boldSystemFontOfSize:15.f];
    lblFooter.backgroundColor = [UIColor clearColor];
    lblFooter.textColor = [UIColor darkGrayColor];
    lblFooter.numberOfLines = 0;
    lblFooter.lineBreakMode = UILineBreakModeTailTruncation;
    lblFooter.text = LocalizedString(@"RESTART_STRATPAD", nil);
    lblFooter.textAlignment = UITextAlignmentCenter;
    
    CGSize size = [lblFooter.text sizeWithFont:[UIFont boldSystemFontOfSize:15.f]
                             constrainedToSize:CGSizeMake(tableView_.bounds.size.width, 100)
                                 lineBreakMode:UILineBreakModeTailTruncation];
    
    lblFooter.frame = CGRectMake(0, 0, tableView_.bounds.size.width, size.height);
    tableView_.tableFooterView = lblFooter;
    [lblFooter release];
    
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnQuitNow setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnQuitNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnQuitNow setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnQuitNow.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnQuitNow.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    [btnQuitNow setTitle:LocalizedString(@"QUIT_NOW_BTN", nil) forState:UIControlStateNormal];
    
    [super viewDidLoad];
}



- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setBtnQuitNow:nil];
    [super viewDidUnload];
}


-(void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.contentSizeForViewInPopover = CGSizeMake(self.view.frame.size.width, 400);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark tableView dataSources

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    return [languages_ count];
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
    NSString *localeIdentifier = [languages_ objectAtIndex:indexPath.row];    
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


#pragma mark tableView delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];   
    for (UITableViewCell *cell in [tableView visibleCells]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];    
    
    NSString *localeIdentifier = [languages_ objectAtIndex:indexPath.row];     
    [[LocalizedManager sharedManager]setLocaleIdentifier:localeIdentifier];
}


- (void)reloadLocalizableResources {
    
    [super reloadLocalizableResources];
    self.title = LocalizedString(@"LANGUAGE", nil);
}

#pragma mark - actions

- (IBAction)quitNow {
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
        AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
        [appDelegate applicationWillTerminate:[UIApplication sharedApplication]];
        
        exit(0);
    }
}

@end
