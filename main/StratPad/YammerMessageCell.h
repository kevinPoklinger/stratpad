//
//  YammerMessageCell.h
//  StratPad
//
//  Created by Julian Wood on 12-10-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabelVAlignment.h"

@interface YammerMessageCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imgSenderPhoto;
@property (retain, nonatomic) IBOutlet UILabel *lblSender;
@property (retain, nonatomic) IBOutlet UIButton *btnLike;
@property (retain, nonatomic) IBOutlet UILabel *lblCreationDate;
@property (retain, nonatomic) IBOutlet UILabelVAlignment *lblCommentText;

@end
