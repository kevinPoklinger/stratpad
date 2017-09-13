//
//  YearMonthInputViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "YearMonthInputViewController.h"
#import "NSCalendar+Expanded.h"
#import "NSDate-StratPad.h"

@interface YearMonthInputViewController ()
@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBtnItemTitle;

@end

@implementation YearMonthInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // update title
    [_barBtnItemTitle setTitle:self.desc];
    
    [_barBtnItemTitle setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:16] forKey:UITextAttributeFont]
                                    forState:UIControlStateNormal];

    // init the pickers
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_desc release];
    [_pickerView release];
    [_barBtnItemTitle release];
    [super dealloc];
}

#pragma mark - Private

- (void)reloadData
{
    NSString *yyyymm = self.value.stringValue;
    NSString *mm, *yy;
    if ( !(yyyymm && yyyymm.length == 6) ) {
        // use the current date
        NSDateComponents *comps = [[NSCalendar cachedGregorianCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit
                                                                          fromDate:[NSDate date]];

        mm = [NSString stringWithFormat:@"%02d", comps.month];
        yy = [[NSString stringWithFormat:@"%d", comps.year] substringFromIndex:2];
    }
    else {
        mm = [yyyymm substringWithRange:NSMakeRange(4, 2)];
        yy = [yyyymm substringWithRange:NSMakeRange(2, 2)];
    }
    
    int mIdx = MAX(mm.intValue-1, 0);
    [_pickerView selectRow:mIdx inComponent:0 animated:YES];
    
    int yyyy = yy.intValue < 70 ? yy.intValue+2000 : yy.intValue+1900;
    int yIdx = yyyy - 1970;
    [_pickerView selectRow:yIdx inComponent:1 animated:YES];
    
    // fire an event so that we update our model and the associated text field, esp for case where date was initially nil
    [self pickerView:_pickerView didSelectRow:yIdx inComponent:1];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        // month
        return 12;
    }
    else {
        // year
        NSDateComponents *comps = [[NSCalendar cachedGregorianCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
        int year = [comps year];
        int minYear = 1970;
        int maxYear = year + 50;
        return maxYear - minYear;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // we'll show mmm | yyyy in picker
    if (component == 0) {

        // determine date so that we can get a month name
        int month = row+1;
        NSString *yyyy = [self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:1] forComponent:1];
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = yyyy.integerValue;
        comps.month = month;
        NSDate *date = [[NSCalendar cachedGregorianCalendar] dateFromComponents:comps];
        [comps release];
        
        return [date monthNameAbbreviated];
    }
    else {
        return [[NSNumber numberWithInt:1970 + row] stringValue];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // update our model
    NSInteger m = [_pickerView selectedRowInComponent:0] + 1;
    NSString *yyyy = [self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:1] forComponent:1];
    NSString *yyyymm = [NSString stringWithFormat:@"%@%02d", yyyy, m];
    self.value = [NSNumber numberWithInteger:yyyymm.integerValue];
    
    // communicate
    [_target performSelector:_action withObject:self.value];
}



@end
