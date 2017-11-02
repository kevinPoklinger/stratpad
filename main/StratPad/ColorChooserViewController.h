//
//  ColorChooserViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"

@protocol ColorChooser <NSObject>
- (void)colorSelected;
@end

@interface ColorChooserViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    @private
    Chart *chart_;
    id<ColorChooser> colorChooser_;
}
@property (retain, nonatomic) IBOutlet UITableView *tblColors;

- (id)initWithChart:(Chart*)chart andColorChooser:(id<ColorChooser>)colorChooser;

@end
