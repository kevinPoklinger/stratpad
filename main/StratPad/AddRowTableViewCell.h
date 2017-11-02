//
//  AddThemeTableViewCell.h
//  StratPad
//
//  Created by Julian Wood on 11-08-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBRoundedTableViewCell.h"

@interface AddRowTableViewCell : MBRoundedTableViewCell {
    @private
    UILabel *lblAddRow_;
}

@property (nonatomic, retain) IBOutlet UILabel *lblAddRow;

@end
