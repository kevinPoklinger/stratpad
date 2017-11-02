//
//  MBRichDrawableLabel.h
//  StratPad
//
//  Created by Julian Wood on 9/22/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Drawable.h"


@interface MBRichDrawableLabel : NSObject<Drawable> {
@protected
    NSAttributedString *attributedString_;
    CGRect rect_;
}

@property(nonatomic, assign) CGRect rect;
@property(nonatomic,retain) NSAttributedString *attributedString;

- (id)initWithAtrributedString:(NSAttributedString*)attributedString 
                       andRect:(CGRect)rect;

@end
