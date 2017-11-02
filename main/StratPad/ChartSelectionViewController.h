//
//  ChartSelectionViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-06-19.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    StratCardActionPrint,
    StratCardActionEmail
} StratCardAction;

@interface ChartSelectionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    @private
    StratCardAction stratCardAction_;
    
    NSMutableDictionary *chartDict_;
    
    CAGradientLayer *maskLayer_;
}

- (id)initWithAction:(StratCardAction)stratCardAction;
- (IBAction)printOrEmailFile;

@property (retain, nonatomic) IBOutlet UITableView *tblCharts;
@property (retain, nonatomic) IBOutlet UIButton *btnAction;

@end
