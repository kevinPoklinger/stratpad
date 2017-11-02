//
//  TextFieldTableViewCell.h
//  StratPad
//
//  Created by Julian Wood on 11-08-18.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextFieldTableViewCell : UITableViewCell<UITextFieldDelegate> {
    UILabel *label_;
    UITextField *textField_;
    id boundEntity_;
    NSString *boundProperty_;
    NSNumber *maxLength_;
    UITableView *tableView_;
    NSIndexPath *indexPath_;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) id boundEntity;
@property (nonatomic, retain) NSString *boundProperty;
@property (nonatomic, retain) NSNumber *maxLength;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPath;

@end
