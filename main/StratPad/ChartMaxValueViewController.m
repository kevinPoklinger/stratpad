//
//  ChartMaxValueViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-06-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
// allow free form text entry
// we should restrict to digits - no commas, decimals or negatives
// 15 digits
// adjust the minimum to >= max value
// note the target value as well
// note the overlay max and target too
// area to flash mistakes
// area for instructions
// done on kb will invoke the change


#import "ChartMaxValueViewController.h"
#import "Measurement.h"
#import "DataManager.h"
#import "Metric.h"
#import "StratFileManager.h"

@interface ChartMaxValueViewController ()

@end

@implementation ChartMaxValueViewController
@synthesize scrollView;
@synthesize fldMaxValue;
@synthesize lblMaxMeasuredValue;
@synthesize lblMaxTargetValue;

- (id)initWithChart:(Chart*)chart andChartMaxValueChooser:(id<ChartMaxValueChooser>)chartMaxValueChooser
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        chart_ = chart;
        chartMaxValueChooser_ = chartMaxValueChooser;
        self.title = LocalizedString(@"CHART_MAX_VALUE", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(chart_ != nil, @"You have to provide a valid chart object in the init.");
    NSAssert(chartMaxValueChooser_ != nil, @"You have to provide a valid ChartMaxValue chooser object in the init.");
    
    UIViewController *vc = [[self.navigationController viewControllers] objectAtIndex:0];
    scrollView.contentSize = vc.view.bounds.size;
    
    fldMaxValue.delegate = self;
    fldMaxValue.actions = EditActionCopy | EditActionDelete | EditActionSelect | EditActionSelectAll;
    fldMaxValue.placeholder = [[chart_ yAxisMaxFromChartOrMeasurement] stringValue];


    // get max measurement for chart; overlays are taken care of on the other y-axis
    Measurement *m1 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
                                            sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO]] 
                                                  predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", chart_.metric]];
    NSNumber *maxVal = m1.value;
    
//    if (chart_.shouldDrawOverlay) {
//        Chart *overlay = [Chart chartWithUUID:chart_.overlay];
//        Measurement *m2 = (Measurement*)[DataManager objectForEntity:NSStringFromClass([Measurement class]) 
//                                                sortDescriptorsOrNil:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO]] 
//                                                      predicateOrNil:[NSPredicate predicateWithFormat:@"metric = %@", overlay.metric]];
//        if ([m2.value compare:maxVal] == NSOrderedDescending) {
//            maxVal = m2.value;
//        }        
//    }
    lblMaxMeasuredValue.text = maxVal.stringValue;
    
    // get max target value for chart    
    NSNumber *maxTarget = [NSNumber numberWithInt:0];
    if ([chart_.metric isNumeric]) {
        maxTarget = [chart_.metric parseNumberFromTargetValue];
    }
    
//    if (chart_.shouldDrawOverlay) {
//        Chart *overlay = [Chart chartWithUUID:chart_.overlay];
//        NSNumber *target = [overlay.metric parseNumberFromTargetValue];
//        if ([target compare:maxTarget] == NSOrderedDescending) {
//            maxTarget = target;
//        }        
//    }
    lblMaxTargetValue.text = maxTarget.stringValue;
    
    // finally set the actual max value
    NSNumber *yMax = [chart_ yAxisMaxFromChartOrMeasurement];
    fldMaxValue.text = yMax.stringValue;
}

- (void)viewDidUnload
{
    [self setFldMaxValue:nil];
    [self setLblMaxMeasuredValue:nil];
    [self setLblMaxTargetValue:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+40);
}


- (void)dealloc {
    [fldMaxValue release];
    [lblMaxMeasuredValue release];
    [lblMaxTargetValue release];
    [scrollView release];
    [super dealloc];
}

#pragma mark - UITextFieldDelegate

// user pressed return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // done key - dismiss keyboard
    [textField resignFirstResponder];
    
    // don't do the default action (of nothing)
    return NO;
}

- (void)textFieldDidEndEditing:(PropertyTextField *)textField
{
    CGFloat yMax;

    if (textField.text && ![textField.text isEqualToString:@""]) {
        yMax = textField.text.floatValue;
        
        CGFloat yMaxCalc = [chart_ yAxisMaxFromMeasurements];
        if (yMax < yMaxCalc) {
            
            // if less than calculated value, then we need to use that instead and nil out the saved value in chart
            [chart_ setYAxisMax:nil];
            [textField setText:[[chart_ yAxisMaxFromChartOrMeasurement] stringValue]];
            
        } else {
            
            // otherwise use the user-entered value and save
            [chart_ setYAxisMax:[NSNumber numberWithInt:textField.text.intValue]];    
            
        }
    } else {

        // just use calculated value
        [chart_ setYAxisMax:nil];
        [textField setText:[[chart_ yAxisMaxFromChartOrMeasurement] stringValue]];
        
    }
    
    // save and redraw
    [[StratFileManager sharedManager] saveCurrentStratFile];
    [chartMaxValueChooser_ maxValueEntered];
}

- (BOOL)textField:(PropertyTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{           
    // max is 12345678901 or 9,999,999,999
    if (textField.text.length > 11 && [replacementString length] > 0) {
        return NO;
    }
    else if ([replacementString length] == 1) {
        // as long as replacementString (what the user typed) contains valid chars, return yes
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        return [replacementString rangeOfCharacterFromSet:set].location != NSNotFound;
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



@end
