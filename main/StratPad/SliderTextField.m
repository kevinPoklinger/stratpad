//
//  SliderTextField.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-18.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "SliderTextField.h"
#import "SliderInputViewController.h"

@interface SliderTextField ()
@property (nonatomic,retain) UIPopoverController *popoverController;
@end


@implementation SliderTextField

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // look for changes in model; primarily when we want to initialize from our LoanCell
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [self reloadData];
    }
}

- (BOOL)becomeFirstResponder
{
    [self.linkedFieldOrganizer resignRespondersExcept:self];
    
    // show popup
    if (!_popoverController) {
        SliderInputViewController *sliderController = [[SliderInputViewController alloc] init];
        
        sliderController.minimumValue = _minimumValue;
        sliderController.maximumValue = _maximumValue;
        
        sliderController.desc = self.desc;
        sliderController.valueFormatter = _valueFormatter;
        
        sliderController.target = self;
        sliderController.action = @selector(valueChanged:);
        
        sliderController.value = _value;
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:sliderController];
        _popoverController.popoverContentSize = sliderController.view.bounds.size;
        _popoverController.passthroughViews = self.linkedFieldOrganizer.linkedFields;
        [sliderController release];
    }
    
    [_popoverController presentPopoverFromRect:self.frame
                                       inView:self.superview
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    // because we allow pass through views, we must make sure we dismiss
    [_popoverController dismissPopoverAnimated:YES];
    
    return YES;
}

-(void)reloadData
{
    // from our model, show formatted data in the text field
    if (self.value) {
        NSString *formattedValue = _valueFormatter(_value);
        self.text = formattedValue;
    }
}

-(void)valueChanged:(NSNumber*)value
{
    self.value = value;
    
    // just add UIControlEventValueChanged event listeners to SliderTextField, and this will make sure they are called
    for (id target in [self allTargets]) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString *actionString in actions) {
            SEL action = NSSelectorFromString(actionString);
            [target performSelector:action withObject:value];
        }
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(PropertyTextField *)textField
{
    // we don't edit this field in the traditional manner
    return NO;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"value"];
    [_valueFormatter release];
    [_desc release];
    [_popoverController release];
    [_value release];
    [super dealloc];
}


@end
