//
//  AssetsViewController.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"
#import "FinancialRowValidator.h"

@interface AssetsViewController : FormViewController<UITableViewDataSource,UITableViewDelegate,FinancialRowValidator>

@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;


@end
