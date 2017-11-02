//
//  TermInputViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-30.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "TermInputViewController.h"
#import "NSCalendar+Expanded.h"

@interface TermInputViewController ()
@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBtnItemTitle;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation TermInputViewController

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
    [_barBtnItemTitle release];
    [_pickerView release];
    [super dealloc];
}

#pragma mark - Private

- (void)reloadData
{
    // default value
    int years = 2;
    int months = 0;
    
    // load user value
    if (self.value) {
        years = self.value.integerValue / 12;
        months = self.value.integerValue % 12;
    }

    [_pickerView selectRow:years inComponent:0 animated:NO];
    [_pickerView selectRow:months inComponent:1 animated:NO];
    
    // fire an event so that we update our model and the associated text field, esp for case where term was initially nil
    [self pickerView:_pickerView didSelectRow:months inComponent:1];
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 41;
    }
    else {
        return 12;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%i y", row];
    }
    else {
        return [NSString stringWithFormat:@"%i mo.", row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // update our model
    NSInteger y = [_pickerView selectedRowInComponent:0];
    NSInteger m = [_pickerView selectedRowInComponent:1];
    
    self.value = [NSNumber numberWithInteger:y*12+m];
    
    // communicate
    [_target performSelector:_action withObject:self.value];
}

@end
