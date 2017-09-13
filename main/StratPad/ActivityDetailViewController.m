//
//  ActivityDetailViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 19, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "StratFileManager.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "NSNumber-StratPad.h"
#import "Theme.h"
#import "Responsible.h"
#import "DataManager.h"
#import "SkinManager.h"
#import "UIColor-Expanded.h"
#import "NSString-Expanded.h"

@interface ActivityDetailViewController ()
@property (nonatomic, retain) Activity *activity;
@property (nonatomic, retain) NSCharacterSet *digitSet;
@end

@implementation ActivityDetailViewController

@synthesize titleItem = titleItem_;
@synthesize fieldsetView = fieldsetView_;
@synthesize lblAction = lblAction_;
@synthesize txtAction = txtAction_;
@synthesize lblStartDate = lblStartDate_;
@synthesize btnStartDate = btnStartDate_;
@synthesize lblEndDate = lblEndDate_;
@synthesize btnEndDate = btnEndDate_;
@synthesize lblResponsible = lblResponsible_;
@synthesize txtResponsible = txtResponsible_;
@synthesize lblUpfrontCost = lblUpfrontCost_;
@synthesize txtUpfrontCost = txtUpfrontCost_;
@synthesize lblOngoingCost = lblOngoingCost_;
@synthesize txtOngoingCost = txtOngoingCost_;
@synthesize lblOngoingFrequency = lblOngoingFrequency_;
@synthesize tblOngoingFrequency = tblOngoingFrequency_;

@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andActivity:(Activity*)activity
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {                
        self.activity = activity;

        // only include ongoing frequencies of monthly, quarterly, and annually...
        NSArray *sortedFrequencies = [Frequency frequenciesSortedByOrder];
        frequencies_ = [[NSMutableArray arrayWithCapacity:3] retain];
        
        FrequencyCategory category;
        for (Frequency *frequency in sortedFrequencies) {
            category = [frequency categoryRaw];
            if (category == FrequencyCategoryMonthly || category == FrequencyCategoryQuarterly || category == FrequencyCategoryAnnually) {
                [frequencies_ addObject:frequency];
            }
        }
        
        self.digitSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-"];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_digitSet release];
    [_activity release];
    [titleItem_ release];
    [fieldsetView_ release];
    [lblAction_ release];
    [txtAction_ release];
    [lblStartDate_ release];
    [btnStartDate_ release];
    [lblEndDate_ release];
    [btnEndDate_ release];
    [lblResponsible_ release];
    [txtResponsible_ release];
    [lblUpfrontCost_ release];
    [txtUpfrontCost_ release];
    [lblOngoingCost_ release];
    [txtOngoingCost_ release];
    [lblOngoingFrequency_ release];
    [tblOngoingFrequency_ release];
        
    [frequencies_ release];
    
    [responsibleController_ release];
    [startDateController_ release];
    [endDateController_ release];
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    SkinManager *skinMan = [SkinManager sharedManager];
    self.view.backgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];

    self.lblAction.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblStartDate.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblEndDate.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblResponsible.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblUpfrontCost.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblOngoingCost.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblOngoingFrequency.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    
    self.txtAction.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.txtAction.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    
    self.btnStartDate.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.btnStartDate.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    self.btnStartDate.enabledBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];    
    
    self.btnEndDate.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.btnEndDate.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    self.btnEndDate.enabledBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];    

    self.txtResponsible.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.txtResponsible.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    
    self.txtUpfrontCost.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.txtUpfrontCost.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    
    self.txtOngoingCost.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.txtOngoingCost.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    
    self.tblOngoingFrequency.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    
    self.titleItem.title = _activity == nil ? self.txtAction.placeholder : _activity.action;

    self.fieldsetView.contentSize = CGSizeMake(self.fieldsetView.frame.size.width, self.fieldsetView.frame.size.height);
    
    if (!responsibleController_) {
        responsibleController_ = [[MBAutoSuggestController alloc] initWithAutoSuggestTextField:self.txtResponsible];
        responsibleController_.delegate = self;
        [self updateResponsibleAutoSuggestValues];
    }

    self.txtAction.text = _activity.action;    
    self.btnStartDate.date = _activity.startDate;
    self.btnEndDate.date = _activity.endDate;
    self.txtResponsible.text = _activity.responsible.summary;
    
    self.txtUpfrontCost.text = [_activity.upfrontCost decimalFormattedNumberWithZeroDisplay:NO];
    self.txtOngoingCost.text = [_activity.ongoingCost decimalFormattedNumberWithZeroDisplay:NO];
    
    // bind
    [self.txtUpfrontCost setBindingWithEntity:_activity andProperty:@"upfrontCost"];
    [self.txtOngoingCost setBindingWithEntity:_activity andProperty:@"ongoingCost"];

    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self.txtAction becomeFirstResponder];
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
    return frequencies_.count; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrequencyCell"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FrequencyCell"] autorelease];        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        SkinManager *skinMan = [SkinManager sharedManager];
        cell.contentView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:[skinMan stringForProperty:kSkinSection2TableCellFontName forMediaType:MediaTypeScreen] 
                                              size:[skinMan fontSizeForProperty:kSkinSection2TableCellLargeFontSize forMediaType:MediaTypeScreen]];
        cell.textLabel.textColor = [skinMan colorForProperty:kSkinSection2TableCellFontColor forMediaType:MediaTypeScreen];            
    }
    
    NSUInteger row = [indexPath row];
    Frequency *frequency = [frequencies_ objectAtIndex:row];
    
    cell.textLabel.text = [frequency nameForCurrentLocale];        
    
    if (_activity.ongoingFrequency == frequency) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;        
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSUInteger row = [indexPath row];
    _activity.ongoingFrequency = [frequencies_ objectAtIndex:row];                
    [[StratFileManager sharedManager] saveCurrentStratFile];

    // mark the selected cell with a checkmark, and ensure none of the others have one.
    NSUInteger section = [indexPath section];
    NSUInteger numRows = [tableView numberOfRowsInSection:section];    
    UITableViewCell *cell = nil;
    for (NSUInteger i = 0; i < numRows; i++) {
        cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        cell.accessoryType = i == row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;        
    }
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtUpfrontCost || textField == self.txtOngoingCost) {
        // remove commas, spaces or any non-digit
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[_digitSet invertedSet]] componentsJoinedByString:@""];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if (textField == self.txtResponsible) {
        NSString *searchValue = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
        [responsibleController_ showWithSearchString:searchValue];
        return YES;
    }
    else if (textField == self.txtAction) {
        return YES;
    }

    // number fields below
    
    // we will allow -99 999 999 or 999 999 999 = 9 chars
    if (textField.text.length == 9 && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
        return [replacementString rangeOfCharacterFromSet:_digitSet].location != NSNotFound;
    }
    else if ([replacementString length] == 0) {
        // just blanking out
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)textFieldDidEndEditing:(MBRoundedTextField *)textField
{
    if (textField == self.txtResponsible) {
        [responsibleController_ hideAutoSuggest];
        [self saveAndUpdateResponsibleField];
        [[StratFileManager sharedManager] saveCurrentStratFile];
        [self updateResponsibleAutoSuggestValues];
        
    } else if (textField == self.txtAction) {
        _activity.action = [self.txtAction.text isBlank] ? nil : [self.txtAction.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[StratFileManager sharedManager] saveCurrentStratFile];            
        
    } else if (textField == self.txtUpfrontCost || textField == self.txtOngoingCost) {
        NSNumber *cost = [textField.text isBlank] ? nil : [NSNumber numberWithInteger:textField.text.integerValue];
        [_activity setValue:cost forKey:textField.boundProperty];
        textField.text = [cost decimalFormattedNumberWithZeroDisplay:NO];
        [stratFileManager_ saveCurrentStratFile];
        
    }
    
}


