//
//  Drawable.h
//  StratPad
//
//  Created by Julian Wood on 9/22/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Drawable <NSObject>
@required

// supposes that you have set a rect in which to draw the object into the current context
- (void)draw;

// the rect into which this object should be drawn
- (CGRect)rect;
- (void)setRect:(CGRect)rect;

@optional

// this will change rect such that it is optimally sized at the original Drawable origin
- (void)sizeToFit;

// just a flag saying that we have positioned the rect appropriately and we can draw to context
- (BOOL)readyForPrint;
- (void)setReadyForPrint:(BOOL)isReadyForPrint;

@end
