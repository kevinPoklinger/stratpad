//
//  PropertyTextField.h
//  StratPad
//
//  Created by Julian Wood on 12-04-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Holds a property name for reference - can be used to bind to a core data entity property.
//  Makes it easy to specify which actions can be performed on the textfield (ie copy, paste, etc)
//  NB. it is better to use UIView+ObjectTagAdditions to hold the property name.

#import <UIKit/UIKit.h>
#import "LinkedFieldOrganizer.h"

typedef enum {
    EditActionCopy      = 1,
    EditActionCut       = 2,
    EditActionDelete    = 4,
    EditActionPaste     = 8,
    EditActionSelect    = 16,
    EditActionSelectAll = 32
} EditAction;

@interface PropertyTextField : UITextField

// bind the textField to a CoreData property name
@property (nonatomic, retain) NSString* property;

// for the copy/paste/... menu, which options should we show?
@property (nonatomic, assign) NSUInteger actions;

// sometimes the default grey colour is not appropriate
@property (nonatomic, retain) UIColor *placeHolderColor;

// let this field know about other fields; eg when we have a UITableViewCell full of fields, which have custom behaviours (otherwise traditional responder mechanism will work fine for this purpose)
@property (nonatomic, retain) LinkedFieldOrganizer *linkedFieldOrganizer;

@end
