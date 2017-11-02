//
//  TableCellTextView.h
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCellTextView : UITextView

@property (nonatomic,retain) NSIndexPath *indexPath;
@property (assign, nonatomic) BOOL isShowingPlaceHolder;

-(void)showPlaceHolder;
-(void)hidePlaceHolder;

@end
