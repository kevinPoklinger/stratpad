//
//  MBRoundedTableViewCell.h
//  StratPad
//
//  Created by Eric on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Draws a table cell with a transparent background and a 
//  rounded view inside of it.  Note that in order to have 
//  space between each cell in a table view, the rounded view should be 
//  smaller in height than the cell itself.

@interface MBRoundedTableViewCell : UITableViewCell {
 @protected 
    UIView *roundedView_;
}

@property (nonatomic, retain) IBOutlet UIView *roundedView;

@end
