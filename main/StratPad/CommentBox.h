//
//  CommentBox.h
//  StratPad
//
//  Created by Julian Wood on 12-05-01.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentLabel.h"
#import "Chart.h"

@interface CommentBox : NSObject

@property(nonatomic,assign)CGRect hitRect;
@property(nonatomic,copy)NSString *comment;
@property(nonatomic,retain)Chart *chart;
@property(nonatomic,retain)CommentLabel *commentLabel;
@property(nonatomic,assign)NSUInteger level;

- (id)initWithHitRect:(CGRect)aHitRect comment:(NSString*)aComment chart:(Chart*)aChart level:(uint)level;

@end
