//
//  MessageCountLabel.h
//  StratPad
//
//  Created by Julian Wood on 12-09-26.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  Draws a label, much like you would see in the Mail.app, which is often used to denote how many nread cells there
//  are in a tableviewcell. Has a slight gradient, and rounded edges.

#import <UIKit/UIKit.h>

@interface MessageCountLabel : UILabel

// given the text in this label at the designated fontsize, what size should this label be?
// workable attributes are 16pt high and fontsize of 12 bold, white text, center alignment
- (CGSize)preferredSize;

@end
