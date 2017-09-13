//
//  OpeningBalanceCell.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-26.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyTextField.h"
#import "OpeningBalances.h"

@protocol RowScrollerDelegate <NSObject>
@required
-(void)scrollToRow:(NSInteger)row;
-(UIResponder*)nextField:(NSInteger)lastRow;

@end

@interface OpeningBalanceCell : UITableViewCell<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UILabel *lblName;
@property (retain, nonatomic) IBOutlet UILabel *lblCalculated;
@property (retain, nonatomic) IBOutlet PropertyTextField *txtValue;
@property (retain, nonatomic) IBOutlet UILabel *lblDifference;

@property (retain, nonatomic) OpeningBalances *openingBalances;

// give the delegate sufficient info to scroll to this cell when needed
@property (retain, nonatomic) id<RowScrollerDelegate> delegate;
@property (assign, nonatomic) NSInteger row;

// re-display formatted data from openingBalances
-(void)reloadData;

@end
