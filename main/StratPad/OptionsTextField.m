//
//  EnumTextField.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "OptionsTextField.h"
#import "OptionsInputViewController.h"

@interface OptionsTextField ()
@property (nonatomic,retain) UIPopoverController *popoverController;
@end

@implementation OptionsTextField


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // look for changes in model
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        _dismissOnSelection = FALSE;
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
        OptionsInputViewController *optionsController = [[OptionsInputViewController alloc] init];
        
        optionsController.desc = self.desc;
        optionsController.options = _options;
        
        optionsController.target = self;
        optionsController.action = @selector(valueChanged:);
        
        optionsController.value = _value;
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:optionsController];
        _popoverController.popoverContentSize = [optionsController preferredSize];
        _popoverController.passthroughViews = self.linkedFieldOrganizer.linkedFields;
        [optionsController release];
    }
    
    [_popoverController presentPopoverFromRect:self.frame
                                        inView:self.superview
                      permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
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
    if (_value != nil) {
        if (self.displayBlock) {
            self.displayBlock(self, _value);
        }
        else {
            self.text = [self.options objectAtIndex:_value.integerValue];
        }
    }
}

-(void)valueChanged:(NSNumber*)value
{
    self.value = value;
    
    // just add UIControlEventValueChanged event listeners to EnumTextField, and this will make sure they are called
    for (id target in [self allTargets]) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString *actionString in actions) {
            SEL action = NSSelectorFromString(actionString);
            [target performSelector:action withObject:value];
        }
    }
    
    if (_dismissOnSelection) {
        [_popoverController dismissPopoverAnimated:YES];
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
    [_displayBlock release];
    [_desc release];
    [_popoverController release];
    [super dealloc];
}

@end