//
//  NoRowsTableDataSource.h
//  StratPad
//
//  Created by Julian Wood on 11-08-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Use this when your table goes down to zero rows, but you want to add a row which gives instructions,
//  and potentially has a separate action. Make sure you switch datasources in your viewcontroller in
//  viewWillAppear when you commit editing and no rows remain. You'll also want to add some logic to your
//  viewcontroller for when this cell is selected.

#import <Foundation/Foundation.h>

@interface NoRowsTableDataSource : NSObject<UITableViewDataSource>

-(id)initWithTitle:(NSString*)titleForRow;

@property(nonatomic, assign) NSString *titleForRow;
@property(nonatomic, assign) BOOL isRounded;


@end
