//
//  MBDropDownController.h
//  StratPad
//
//  Created by Eric Rogers on August 21, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDropDownButton.h"

@protocol DropDownDelegate <NSObject>
- (void)valueSelected:(id)value forDropDownButton:(MBDropDownButton*)button;
@end


@interface MBDropDownController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate> {
@private
    UITableView *tableView_;
    
    MBDropDownButton *dropDownButton_;
    
    UIPopoverController *popoverController_;
    
    NSMutableArray *dropDownValues_;
    
    NSNumber *selectedRow_;
    
    id selectedValue_;
    
    id<DropDownDelegate> delegate_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) id selectedValue;
@property(nonatomic, assign) id<DropDownDelegate> delegate;


- (id)initWithDropDownButton:(MBDropDownButton*)button andSelectedValueOrNil:(id)value;

- (void)addDropDownValue:(id)value withDisplayValue:(NSString*)displayValue;
- (void)removeAllDropDownValues;

- (void)hide;
- (void)show;

@end