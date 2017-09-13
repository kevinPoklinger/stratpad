//
//  MBCalendarButton.h
//  StratPad
//
//  Created by Eric Rogers on August 15, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  A rounded button with an inset label on the left, and calendar on the right. When you tap it
//  it shows an MBDateSelectionViewController. This vc will query a DateDelectionDelegate for the date that it
//  should show. It will also query this delegate after every selected date to see if it is valid,
//  and present the user with a warning message when it is not. This message can be customized by the delegate
//  using the optional messageForDate:forCalendarButton:isValid: delegate message. After a date is chosen, the 
//  delegate is sent a dateSelected:forCalendarButton: message. You should not set the date in the button manually 
//  by accessing the label.
//
//  Usage recipe:
//  1. Add UIButton to nib and change to a MBCalendarButton (btn label needs to be empty, 138 px wide for system 14 font)
//  2. Hook up an outlet and an action to MBCalendarButton
//  3. Set the date on the button in viewdidload
//  4. Can also set textColor, textSize, roundedRectBackgroundColor, enabledBackgroundColor and nextResponder in viewdidload
//  5. In action, you need to invoke an MBDateSelectionViewController and set its delegate
//  6. Implement DateSelectionDelegate


#import "MBRoundedButton.h"
#import "MBDateSelectionViewController.h"

@interface MBCalendarButton : MBRoundedButton {
 @private
    UILabel *label_; 
    NSDate *date_;

    UIResponder *nextResponder_;

    MBDateSelectionViewController *targetDateController_;
    id<DateSelectionDelegate> delegate_;
    NSString* titleForDateSelectionPopover_;
    
    UIColor *enabledBackgroundColor_;
    UIColor *disabledBackgroundColor_;
    
}

// a UIControl that will be made firstResponder when pressing the next button
@property(nonatomic,retain) UIResponder *nextResponder;

// where should the popover chooser query for suggested dates, validation and validation messages, and notify after a date has been selected
@property(nonatomic,assign) id<DateSelectionDelegate> delegate;

// give the date chooser a title. eg. Start Date
@property(nonatomic,retain) NSString* titleForDateSelectionPopover;

// this is the date that will be displayed in the button, and initially shown in the chooser; can be nil
@property(nonatomic, assign, setter=setDate:) NSDate *date;

// for skins
@property(nonatomic, retain) UIColor *enabledBackgroundColor;
@property(nonatomic, assign) UIColor *textColor;
@property(nonatomic, assign) CGFloat textSize;

@end
