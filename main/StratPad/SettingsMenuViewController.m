//
//  SettingsMenuViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "SettingsMenuViewController.h"
#import "DataManager.h"
#import "EventManager.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "PageViewController.h"
#import "CustomUpgradeViewController.h"
#import "LanguageViewController.h"
#import "NSLocale+Expanded.h"
#import "RegistrationViewController.h"
#import "Reachability.h"
#import "UIColor-Expanded.h"
#import "NSUserDefaults+StratPad.h"
#import "RegistrationManager.h"
#import "UIImage+Resize.h"

// identify the lock view and the activity views for easy retrieval
#define tagLock         888
#define tagActivity     777

@interface UIImagePickerController (Settings)

@end

@implementation UIImagePickerController (Settings)

// ios6 looks at the ability of the UI to rotate, in order to match the picker. Since the picker only supports portrait, and StratPad only landscape, we get a crash.
// this prevents the picker from looking for a landscape orientation
-(BOOL)shouldAutorotate{
    return NO;
}

@end

@interface SettingsMenuViewController (Private)
- (BooleanTableViewCell*)booleanCellForIndexPath:(NSIndexPath*)indexPath 
                                           label:(NSString*)label
                                         binding:(NSString*)binding
                                          onText:(NSString*)onText
                                         offText:(NSString*)offText;
- (BooleanTableViewCell*)revenueCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath;
- (TextFieldTableViewCell*)consultantFirmCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath;
- (TextFieldTableViewCell*)currencyCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath;
- (LogoCell*)logoCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath;
@end

@implementation SettingsMenuViewController

@synthesize tableView = tableView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        settings_ = [(Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) sortDescriptorsOrNil:nil predicateOrNil:nil] retain];
        
        // listen for changes to isCalculationOptimistic and currency properties in settings so we can 
        // fire events related to them.
        [settings_ addObserver:self forKeyPath:@"isCalculationOptimistic" options:0 context:nil];
        [settings_ addObserver:self forKeyPath:@"currency" options:0 context:nil];
        
        self.navigationItem.title = LocalizedString(@"MENU_SETTINGS_TITLE", nil);
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isCalculationOptimistic"]) {
        [EventManager fireOptimisticSettingChangeEvent];
        
    } else if ([keyPath isEqualToString:@"currency"]) {
        [EventManager fireCurrencySettingChangeEvent];
        
    }
}

-(void)viewDidLoad
{
    // the first time we show it, don't do any active resizing
    [self resetFirstTimeShowFlag];
    
    // to get correct resizing of the popover as we navigate through a navcontroller, we have to:
    // 1. set the contentSizeForViewInPopover to our viewSize - navBarHeight
    // 2. only after we've shown it once do we begin actively changing the popover size
    // 3. we need to use a little trick (forcePopoverSize) to prompt the popover to resize to the specified size
    // 4. make sure we reset our flag to change the popover size when the view is dismissed (but still resident) - MenuNavController
    // this is a better hack than using the navbar delegate to actively resize the popover (like we do with Chart options)
    // in the MenuNavController, we also set the popover size, but this overrides that
    // not sure exactly what this offset represents; it's roughly the size of the navbar (44pts); empirically determined
    static float offsetHeight = 40.f;
    self.contentSizeForViewInPopover = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-offsetHeight);
    
    // scroll to the correct textfield if necessary
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];	
}

- (void)createTableStructure 
{
    if(menuItems_) {
        [menuItems_ release];
        menuItems_ = nil;
    }
    menuItems_ = [NSMutableArray arrayWithObjects:
                  
                  // identity
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    // registration
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"REGISTRATION", nil), @"text",
                     @"registrationCellWithLabel:atIndexPath:", @"constructor",
                     @"selectRegistrationCell", @"action",
                     nil],
                    // textfield
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"FIRM_NAME", nil), @"text",
                     @"consultantFirmCellWithLabel:atIndexPath:", @"constructor",
                     @"selectFirmCell", @"action",
                     @"textfield", @"type",
                     nil],
                    // slide + pic
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"FIRM_LOGO", nil), @"text",
                     @"logoCellWithLabel:atIndexPath:", @"constructor",
                     @"selectLogoCell", @"action",
                     [NSNumber numberWithFloat:82.f], @"cellHeight",
                     nil],
                    nil], @"rows",
                   LocalizedString(@"CONSULTANTS_SETTINGS", nil), @"sectionTitle",
                   nil],
                  
                  // financial
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:
                    // bool
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"REVENUE_CALCULATION", nil), @"text",
                     @"revenueCellWithLabel:atIndexPath:", @"constructor",
                     // no action
                     nil], 
                    // textfield
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"CURRENCY", nil), @"text",
                     @"currencyCellWithLabel:atIndexPath:", @"constructor",
                     @"textfield", @"type",
                     nil], 
                    nil], @"rows",
                   LocalizedString(@"FINANCIAL_SETTINGS", nil), @"sectionTitle",
                   nil],
                  
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSArray arrayWithObjects:                    
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     LocalizedString(@"LANGUAGE", nil), @"text",
                     @"languageCellWithLabel:atIndexPath:", @"constructor",
                     @"selectLanguageCell", @"action",
                     nil], 
                    nil], @"rows",
                   LocalizedString(@"INTERNATIONAL", nil), @"sectionTitle",
                   nil],
                  
                  nil];
    
    [menuItems_ retain];   
}

