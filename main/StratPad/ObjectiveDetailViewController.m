//
//  ObjectiveDetailViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  This is the detail view for F6

#import "ObjectiveDetailViewController.h"
#import "Frequency.h"
#import "Theme.h"
#import "ObjectiveType.h"
#import "StratFileManager.h"
#import "NSString-Expanded.h"
#import "DataManager.h"
#import "NSDate-StratPad.h"
#import "MBCalendarButton.h"
#import "Metric.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"
#import "MetricCell.h"
#import "EditionManager.h"

@interface ObjectiveDetailViewController (Private)
- (void)updateDescriptionAutoSuggestValues;
@end

@implementation ObjectiveDetailViewController

@synthesize dropDownFrequency;
@synthesize dropDownObjective;
@synthesize titleItem = titleItem_;
@synthesize fieldsetView = fieldsetView_;
@synthesize txtDescription = txtDescription_;

@synthesize tblMetrics;
@synthesize btnManage;
@synthesize btnAddMetric;
@synthesize roundedRectView;


@synthesize delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andObjective:(Objective*)objective
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {                
        objective_ = [objective retain];
        skinMan_ = [SkinManager sharedManager];

        frequencies_ = [[NSArray arrayWithObjects: 
                         [Frequency frequencyForCategory:FrequencyCategoryWeekly],
                         [Frequency frequencyForCategory:FrequencyCategoryMonthly],
                         [Frequency frequencyForCategory:FrequencyCategoryQuarterly],
                         [Frequency frequencyForCategory:FrequencyCategoryAnnually],
                         nil] retain];
        
        objectiveTypes_ = [[NSArray arrayWithObjects:
                            [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial], 
                            [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCustomer], 
                            [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess], 
                            [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryStaff],
                            nil] retain]; 
        NSArray *metrics = [objective_.metrics sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"targetDate" ascending:NO]]];
        metrics_ = [[NSMutableArray array] retain];
        [metrics_ addObjectsFromArray:metrics];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];	

    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [objective_ release];
    
    [titleItem_ release];
    [fieldsetView_ release];
    [txtDescription_ release];
    
    [frequencies_ release];
    [objectiveTypes_ release];
    [metrics_ release];
    
    [descriptionController_ release];
    [metricController_ release];
    
    [tblMetrics release];
    [dropDownFrequency release];
    [dropDownObjective release];
    [frequencyDropDownController_ release];
    [objectiveTypeDropDownController_ release];
    
    [btnManage release];
    [btnAddMetric release];
    [roundedRectView release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if (!descriptionController_) {
        descriptionController_ = [[MBAutoSuggestController alloc] initWithAutoSuggestTextField:self.txtDescription];
        descriptionController_.delegate = self;
        [self updateDescriptionAutoSuggestValues];
    }
        
    self.view.backgroundColor = [skinMan_ colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];
    self.roundedRectView.roundedRectBackgroundColor = [skinMan_ colorForProperty:kSkinSection2FormSubtableBackgroundColor forMediaType:MediaTypeScreen];
  
    // skin the labels
    for (UIView *subview in [fieldsetView_ subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setTextColor:[skinMan_ colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen]];
        }
    }
    
    // frequency drop down
    self.dropDownFrequency.roundedRectBackgroundColor = [skinMan_ colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    self.dropDownFrequency.label.textColor = [skinMan_ colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];

    if (!frequencyDropDownController_) {
        frequencyDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.dropDownFrequency andSelectedValueOrNil:objective_.reviewFrequency];
        frequencyDropDownController_.delegate = self;        

        // load values
        for (Frequency *frequency in frequencies_) {
            [frequencyDropDownController_ addDropDownValue:frequency withDisplayValue:frequency.nameForCurrentLocale];
        }
    }
    dropDownFrequency.label.text = objective_.reviewFrequency.nameForCurrentLocale;

    // objective drop down
    self.dropDownObjective.roundedRectBackgroundColor = [skinMan_ colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    self.dropDownObjective.label.textColor = [skinMan_ colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];

    if (!objectiveTypeDropDownController_) {
        objectiveTypeDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.dropDownObjective andSelectedValueOrNil:objective_.objectiveType];
        objectiveTypeDropDownController_.delegate = self;        
        
        // load values
        for (ObjectiveType *objectiveType in objectiveTypes_) {
            [objectiveTypeDropDownController_ addDropDownValue:objectiveType withDisplayValue:objectiveType.nameForCurrentLocale];
        }
    }
    dropDownObjective.label.text = objective_.objectiveType.nameForCurrentLocale;
    
    // other fields
    self.txtDescription.textColor = [skinMan_ colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.txtDescription.roundedRectBackgroundColor = [skinMan_ colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
        
    self.tblMetrics.backgroundColor = [UIColor clearColor];
    self.tblMetrics.separatorColor = [UIColor clearColor];
    
    // grab the tableHeaderView out of the nib
    static NSString *CellIdentifier = @"MetricCell";    
    NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    UIView *headerView = [topLevelObjects objectAtIndex:1];
    headerView.backgroundColor = [UIColor clearColor];
    
    // skin the detail table header colours
    for (UIView *subview in [headerView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setTextColor:[skinMan_ colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen]];
        }
    }
    
    // turn off success if no stratboard
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard]) {
        [[headerView viewWithTag:1] setHidden:YES];
    }
    
    self.tblMetrics.tableHeaderView = [topLevelObjects objectAtIndex:1];

    
    // the title of the popup "window"
    self.titleItem.title = objective_.summary;
    
    // initial size; NB. we need to shrink it in order to get scrolling when the KB is up
    self.fieldsetView.contentSize = CGSizeMake(self.fieldsetView.frame.size.width, self.fieldsetView.frame.size.height);
    
    self.txtDescription.text = objective_.summary;
            
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [frequencyDropDownController_ release], frequencyDropDownController_ = nil;    
    [objectiveTypeDropDownController_ release], objectiveTypeDropDownController_ = nil;    

    [self setTblMetrics:nil];
    [self setDropDownFrequency:nil];
    [self setDropDownObjective:nil];
    [self setBtnManage:nil];
    [self setBtnAddMetric:nil];
    [self setRoundedRectView:nil];
    [super viewDidUnload];
    self.titleItem = nil;
    self.fieldsetView = nil;
    self.txtDescription = nil;
        
    [descriptionController_ release], descriptionController_ = nil;
    [metricController_ release], metricController_ = nil;
}