#pragma mark - AutoSuggestDelegate

- (void)valueSelected:(NSString*)value forAutoSuggestTextField:(MBAutoSuggestTextField *)textField
{
    if (textField == self.txtResponsible) {
        [self saveAndUpdateResponsibleField];
        [[StratFileManager sharedManager] saveCurrentStratFile];
        [self updateResponsibleAutoSuggestValues];        
    }
}


#pragma mark - DateSelectionDelegate
- (void)dateSelected:(NSDate*)date forCalendarButton:(MBCalendarButton *)button
{
    if (button == self.btnStartDate) {        
        _activity.startDate = date;
    } else {
        _activity.endDate = date;        
    }
    [[StratFileManager sharedManager] saveCurrentStratFile];
}

- (BOOL)isValid:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    if (date == nil) {
        return YES;
    }
    
    // if we propose a date, and it comes back as the suggested date, then we know it is valid
    NSDate *suggestedDate = [self suggestedDateForCalendarButton:button proposedDate:date];
    return ([suggestedDate compare:date] == NSOrderedSame);    
}

- (NSDate*)suggestedDateForCalendarButton:(MBCalendarButton*)button proposedDate:(NSDate *)proposedDate
{
    Theme *theme = _activity.objective.theme;        
    NSDate *now = [NSDate date];
    if (button == self.btnStartDate) { 
        
        // suggested date depends on proposedDate (user entered), activity end date (<= theme end date), and theme start date 
        // the final date must be between the theme start (inclusive) and end date (exclusive)
        // must also be less than or equal to the activity end date
        // we assume if endDate exists, it must be valid

        NSDate *minStartDate = [theme normalizedStartDate];
        NSDate *themeEndDate = [theme normalizedEndDate];
        NSDate *maxStartDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:(_activity.endDate ? _activity.endDate : themeEndDate)];
//        NSDate *maxStartDate = _activity.endDate ? _activity.endDate : themeEndDate;
        
        if (!proposedDate) {
            proposedDate = now;
        }
        
        // make sure it falls within the valid period
        if ([proposedDate compare:minStartDate] != NSOrderedAscending && 
            [proposedDate compare:maxStartDate] != NSOrderedDescending) 
        {
            // proposed date >= min && <= max
            return proposedDate;
        } else if ([proposedDate compare:minStartDate] == NSOrderedAscending) {
            return minStartDate;
        } else {
            return maxStartDate;
        }
        
    } else {
        
        NSDate *minEndDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:(_activity.startDate ? _activity.startDate : [theme normalizedStartDate])]; 