-(void)viewDidUnload
{    
    [popoverForImagePicker_ release], popoverForImagePicker_ = nil;
    [tableView_ release], tableView_ = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createTableStructure];
    [tableView_ reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // after the first time we've shown the settings menu, we need to actively resize it to the proper size
    [self forcePopoverSize];
}

- (void) forcePopoverSize {
    // after the first time we've shown the settings menu, we need to actively resize it to the proper size
    if (!firstTimeShow_) {
        CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
        CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
        self.contentSizeForViewInPopover = fakeMomentarySize;
        self.contentSizeForViewInPopover = currentSetSizeForPopover;        
    } else {
        firstTimeShow_ = NO;
    }
}


#pragma mark - Memory Management

- (void)dealloc 
{
    [popoverForImagePicker_ release];
    [tableView_ release];
    [menuItems_ release];	
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [settings_ removeObserver:self forKeyPath:@"isCalculationOptimistic"];
    [settings_ removeObserver:self forKeyPath:@"currency"];
    
    [settings_ release];
    
    [super dealloc];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [menuItems_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[menuItems_ objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[menuItems_ objectAtIndex:section] objectForKey:@"sectionTitle"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    NSArray *sectionItems = [[menuItems_ objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    
    SEL cellConstructor = NSSelectorFromString([rowDict objectForKey:@"constructor"]);
    UITableViewCell *cell = [self performSelector:cellConstructor withObject:[rowDict objectForKey:@"text"] withObject:indexPath];
    return cell;    
}
                  
                  
#pragma mark - Cell Construction

- (TextFieldTableViewCell*)consultantFirmCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{    
    TextFieldTableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"TextFieldTableViewCell"];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TextFieldTableViewCell class]) owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tableView = tableView_;
    cell.indexPath = indexPath;
    cell.textField.enabled = [[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport];

    [cell setBoundEntity:settings_];
    [cell setBoundProperty:@"consultantFirm"];

	[[cell label] setText:label];
    
    // set the consultant firm value from settings
    [[cell textField] setText:[settings_ consultantFirm]];
    [[cell textField] setPlaceholder:LocalizedString(@"PLACEHOLDER_CONSULTANT_FIRM", nil)];
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport]) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }
        
    return cell;
}

- (LogoCell*)logoCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{
    // don't bother caching because a. there is only 1 cell, and b. we need to reload when switching languages
    NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:NSStringFromClass([LogoCell class]) owner:self options:nil];
    LogoCell *cell = [topLevelObjects objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.logoEditor = self;
    
    // company logo
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class])
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    if (settings.consultantLogo) {
        [cell setLogoImage:settings.consultantLogo];
    } else {
        [cell setLogoImage:nil];
    }
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport]) {
        [self addLockToCellView:cell.contentView];
    } else {
        [self removeLockFromCellView:cell.contentView];
    }
    
    return cell;
}

- (BooleanTableViewCell*)revenueCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{
    return [self booleanCellForIndexPath:indexPath
                                   label:label
                                 binding:@"isCalculationOptimistic"
                                  onText:LocalizedString(@"SWITCH_REVENUE_OPTIMISTIC", nil)
                                 offText:LocalizedString(@"SWITCH_REVENUE_PESSIMISTIC", nil)];
}

