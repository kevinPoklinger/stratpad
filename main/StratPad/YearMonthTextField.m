//
//  YearMonthTextField.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-19.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "YearMonthTextField.h"
#import "YearMonthInputViewController.h"
#import "NSDate-StratPad.h"
#import "NSCalendar+Expanded.h"


@interface NSDate (YearMonthTextField)
- (NSString*)formattedMonthFullYear;
@end

@implementation NSDate (YearMonthTextField)

- (NSString*)formattedMonthFullYear
{
    static NSDateFormatter* sMonthYearFormatter = nil;
    
    if (!sMonthYearFormatter) {
        NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        sMonthYearFormatter = [[NSDateFormatter alloc] init];
        [sMonthYearFormatter setDateFormat:@"MMM yyyy"];
        [sMonthYearFormatter setLocale:locale];
        [sMonthYearFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [locale release];
    }
    
    return [sMonthYearFormatter stringFromDate:self];
}

@end

@interface YearMonthTextField ()
@property (nonatomic,retain) UIPopoverController *popoverController;
@end

@implementation YearMonthTextField

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
        YearMonthInputViewController *ymViewController = [[YearMonthInputViewController alloc] init];
        ymViewController.desc = self.desc;
                
        ymViewController.target = self;
        ymViewController.action = @selector(valueChanged:);
        
        ymViewController.value = _value;
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:ymViewController];
        _popoverController.popoverContentSize = ymViewController.view.bounds.size;
        _popoverController.passthroughViews = self.linkedFieldOrganizer.linkedFields;
        [ymViewController release];
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
        // display as MMM 'YY (coming from yyyymm)
        NSString *s = [self.value stringValue];
        NSString *y = [s substringWithRange:NSMakeRange(0, 4)];
        NSString *m = [s substringFromIndex:4];
                
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = y.integerValue;
        comps.month = m.integerValue;
        NSDate *date = [[NSCalendar cachedGregorianCalendar] dateFromComponents:comps];
        [comps release];
        
        self.text = [date formattedMonthFullYear];
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
    [self.desc release];
    [_popoverController release];
    [super dealloc];
}


@end
