//
//  MBCalendarButton.m
//  StratPad
//
//  Created by Eric Rogers on August 15, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBCalendarButton.h"
#import "UIColor-Expanded.h"
#import "NSDate-StratPad.h"

@interface MBCalendarButton (Private)
-(void)showDateSelectionPopover;
@end

@implementation MBCalendarButton

@synthesize nextResponder = nextResponder_;
@synthesize delegate = delegate_;
@synthesize titleForDateSelectionPopover = titleForDateSelectionPopover_;
@synthesize enabledBackgroundColor = enabledBackgroundColor_;
@synthesize date = date_;

static const NSUInteger kHorizontalSubviewSpace = 10;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {

        UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, 10);
        
        UIImage *imgCalendar = [UIImage imageNamed:@"calendar.png"];
        UIImageView *calendarView = [[UIImageView alloc] initWithImage:imgCalendar];
        calendarView.frame = CGRectMake(self.bounds.size.width - imgCalendar.size.width - insets.right, 
                                         (self.bounds.size.height - imgCalendar.size.height)/2, 
                                         imgCalendar.size.width, imgCalendar.size.height);
        [self addSubview:calendarView];
        [calendarView release];
                
        UILabel *lblForButton = [[UILabel alloc] initWithFrame:CGRectMake(insets.left,
                                                           0, 
                                                           self.bounds.size.width - insets.left - insets.right - calendarView.frame.size.width - kHorizontalSubviewSpace, 
                                                           self.bounds.size.height)];
        lblForButton.backgroundColor = [UIColor clearColor];
        lblForButton.lineBreakMode = UILineBreakModeTailTruncation;
        lblForButton.userInteractionEnabled = NO; // set to no, as the button should be the only event responder.
        label_ = lblForButton;
        [self addSubview:lblForButton];
        [lblForButton release];
        
        NSString *hex = [roundedRectBackgroundColor_ hexStringFromColor];
        enabledBackgroundColor_ = [[UIColor colorWithHexString:hex] retain];
        disabledBackgroundColor_ = [[UIColor colorWithHexString:@"D4D4D4"] retain];
        
        targetDateController_ = nil;
    }
    return self;
}

-(BOOL)becomeFirstResponder
{
    [self showDateSelectionPopover];
    return YES;
}

-(void)showDateSelectionPopover
{
    NSAssert(delegate_ != nil, @"You must provide a DateSelectionDelegate, used to back the date popover.");
    NSAssert(titleForDateSelectionPopover_ != nil, @"You must provide a title for the date selection popover window.");
    if (!targetDateController_) {
        targetDateController_ = [[MBDateSelectionViewController alloc] 
                                 initWithCalendarButton:self
                                 andTitle:titleForDateSelectionPopover_];
        targetDateController_.delegate = delegate_;
    }
    
    [targetDateController_ showDatePicker];
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    [roundedRectBackgroundColor_ release];
    roundedRectBackgroundColor_ = enabled ? enabledBackgroundColor_ : disabledBackgroundColor_;
    [roundedRectBackgroundColor_ retain];
    
    label_.backgroundColor = enabled ? enabledBackgroundColor_ : disabledBackgroundColor_;
    [self setNeedsDisplay]; 
}

// override; nil is supported
-(void)setDate:(NSDate *)date
{
    if (![date isEqualToDate:date_]) {
        [date_ release];
        date_ = [date retain];
        label_.text = [date_ formattedDateForDateSelection];        
    }
}

-(void)setTextColor:(UIColor *)textColor
{
    label_.textColor = textColor;
}

-(UIColor*)textColor
{
    return label_.textColor;
}

-(void)setTextSize:(CGFloat)textSize
{
    label_.font = [UIFont systemFontOfSize:textSize];
}

-(CGFloat)textSize
{
    return label_.font.pointSize;
}

-(void)dealloc
{
    [titleForDateSelectionPopover_ release];
    [targetDateController_ release];
    [nextResponder_ release];
    [disabledBackgroundColor_ release];
    [enabledBackgroundColor_ release];
    [super dealloc];
}

@end