- (TextFieldTableViewCell*)currencyCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{
    TextFieldTableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"TextFieldTableViewCell"];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TextFieldTableViewCell class]) owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tableView = tableView_;
    cell.indexPath = indexPath;

    [cell setBoundEntity:settings_];
    [cell setBoundProperty:@"currency"];
    [cell setMaxLength:[NSNumber numberWithInt:3]];
    
	[[cell label] setText:label];
    
    // set the currency value from settings
    [[cell textField] setText:[settings_ currency]];
    [[cell textField] setPlaceholder:LocalizedString(@"PLACEHOLDER_CURRENCY", nil)];
                   
    return cell;
}

- (BooleanTableViewCell*)booleanCellForIndexPath:(NSIndexPath*)indexPath 
                                           label:(NSString*)label
                                         binding:(NSString*)binding
                                          onText:(NSString*)onText
                                         offText:(NSString*)offText
{    
    BooleanTableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"BooleanTableViewCell"];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BooleanTableViewCell class]) owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.switchOption.onText = onText;
    cell.switchOption.offText = offText;
    cell.switchOption.binding = binding;
    [cell.switchOption sizeToFit];
    [cell.switchOption addTarget:self action:@selector(saveSwitchSetting:) forControlEvents:UIControlEventValueChanged];
           
    // set the row label from our dict of localized names
	[[cell lblName] setText:label];

    // set the switch value from settings
    BOOL on = [[settings_ valueForKey:binding] boolValue];
    [[cell switchOption] setOn:on];
    
    return cell;
}


- (UITableViewCell*)languageCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"LanguageTableViewCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"LanguageTableViewCell"] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont systemFontOfSize:17]];
    }
    cell.textLabel.text = label;    
    
    NSString *localeIdentifier = [[LocalizedManager sharedManager]localeIdentifier];    
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:localeIdentifier];    
    NSString *language = [locale displayNameForKey:NSLocaleLanguageCode value:localeIdentifier];
    
    // uppercase first letter
    language = [language stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[language substringToIndex:1] capitalizedString]];
    
    // if we also specify the region in the identifier, then look up the country name and append
    if (localeIdentifier.length > 2) {
        language = [language stringByAppendingFormat:@" - %@", [locale displayNameForKeyExpanded:NSLocaleCountryCode value:localeIdentifier]];
    }
    
    [locale release];
    
    cell.detailTextLabel.text = language;
    
    return cell;
}

- (UITableViewCell*)registrationCellWithLabel:(NSString*)label atIndexPath:(NSIndexPath*)indexPath
{
    BOOL isOnline = [[Reachability reachabilityForInternetConnection] isReachable];
    BOOL isRegistered = [[EditionManager sharedManager] isFeatureEnabled:FeatureBackup];
    BOOL needsReminder = [[NSUserDefaults standardUserDefaults] integerForKey:keyRegistrationStatus] == RegistrationStatusSubmitted;
    
    BOOL itemEnabled = isOnline || isRegistered;
    
    // detail text can explain why it is disabled
    // if online, show either thank you or reason to register
    // if offline, show either thank you (and enabled) or offline message
    
    NSString *detailText = isOnline ? LocalizedString(@"REGISTER_TO_UNLOCK_BACKUP", nil) : LocalizedString(@"MSG_OFFLINE", nil);
    detailText = needsReminder ? LocalizedString(@"REGISTER_REMINDER_MENU_ITEM", nil) : detailText;
    detailText = isRegistered ? LocalizedString(@"REGISTER_THANK_YOU", nil) : detailText;
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"RegistrationCell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RegistrationCell"] autorelease];
    }
    
    // font, colour and selectability should match itemEnabled
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = itemEnabled ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = itemEnabled ? [UIColor blackColor] : [UIColor colorWithHexString:@"d0d0d0"];
    
    cell.textLabel.text = label; // registration
    cell.detailTextLabel.text = detailText;
            
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionItems = [[menuItems_ objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];

    NSNumber *height = [rowDict objectForKey:@"cellHeight"];
    return height ? [height floatValue] : 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
    // figure out appropriate data for row
    NSArray *sectionItems = [[menuItems_ objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    
    SEL cellAction = NSSelectorFromString([rowDict objectForKey:@"action"]);
    if (cellAction) {
        [self performSelector:cellAction];
    }    
        
    // nothing is selectable at this point        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    // clicking in the textfield in the cell doesn't notify the table of any selection events
    // iterate each cell, see if it's a textviewcell, see if it's editing, then scroll to it
    // we also do this (earlier) in the textFieldDidBeginEditing: delegate method, which is sometimes too early
    for (uint i=0, ct=[menuItems_ count]; i<ct; ++i) {
        NSArray *rowDicts = [[menuItems_ objectAtIndex:i] objectForKey:@"rows"];
        for (uint j=0, ctj=[rowDicts count]; j<ctj; ++j) {
            NSDictionary *rowDict = [rowDicts objectAtIndex:j];
            if ([@"textfield" isEqualToString:[rowDict objectForKey:@"type"]]) {
                // get the cell and see if it is editing
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                TextFieldTableViewCell *cell = (TextFieldTableViewCell*)[tableView_ cellForRowAtIndexPath:indexPath];
                if ([cell.textField isEditing]) {
                    [tableView_ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];                    
                    return;
                }
            }
        }
    }    
}

#pragma mark - Menu Actions

- (void) saveSwitchSetting:(MBBindableRoundSwitch*)sender
{
    [settings_ setValue:[NSNumber numberWithBool:sender.isOn] forKey:sender.binding];
    [DataManager saveManagedInstances];    
}

- (void)selectFirmCell
{
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport]) {
        
        
        // show upgrade
        RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootViewController dismissAllMenus];
        
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];
    }
}

