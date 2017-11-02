//
//  AddObjectiveTableViewCell.h
//  StratPad
//
//  Created by Eric on 11-08-17.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedTableViewCell.h"


@interface AddObjectiveTableViewCell : MBRoundedTableViewCell {
@private
    UILabel *lblAddObjective_;   
}

@property(nonatomic, retain) IBOutlet UILabel *lblAddObjective;

@end
