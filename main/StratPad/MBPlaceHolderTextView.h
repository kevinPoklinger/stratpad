//
//  MBPlaceHolderTextView.h
//  StratPad
//
//  Created by Julian Wood on 11-08-07.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  A version of UITextView which supports placeholder text.

#import <Foundation/Foundation.h>


@interface MBPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    
@private
    UILabel *placeHolderLabel;
    UIColor *roundedRectBackgroundColor_;
}

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic,retain) UIColor *roundedRectBackgroundColor;

-(void)textChanged:(NSNotification*)notification;

@end