- (void)selectLogoCell 
{
    RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController dismissAllMenus];
    [popoverForImagePicker_ release], popoverForImagePicker_ = nil;
    
    if ([[EditionManager sharedManager] isFeatureEnabled:FeatureLogoOnReport]) {
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        popoverForImagePicker_ = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popoverForImagePicker_ presentPopoverFromBarButtonItem:rootViewController.settingsItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [imagePicker release];
        
    } else {
        
        // show upgrade
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];        
    }

}


- (void)selectLanguageCell 
{
    LanguageViewController *languageViewController = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:nil];
    [self.navigationController pushViewController:languageViewController animated:YES];
    [languageViewController release];    
}

- (void)selectRegistrationCell
{
    BOOL isOnline = [[Reachability reachabilityForInternetConnection] isReachable];
    BOOL isRegistered = [[EditionManager sharedManager] isFeatureEnabled:FeatureBackup];
    BOOL itemEnabled = isOnline || isRegistered;
    
    if (itemEnabled) {
        RegistrationViewController *vc = [[RegistrationViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    }

}

#pragma mark - LogoEditor

-(void)editLogo
{
    [self selectLogoCell];
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
    UIImage *resizedImage = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                               bounds:CGSizeMake(300, 300) interpolationQuality:kCGInterpolationHigh];
    
    Settings *settings = (Settings*)[DataManager objectForEntity:NSStringFromClass([Settings class]) 
                                            sortDescriptorsOrNil:nil
                                                  predicateOrNil:nil];
    [settings setConsultantLogo:resizedImage];
    [DataManager saveManagedInstances];
    
    [tableView_ reloadData];
        
    RootViewController *rootVC = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootVC.pageViewController reloadCurrentPages];
    
    // get rid of image picker
    [popoverForImagePicker_ dismissPopoverAnimated:YES];
    
    // show the settings again
    [(MenuNavController*)self.navigationController showMenu:rootVC.settingsItem];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
    [popoverForImagePicker_ dismissPopoverAnimated:YES];
}

#pragma mark - Public

-(void)dismissImagePicker
{
    [popoverForImagePicker_ dismissPopoverAnimated:YES];
}

-(void)resetFirstTimeShowFlag
{
    firstTimeShow_ = YES;
}


#pragma mark - override

- (void)reloadLocalizableResources
{
    self.navigationItem.title = LocalizedString(@"MENU_SETTINGS_TITLE", nil);
    [tableView_ reloadData];
}

#pragma mark - Private

-(void)showUpgrade
{
    // show custom upgrade vc
    RootViewController *rootViewController = (RootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
    [upgradeVC showPopoverInView:rootViewController.view];
    [upgradeVC release];
}

-(void)addLockToCellView:(UIView*)contentView
{
    UIView *viewLock = [contentView viewWithTag:tagLock];
    if (!viewLock) {
        UIImage *imgLock = [UIImage imageNamed:@"lock"];
        viewLock = [[UIImageView alloc] initWithImage:imgLock];
        viewLock.alpha = 0.6;
        viewLock.frame = CGRectMake(tableView_.bounds.size.width-imgLock.size.width - 4, 4, imgLock.size.width, imgLock.size.height);
        viewLock.tag = tagLock;
        [contentView addSubview:viewLock];
        [viewLock release];
    }
}

-(void)removeLockFromCellView:(UIView*)contentView
{
    UIView *viewLock = [contentView viewWithTag:tagLock];
    [viewLock removeFromSuperview];
}




@end
