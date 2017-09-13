//
//  TitleViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-04-06.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPlaceHolderTextView.h"
#import "Chart.h"

@protocol TitleChooser <NSObject>
-(void)titleChosen;
@end

@interface TitleViewController : UIViewController<UITextViewDelegate> {
    @private
    Chart *chart_;
    id<TitleChooser> titleChooser_;
}

- (id)initWithChart:(Chart*)chart andTitleChooser:(id<TitleChooser>)titleChooser;

@property (retain, nonatomic) IBOutlet MBPlaceHolderTextView *textView;

@end
