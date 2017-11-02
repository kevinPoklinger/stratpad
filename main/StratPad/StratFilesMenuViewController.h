//
//  StratFilesMenuViewController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFilesTableViewCell.h"
#import "MenuNavController.h"

@interface StratFilesMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TableBasedMenu> {
@private
    // Array of StratFile ordered by dateLastAccessed
    NSArray *stratFiles_;
    
    UITableView *tableView_;
        
    // outlet to a theme table view cell loaded from a nib resource
	StratFilesTableViewCell *tableCell_;
            
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet StratFilesTableViewCell *tableCell;

@end