- (void)viewDidAppear:(BOOL)animated
{    
//    [self.txtDescription becomeFirstResponder];
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
    return [objective_.metrics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{       
    static NSString *CellIdentifier = @"MetricCell";    
    MetricCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Metric *metric = [metrics_ objectAtIndex:[indexPath row]];
    cell.metric = metric;
    cell.textFieldSummary.text = metric.summary;
    cell.textFieldTargetValue.text = metric.targetValue;
    cell.btnTargetDate.date = metric.targetDate;
    cell.successIndicator.selection = metric.successIndicator;
    
    // might want to think about doing this once per table, rather than once per cell
    [cell updateMetricAutoSuggestValues];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {                
        Metric *metric = [metrics_ objectAtIndex:[indexPath row]];
        [metrics_ removeObjectAtIndex:[indexPath row]];
        [DataManager deleteManagedInstance:metric];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationRight];                    
    }    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row > 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtDescription) {
        NSString *searchValue = [textField.text stringByReplacingCharactersInRange:range withString:string];    
        [descriptionController_ showWithSearchString:searchValue];
        self.titleItem.title = searchValue;
        
    } 
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.txtDescription) {
        [descriptionController_ hideAutoSuggest];
        objective_.summary = self.txtDescription.text;
        [[StratFileManager sharedManager] saveCurrentStratFile];
        [self updateDescriptionAutoSuggestValues];        
        
    } 
}

- (void)configureResponderChain
{    
    // all of the input fields on this page
    responderChain_ = [[NSArray arrayWithObjects:
                        self.txtDescription,
                        self.dropDownFrequency,
                        self.dropDownObjective,
                        self.tblMetrics,
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


#pragma mark - AutoSuggestDelegate

- (void)valueSelected:(NSString*)value forAutoSuggestTextField:(MBAutoSuggestTextField *)textField
{
    if (textField == self.txtDescription) {
        self.titleItem.title = self.txtDescription.text;
        objective_.summary = self.txtDescription.text;
        [[StratFileManager sharedManager] saveCurrentStratFile];
        [self updateDescriptionAutoSuggestValues];   
        
    }
}


#pragma mark - Actions

- (IBAction)done
{
    [self.delegate editingCompleteForObjective:objective_];
}

- (IBAction)addMetric:(id)sender {
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    [objective_ addMetricsObject:metric];
    [[StratFileManager sharedManager] saveCurrentStratFile];

    [metrics_ insertObject:metric atIndex:0];
        
    [tblMetrics insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

- (IBAction)manageMetrics:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    
    // want to stop editing textfield too
    NSArray *visibleCellPaths = [tblMetrics indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleCellPaths) {
        MetricCell *cell = (MetricCell*)[tblMetrics cellForRowAtIndexPath:indexPath];
        if ([cell.textFieldSummary isEditing] || [cell.textFieldTargetValue isEditing]) {
            [cell.textFieldSummary endEditing:NO];
            [cell.textFieldTargetValue endEditing:NO];
            break;
        }        
    }
    
    if (tblMetrics.editing) {
        // switch off editing mode.
        [button setTitle:LocalizedString(@"MANAGE", nil)];
        [tblMetrics setEditing:NO animated:YES];        
    } else {
        [button setTitle:LocalizedString(@"DONE", nil)];
        [tblMetrics setEditing:YES animated:YES];        
    }

}




#pragma mark - Support

- (void)updateDescriptionAutoSuggestValues
{
    NSMutableArray *descriptions = [NSMutableArray array];
    
    if (self.txtDescription.text && ![self.txtDescription.text isBlank]) {
        [descriptions addObject:self.txtDescription.text];
    }

    NSArray *themes = [[StratFileManager sharedManager].currentStratFile themesSortedByOrder];
    for (Theme *theme in themes) {
        for (Objective *objective in theme.objectives) {
            if (objective.summary && ![objective.summary isBlank] && ![descriptions containsObject:objective.summary]) {
                [descriptions addObject:objective.summary];
            }
        }
    }
    descriptionController_.autoSuggestValues = descriptions;
}

#pragma mark - DropDownDelegate

- (void)valueSelected:(id)value forDropDownButton:(MBDropDownButton *)button
{
    if (button == dropDownFrequency) {
        objective_.reviewFrequency = value;
    } 
    else if (button == dropDownObjective) {
        objective_.objectiveType = value;
    }
    
    [[StratFileManager sharedManager] saveCurrentStratFile];
}

#pragma mark - Notifications

- (void)didShowKeyboard:(NSNotification*)notification
{
    for (int i=0, ct=[metrics_ count]; i<ct; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MetricCell *cell = (MetricCell*)[tblMetrics cellForRowAtIndexPath:indexPath];
        if ([cell.textFieldSummary isEditing] || [cell.textFieldTargetValue isEditing]) {
            [tblMetrics scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            CGRect rect = [tblMetrics rectForRowAtIndexPath:indexPath];
            rect = [fieldsetView_ convertRect:rect fromView:tblMetrics];
            [fieldsetView_ scrollRectToVisible:rect animated:YES];
            return;
        }        
    }
}



@end
