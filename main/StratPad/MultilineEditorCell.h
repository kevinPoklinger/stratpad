//
//  MultilineEditorCell.h
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellTextView.h"

@interface MultilineEditorCell : UITableViewCell<UITextViewDelegate>

@property (retain, nonatomic) IBOutlet TableCellTextView *textView;

-(void)showActivity;
-(void)finishActivity;
@end
