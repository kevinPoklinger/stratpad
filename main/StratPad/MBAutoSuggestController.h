//
//  AutoSuggestController.h
//  StratPad
//
//  Created by Eric Rogers on August 14, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Takes an array of suggestion values for a textfield and displays them in a popover adjacent
//  to the given textfield.

#import "MBAutoSuggestTextField.h"

@protocol AutoSuggestDelegate <NSObject>

- (void)valueSelected:(NSString *)value forAutoSuggestTextField:(MBAutoSuggestTextField *)textField;

@end

@interface MBAutoSuggestController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate> {
 @private
    UITableView *tableView_;
    
    MBAutoSuggestTextField *textField_;
    
    UIPopoverController *popoverController_;
        
    NSArray *autoSuggestValues_;
    
    NSMutableArray *filteredValues_;
    
    id<AutoSuggestDelegate> delegate_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet NSArray *autoSuggestValues;
@property(nonatomic, assign) id<AutoSuggestDelegate> delegate;

- (id)initWithAutoSuggestTextField:(MBAutoSuggestTextField*)textField;

- (void)showWithSearchString:(NSString *)query;
- (void)hideAutoSuggest;

@end
