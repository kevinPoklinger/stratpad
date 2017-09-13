//
//  ChartMaxValueViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-06-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "PropertyTextField.h"

@protocol ChartMaxValueChooser <NSObject>
- (void)maxValueEntered;
@end


@interface ChartMaxValueViewController : UIViewController<UITextFieldDelegate> {
@private
    Chart *chart_;
    id<ChartMaxValueChooser> chartMaxValueChooser_;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet PropertyTextField *fldMaxValue;
@property (retain, nonatomic) IBOutlet UILabel *lblMaxMeasuredValue;
@property (retain, nonatomic) IBOutlet UILabel *lblMaxTargetValue;

- (id)initWithChart:(Chart*)chart andChartMaxValueChooser:(id<ChartMaxValueChooser>)chartMaxValueChooser;

@end
