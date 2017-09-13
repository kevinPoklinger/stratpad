//
//  DateSelectionViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 12, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDateSelectionViewController.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "UIColor-Expanded.h"
#import "MBCalendarButton.h"
#import "LocalizedManager.h"
#import "NSCalendar+Expanded.h"

#import <objc/runtime.h>

@implementation MBDateSelectionViewController

@synthesize datePicker = datePicker_;
@synthesize delegate = delegate_;
@synthesize lblDateSelected = lblDateSelected_;
@synthesize barButtonTitle = barButtonTitle_;
@synthesize barButtonNext;

#pragma mark - Constructors

- (id)initWithCalendarButton:(MBCalendarButton *)button andTitle:(NSString*)title
{
    if ((self = [super initWithNibName:@"MBDateSelectionView" bundle:nil])) {
        button_ = button;
        title_ = [[title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":?"]] retain];        
    }
    return self;
}

- (void)viewDidLoad
{
    // MDT = UTC -6, summer
    // MST = UTC -7, winter
    // if we select jan 4, 2008 in MST, then it will be stored as jan 4, 2008 UTC, and it will open in China as jan 4, 2008

    // we need to select a local date, store it as local with no time or timezone info, and show it as local
    // calculations should be done by normalizing dates with dateWithZeroedTime
    // note that you can't set the locale on the datepicker, the way you would expect

    datePicker_.timeZone = [NSTimeZone localTimeZone];
    
    barButtonTitle_.title = title_;
    normalStatusColor_ = [lblDateSelected_.textColor retain];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (button_.date) {                
        // load up the existing date
        self.datePicker.date = button_.date;
        
    } else {
        // pick a new date - a suggested one
        NSDate *proposedDate = [NSDate date];
        NSDate *datePickerDate = [self.delegate suggestedDateForCalendarButton:button_ proposedDate:proposedDate];
        self.datePicker.date = datePickerDate;
    }
    
    [self valueChanged];
    
    if (!button_.nextResponder) {
        self.barButtonNext.title = @"Done";
    }
    
    [super viewWillAppear:animated];
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [self setBarButtonNext:nil];
    self.datePicker = nil;
    self.lblDateSelected = nil;
    self.barButtonTitle = nil;
}

- (void)dealloc
{
    [datePicker_ release];
    [popoverController_ release];
    [lblDateSelected_ release];
    [barButtonTitle_ release];
    [title_ release];
    [normalStatusColor_ release];
    
    [barButtonNext release];
    [super dealloc];
}


#pragma - Public

- (void)hideDatePicker
{
    [popoverController_ dismissPopoverAnimated:YES];
}


#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController 
{
	[popoverController_ release];
	popoverController_ = nil;
    
    // make sure we use a valid date
    NSDate *selectedDate = datePicker_.date;
    BOOL isValid = [self.delegate isValid:selectedDate forCalendarButton:button_];
    NSDate *date = isValid ? selectedDate : [self.delegate suggestedDateForCalendarButton:button_ proposedDate:selectedDate];
    date = [date normalizeDate];
    [button_ setDate:date];
    [self.delegate dateSelected:date forCalendarButton:button_];
}

#pragma mark - Actions

- (IBAction)clear
{
    [button_ setDate:nil];
    [self.delegate dateSelected:nil forCalendarButton:button_]; 
    [self hideDatePicker];
}

- (IBAction)next
{
    // make sure we use a valid date
    NSDate *selectedDate = datePicker_.date;
    BOOL isValid = [self.delegate isValid:selectedDate forCalendarButton:button_];
    NSDate *date = isValid ? selectedDate : [self.delegate suggestedDateForCalendarButton:button_ proposedDate:selectedDate];
    date = [date normalizeDate];
    [button_ setDate:date];
    [self.delegate dateSelected:date forCalendarButton:button_]; 
    
    [self hideDatePicker];
    
    // todo: if nextresponder is nil then change button to Done
    [button_.nextResponder becomeFirstResponder];
}

- (void)showDatePicker
{    
    if (popoverController_) {
        [popoverController_ release];
        popoverController_ = nil;
    }
    
	popoverController_ = [[UIPopoverController alloc] initWithContentViewController: self];
	popoverController_.delegate = self;
	popoverController_.popoverContentSize = self.view.bounds.size;	
	
	[popoverController_ presentPopoverFromRect:button_.frame	
                                        inView:[button_ superview]
                      permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                      animated:YES];    
}

- (void)valueChanged
{
    // don't set the value until we actually choose a valid date and dismiss the controller
    // make sure the date is valid
    NSDate *selectedDate = datePicker_.date;
    BOOL isValid = [self.delegate isValid:selectedDate forCalendarButton:button_];
    
    NSString *message;
    
    // use the delegate message if available
    if ([self.delegate respondsToSelector:@selector(messageForDate:forCalendarButton:isValid:)]) {
        message = [self.delegate messageForDate:selectedDate forCalendarButton:button_ isValid:isValid];

    // otherwise use a default message
    } else {
        if (isValid) {
            message = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_VALID", nil), [self.datePicker.date formattedDateForDateSelectionMessage]];
        } else {
            NSDate *suggestedDate = [self.delegate suggestedDateForCalendarButton:button_ proposedDate:selectedDate];
            message = [NSString stringWithFormat:LocalizedString(@"DATE_SELECTION_INVALID", nil), [suggestedDate formattedDateForDateSelectionMessage]];
        }
    }
    
    // resize the popover and the uilabel to fit message
    static const CGFloat padding = 3;
    CGSize size = [message sizeWithFont:lblDateSelected_.font 
                      constrainedToSize:CGSizeMake(lblDateSelected_.frame.size.width, 150) 
                          lineBreakMode:UILineBreakModeWordWrap];
    CGFloat yDiff = (size.height + padding) - lblDateSelected_.frame.size.height;
    CGSize popSize = CGSizeMake(popoverController_.popoverContentSize.width, popoverController_.popoverContentSize.height + yDiff);
    [self performSelectorOnMainThread:@selector(updatePopoverSize:) withObject:[NSValue valueWithCGSize:popSize] waitUntilDone:NO];
    
    lblDateSelected_.text = message;
    lblDateSelected_.textColor = isValid ? normalStatusColor_ : [UIColor colorWithHexString:@"FFCC66"];
    
}

- (void)updatePopoverSize:(NSValue*)popoverSize
{
    [popoverController_ setPopoverContentSize:[popoverSize CGSizeValue] animated:YES];
}

-(void)dumpInfo:(id)obj
{
    Class clazz = [obj class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}


@end

#pragma mark - NSDate (DateSelection)

@implementation NSDate (DateSelection)

-(NSDate*)normalizeDate
{
    // so if we have 2012-02-23 8:11 MST == 2012-02-24 3:11 UTC, we want to store 2012-02-23 00:00 MST == 2012-02-23 07:00 UTC
    return [self dateWithZeroedTime];
}

- (NSString*)formattedDateForDateSelection
{
    // stratpad-language dependent, tz-sensitive
    // in other words, this will take the current datetime, change it to be appropriate for your local tz, and present it according to the language chosen in stratpad
    // shows up in the buttons (ie the field part)
    NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MMM d, yyyy" options:0 locale:locale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:locale];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    [locale release];
    return formattedDate;
}

- (NSString*)formattedDateForDateSelectionMessage
{
    // stratpad-language dependent, tz-sensitive
    // in other words, this will take the current datetime, change it to be appropriate for your local tz, and present it according to the language chosen in stratpad
    NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"EEE MMM d, yyyy" options:0 locale:locale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:locale];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    [locale release];
    return formattedDate;
}


@end
