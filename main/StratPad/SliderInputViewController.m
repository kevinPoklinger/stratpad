//
//  SliderInputViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "SliderInputViewController.h"
#import "SkinManager.h"
#import "HonedSlider.h"

@interface SliderInputViewController ()

@property (retain, nonatomic) IBOutlet UILabel *lblDescription;
@property (retain, nonatomic) IBOutlet HonedSlider *slider;
@property (retain, nonatomic) IBOutlet UILabel *lblValue;

@end

@implementation SliderInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(_valueFormatter != nil, @"Must provide a value formatter");
        
    self.lblDescription.text = self.desc;
    _slider.minimumValue = _minimumValue;
    _slider.maximumValue = _maximumValue;
    
    SkinManager *skinMan = [SkinManager sharedManager];
    UIColor *textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    _lblDescription.textColor = textColor;
    _lblValue.textColor = textColor;
    
    self.view.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor forMediaType:MediaTypeScreen];
    
    [self reloadData];
    
    [_slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_valueFormatter release];
    [_target release];
    [_desc release];
    [_lblDescription release];
    [_slider release];
    [_lblValue release];
    [super dealloc];
}

-(void)valueChanged
{
    NSNumber *val = [NSNumber numberWithFloat:[_slider honedFloatValue]];

    // ie with a percent, or with a year suffix, etc
    NSString *formattedValue = _valueFormatter(val);
    _lblValue.text = formattedValue;
    
    // notify the underlying (typically) uitextfield
    [_target performSelector:_action withObject:val];
}


-(void)reloadData
{
    _slider.value = [self.value floatValue];

    NSString *formattedValue = _valueFormatter(_value);
    _lblValue.text = formattedValue;
}

@end
