//
//  LoansViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-20.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"
#import "FinancialRowValidator.h"

@interface LoansViewController : FormViewController<UITableViewDataSource,UITableViewDelegate,FinancialRowValidator>



@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;

@end
