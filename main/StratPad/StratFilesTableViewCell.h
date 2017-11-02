//
//  StratFilesTableViewCell.h
//  StratPad
//
//  Created by Julian Wood on 11-08-12.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCountLabel.h"


@interface StratFilesTableViewCell : UITableViewCell 

@property (nonatomic,retain) IBOutlet UILabel *name;
@property (nonatomic,retain) IBOutlet UILabel *company;
@property (nonatomic,retain) IBOutlet UILabel *dateLastAccessed;
@property (retain, nonatomic) IBOutlet MessageCountLabel *lblUnreadComments;

@end