//        NSDate *minEndDate = _activity.startDate ? _activity.startDate : [theme normalizedStartDate]; 
        NSDate *maxEndDate = [theme normalizedEndDate];
        
        if (!proposedDate) {
            proposedDate = now;
        }

        // make sure it falls within the valid period
        if ([proposedDate compare:minEndDate] != NSOrderedAscending && 
            [proposedDate compare:maxEndDate] != NSOrderedDescending) 
        {
            // proposed date >= min && <= max
            return proposedDate;
        } else if ([proposedDate compare:minEndDate] == NSOrderedAscending) {
            return minEndDate;
        } else {
            return maxEndDate;
        }        
    }
}


#pragma mark - Actions

- (IBAction)showDatePicker:(id)sender
{    
    if ([self.txtAction isFirstResponder]) {
        [self.txtAction resignFirstResponder];
        
    } else if ([self.txtResponsible isFirstResponder]) {
        [self.txtResponsible resignFirstResponder];
        
    } else if ([self.txtUpfrontCost isFirstResponder]) {
        [self.txtUpfrontCost resignFirstResponder];
        
    } else if ([self.txtOngoingCost isFirstResponder]) {
        [self.txtOngoingCost resignFirstResponder];
    }    
    
    MBCalendarButton *button = (MBCalendarButton*)sender;
    
    if (button == self.btnStartDate) {
        if (!startDateController_) {
            startDateController_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:button
                                    andTitle:lblStartDate_.text];                                    
            startDateController_.delegate = self;
        } 
        [startDateController_ showDatePicker];
        
    } else if (button == self.btnEndDate) {
        if (!endDateController_) {
            endDateController_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:button
                                  andTitle:lblEndDate_.text];                                    
            endDateController_.delegate = self;        
        }
        [endDateController_ showDatePicker];
    }
}

- (IBAction)done
{
    [self.delegate editingCompleteForActivity:_activity];
}


#pragma mark - Support

- (void)configureResponderChain
{    
    // all of the input fields on this page
    responderChain_ = [[NSArray arrayWithObjects:
                        self.txtAction,
                        self.btnStartDate,
                        self.btnEndDate,
                        self.txtResponsible,
                        self.txtUpfrontCost,
                        self.txtOngoingCost,
                        self.tblOngoingFrequency,
                        nil] retain];
    
    // all text fields (ie keyboard up) use next button in KB
    for (int i=0, ct = [responderChain_ count]; i<ct; ++i) {
        UIResponder *responder = [responderChain_ objectAtIndex:i];
        if ([responder isKindOfClass:[UITextField class]]) {
            // if a textfield is last, it can use done button in KB, which will dismiss the keyboard
            [(UITextField*)responder setReturnKeyType:(i == ct-1) ? UIReturnKeyDone : UIReturnKeyNext];
        }            
    }
    
    // set up the date field with it's nextResponder and dateSelection properties
    self.btnStartDate.nextResponder = self.btnEndDate;
    self.btnStartDate.delegate = self;
    self.btnStartDate.titleForDateSelectionPopover = lblStartDate_.text;
    
    self.btnEndDate.nextResponder = self.txtResponsible;
    self.btnEndDate.delegate = self;
    self.btnEndDate.titleForDateSelectionPopover = lblEndDate_.text;
}

- (void)saveAndUpdateResponsibleField
{
    // check to see if a responsible entity already exists for this Strat File.
    Responsible *selectedResponsible = nil;
    NSArray *responsibles = [stratFileManager_.currentStratFile.responsibles allObjects];    
    for (Responsible *responsible in responsibles) {
        if ([responsible.summary isEqualToString:self.txtResponsible.text]) {
            selectedResponsible = responsible;
        }
    }
    
    if (!selectedResponsible) {
        // no matching responsible, so see if we should create one...
        NSString *responsibleText = self.txtResponsible.text;
        if (responsibleText && ![responsibleText isBlank]) {
            selectedResponsible = (Responsible*)[DataManager createManagedInstance:NSStringFromClass([Responsible class])];
            selectedResponsible.summary = responsibleText;
            selectedResponsible.stratFile = stratFileManager_.currentStratFile;            
        }
    }    
    
    _activity.responsible = selectedResponsible;
    [stratFileManager_ saveCurrentStratFile];
    
    [self updateResponsibleAutoSuggestValues];
}

- (void)updateResponsibleAutoSuggestValues
{
    NSArray *responsibles = [stratFileManager_.currentStratFile.responsibles allObjects];
    NSMutableArray *responsibleSummaries = [NSMutableArray arrayWithCapacity:responsibles.count];
    
    for (Responsible *responsible in responsibles) {
        [responsibleSummaries addObject:responsible.summary];
    }    
    
    responsibleController_.autoSuggestValues = responsibleSummaries;    
}

@end
