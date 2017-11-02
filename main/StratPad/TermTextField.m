//
//  TermTextField.m
//  StratPad
//
//  Created by Julian Wood on 2013-05-30.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "TermTextField.h"
#import "TermInputViewController.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"

@interface TermTextField ()
@property (nonatomic,retain) UIPopoverController *popoverController;
@end

@implementation TermTextField

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // look for changes in model
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
    // [super becomeFirstResponder]; will initiate the machinery which will eventually call resignFirstResponder
    // unfortunately, it overrides textFieldShouldBeginEditing: and thus we see a flashing cursor (bad)
    // otherwise, [self.superview endEditing:YES]; would have resigned the last responder
    
    // we have to resign manually, because we're using uitextfields that can't technically become the first responder
    [self.linkedFieldOrganizer resignRespondersExcept:self];
    
    // show popup
    if (!_popoverController) {
        TermInputViewController *termViewController = [[TermInputViewController alloc] init];
        termViewController.desc = self.desc;
        
        termViewController.target = self;
        termViewController.action = @selector(valueChanged:);
        
        termViewController.value = _value;
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:termViewController];
        _popoverController.popoverContentSize = termViewController.view.bounds.size;
        _popoverController.passthroughViews = self.linkedFieldOrganizer.linkedFields;
        [termViewController release];
    }
    
    [_popoverController presentPopoverFromRect:self.frame
                                        inView:self.superview
                      permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                      animated:YES];
    
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
    if (self.value) {
        NSString *key = LocalizedString(@"MONTH_MESSAGE_FORMAT", nil);
        self.text = [NSString stringWithFormat:key, self.value];
    }
}

-(void)valueChanged:(NSNumber*)value
{
    // update model
    self.value = value;
    
    // communicate
    // just add UIControlEventValueChanged event listeners to YearMonthTextField, and this will make sure they are called
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
    [_value release];
    [_desc release];
    [_popoverController release];
    [super dealloc];
}


@end
