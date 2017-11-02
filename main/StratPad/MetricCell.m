//
//  MetricCell.m
//  StratPad
//
//  Created by Julian Wood on 12-05-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MetricCell.h"
#import "SkinManager.h"
#import "StratFileManager.h"
#import "Objective.h"
#import "Theme.h"
#import "NSDate-StratPad.h"
#import "DataManager.h"
#import "EditionManager.h"

@interface MetricCell (Private)
- (void)saveMetricAndUpdateAutoSuggest;
@end

@implementation MetricCell

@synthesize textFieldSummary;
@synthesize textFieldTargetValue;
@synthesize btnTargetDate;

@synthesize metric;

@synthesize successIndicator;

- (void)dealloc {
    [textFieldTargetValue release];
    [textFieldSummary release];
    [btnTargetDate release];
    [metric release];
    [successIndicator release];
    [super dealloc];
}

-(void)awakeFromNib
{
    SkinManager *skinMan = [SkinManager sharedManager];

    // autosuggest field bound differently
    textFieldSummary.delegate = self;
    
    textFieldTargetValue.delegate = self;
    textFieldTargetValue.property = @"targetValue";
    
    // note that we have origin.x=0 (ie the same as the rounded rect in the cell, because we are not showing the dropdown as a rounded rect, but instead it is inline)
    textFieldSummary.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    self.textFieldSummary.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2TextFieldBackgroundColor forMediaType:MediaTypeScreen];
    
    textFieldTargetValue.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    
    btnTargetDate.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    btnTargetDate.textSize = 14.f;
    btnTargetDate.roundedRectBackgroundColor = [UIColor clearColor];    
    btnTargetDate.nextResponder = nil;
    
    self.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    
    [successIndicator setSelection:metric.successIndicator];
    [successIndicator addTarget:self action:@selector(saveSuccessIndicator:)];
    
    if (!autoSuggestController_) {
        autoSuggestController_ = [[MBAutoSuggestController alloc] initWithAutoSuggestTextField:self.textFieldSummary];
        autoSuggestController_.delegate = self;
    }
    
    if (![[EditionManager sharedManager] isFeatureEnabled:FeatureHasStratBoard]) {
        // hide successindicator and use up width
        successIndicator.hidden = YES;
        CGRect f = textFieldSummary.frame;
        textFieldSummary.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width + successIndicator.bounds.size.width, f.size.height);
    }

    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - AutoSuggestDelegate

- (void)valueSelected:(NSString*)value forAutoSuggestTextField:(MBAutoSuggestTextField *)textField
{
    [self saveMetricAndUpdateAutoSuggest];
}

#pragma mark - Support

- (void)saveMetricAndUpdateAutoSuggest
{
    metric.summary = self.textFieldSummary.text;
    [[StratFileManager sharedManager] saveCurrentStratFile];
    [self updateMetricAutoSuggestValues];
}

- (void)updateMetricAutoSuggestValues
{    
    // grab all metrics for this stratfile, for this objectiveType
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objective.theme.stratFile=%@ && objective.objectiveType=%@ && sumary!=nil", metric.objective.theme.stratFile, metric.objective.objectiveType];
    
    // grab all metrics with a summary as a starting point for autosuggest
    StratFile *stratFile = metric.objective.theme.stratFile;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"summary!=nil", stratFile];
    NSArray *metrics = [DataManager arrayForEntity:NSStringFromClass([Metric class]) 
                              sortDescriptorsOrNil:nil
                                    predicateOrNil:predicate];
        
    NSMutableSet *metricSummaries = [NSMutableSet setWithCapacity:metrics.count];
    for (Metric *m in metrics) {
        [metricSummaries addObject:m.summary];
    }
    
    autoSuggestController_.autoSuggestValues = [metricSummaries sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textFieldSummary) {
        NSString *searchValue = [textField.text stringByReplacingCharactersInRange:range withString:string];    
        [autoSuggestController_ showWithSearchString:searchValue];        
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // save metric and update summary autosuggest
    if (textField == textFieldSummary) {
        [autoSuggestController_ hideAutoSuggest];
        [self saveMetricAndUpdateAutoSuggest];
        [[StratFileManager sharedManager] saveCurrentStratFile];
        [self updateMetricAutoSuggestValues];                
        
    } else if (textField == textFieldTargetValue) {
        [metric setValue:textField.text forKey:textFieldTargetValue.property];
    }
    [[StratFileManager sharedManager] saveCurrentStratFile];            
}

// user pressed return
- (BOOL)textFieldShouldReturn:(PropertyTextField *)textField {
    [textField resignFirstResponder];    
    // don't do the default action (of nothing)
    return NO;
}

#pragma mark - DateSelectionDelegate and associated

- (IBAction)showDatePicker:(id)sender {
    [textFieldSummary resignFirstResponder];
    [textFieldTargetValue resignFirstResponder];
    
    if (!datePicker_) {
        datePicker_ = [[MBDateSelectionViewController alloc] initWithCalendarButton:btnTargetDate andTitle:LocalizedString(@"METRIC_DATE_PICKER_TITLE", nil)];                                    
        datePicker_.delegate = self;        
    }
    [datePicker_ showDatePicker];
}

- (void)dateSelected:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    metric.targetDate = date;
    [[StratFileManager sharedManager] saveCurrentStratFile];    
}

- (BOOL)isValid:(NSDate*)date forCalendarButton:(MBCalendarButton*)button
{
    if (date == nil) {
        return YES;
    }
    
    // as long as the date param falls after the theme start, we're ok - it may not exist though
    if (metric.objective.theme.startDate) {
        return [date isAfterOrEqual:metric.objective.theme.startDate];
    }
    
    return YES;
}

- (NSDate*)suggestedDateForCalendarButton:(MBCalendarButton*)button proposedDate:(NSDate *)proposedDate
{
    // any date within the start and end date of its theme, assuming they exist
    Theme *theme = metric.objective.theme;
    
    if (theme.startDate && theme.endDate) {
        if ([proposedDate inRangeWithStartDate:theme.startDate andEndDate:theme.endDate]) {
            return proposedDate;
        } else {
            if ([proposedDate isAfter:theme.endDate]) {
                return theme.endDate;
            } else {
                return theme.startDate;
            }
        }
    } 
    else if (theme.startDate) {
        if ([proposedDate isAfter:theme.startDate]) {
            return proposedDate;
        } else {
            return [NSDate dateWithTimeInterval:24*60*60 sinceDate:theme.startDate];
        }
    }
    else if (theme.endDate) {
        if ([proposedDate isBefore:theme.endDate]) {
            return proposedDate;
        } else {
            return theme.endDate;
        }
    }
    
    return proposedDate;
}

#pragma mark - SuccessIndicator

- (void)saveSuccessIndicator:(id)value
{    
    [metric setSuccessIndicator:value];
    [[StratFileManager sharedManager] saveCurrentStratFile];
}


@end
