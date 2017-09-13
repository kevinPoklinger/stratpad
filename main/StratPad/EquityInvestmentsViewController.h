//
//  EquityInvestmentsViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-23.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"
#import "FinancialRowValidator.h"

@interface EquityInvestmentsViewController : FormViewController<UITableViewDataSource,UITableViewDelegate,FinancialRowValidator>

@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;


@end
