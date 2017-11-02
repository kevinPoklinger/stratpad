//
//  PropertyTextField.m
//  StratPad
//
//  Created by Julian Wood on 12-04-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "PropertyTextField.h"

@implementation PropertyTextField

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _actions = 0;
    }
    return self;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{    
    // see UIResponderStandardEditActions
    // actions are copy:, cut:, delete:, paste:, select:, and selectAll:
    
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] && (_actions & EditActionCopy) != 0) {
        return YES;
    }

    if ([NSStringFromSelector(action) isEqualToString:@"cut:"] && (_actions & EditActionCut) != 0) {
        return YES;
    }

    if ([NSStringFromSelector(action) isEqualToString:@"delete:"] && (_actions & EditActionDelete) != 0) {
        return YES;
    }

    if ([NSStringFromSelector(action) isEqualToString:@"paste:"] && (_actions & EditActionPaste) != 0) {
        return YES;
    }

    if ([NSStringFromSelector(action) isEqualToString:@"select:"] && (_actions & EditActionSelect) != 0) {
        return YES;
    }

    if ([NSStringFromSelector(action) isEqualToString:@"selectAll:"] && (_actions & EditActionSelectAll) != 0) {
        return YES;
    }
    
    return NO;
}

// @override allow custom color
- (void) drawPlaceholderInRect:(CGRect)rect
{
    if (_placeHolderColor) {
        [_placeHolderColor setFill];
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeClip alignment:self.textAlignment];
    } else {
        [super drawPlaceholderInRect:rect];
    }
}

- (BOOL)becomeFirstResponder
{
    // [super becomeFirstResponder]; will initiate the machinery which will eventually call resignFirstResponder
    // unfortunately, it overrides textFieldShouldBeginEditing: and thus we see a flashing cursor (bad)
    // otherwise, [self.superview endEditing:YES]; would have resigned the last responder
    
    // we have to resign manually, because we're using uitextfields that can't technically become the first responder
    [self.linkedFieldOrganizer resignRespondersExcept:self];
    
    return [super becomeFirstResponder];
}

- (void)dealloc
{
    [_linkedFieldOrganizer release];
    [_placeHolderColor release];
    [_property release];
    [super dealloc];
}

@end


