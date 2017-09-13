//
//  DefineObjectivesHeaderView.h
//  StratPad
//
//  Created by Eric Rogers on August 17, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBRoundedRectView.h"

@interface DefineObjectivesHeaderView : MBRoundedRectView {
 @private
    UILabel *lblObjectiveType_;
    UILabel *lblInstructions_;
}

@property(nonatomic, retain) IBOutlet UILabel *lblObjectiveType;
@property(nonatomic, retain) IBOutlet UILabel *lblInstructions;

@end
