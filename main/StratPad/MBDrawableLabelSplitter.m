//
//  MBDrawableLabelSplitter.m
//  StratPad
//
//  Created by Eric Rogers on October 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableLabelSplitter.h"
#import "NSString-Expanded.h"

@implementation MBDrawableLabelSplitter

- (id)initWithFirstRect:(CGRect)firstRect andSubsequentRect:(CGRect)subsequentRect
{
    if ((self = [super init])) {
        firstRect_ = firstRect;
        subsequentRect_ = subsequentRect;
    }
    return self;
}

- (NSArray*)splitDrawable:(id<Drawable>)drawable
{
    MBDrawableLabel *labelToSplit = ((MBDrawableLabel*)drawable);
    NSString *text = labelToSplit.text;
    
    NSMutableArray *labels = [NSMutableArray array];
    
    if (!labelToSplit.text || [labelToSplit.text isBlank]) {
        [labels addObject:labelToSplit];
        return labels;
    }
    
    CGRect splitRect = firstRect_;
    
    for (uint i = 0; text.length > 0; i++) {
        
        MBDrawableLabel *label = [self newDrawableLabelWithText:text andSourceLabel:labelToSplit confinedToRect:splitRect];
        [labels addObject:label];
        [label release];

        // use the subsequent rect for any additional labels.
        splitRect = subsequentRect_;
        
        // remove the characters we just included in the label from the content and continue on.
        text = [text substringFromIndex:label.text.length] ;
        
        // trim any whitespace or newline characters off the text since we want the labels to 
        // begin and end on actual character boundaries
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return labels;
}

- (MBDrawableLabel*)newDrawableLabelWithText:(NSString*)text andSourceLabel:(MBDrawableLabel*)sourceLabel confinedToRect:(CGRect)rect
{
    // The idea here is that we need to build a buffer of words.  Each word is constructed character by character, until we find a
    // whitespace or newline.  At which point we try to add the word and the following whitespace/endline to the buffer.  If it fits, 
    // then continue on.  Otherwise, we need to create a label using the buffer and return it.
    // 
    // There exists an edge case where a word is longer than the width of the rect, and it will not fit in the remainder of the rect.
    // In that situation we will need to break the word across pages; no choice here.
        
    NSString *word = @"";    
    NSString *temp = @"";
    NSString *labelText = @"";    
    
    while (text.length > 0) {

        word = [self nextWordFromText:text withFont:sourceLabel.font restrictedToMaxWidth:rect.size.width];        
        temp = [labelText stringByAppendingFormat:@"%@", word];
        
        // check whether appending the new word to the label text will still fit within the rect for the label.
        CGSize sizeThatFits = [MBDrawableLabel sizeThatFits:CGSizeMake(rect.size.width, 9999) 
                                                   withText:temp 
                                                    andFont:sourceLabel.font 
                                              lineBreakMode:sourceLabel.lineBreakMode];        
        
        if (sizeThatFits.height < rect.size.height) {
            
            // update the label text with the new text containing the word
            labelText = temp;
            
            // remove the characters we just included in the label from text and continue on.
            text = [text substringFromIndex:word.length];
            
        } else {
            // we cannot fit any more characters into the label so break and create the label
            break;
        }        
    }
    
    // trim any whitespace and newlines off the label text
    labelText = [labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:labelText 
                                                              font:sourceLabel.font 
                                                             color:sourceLabel.color 
                                                     lineBreakMode:sourceLabel.lineBreakMode 
                                                         alignment:sourceLabel.textAlignment 
                                                           andRect:rect];
    [label sizeToFit];
    return label;
}

- (NSString*)nextWordFromText:(NSString*)text withFont:(UIFont*)font restrictedToMaxWidth:(CGFloat)maxWidth
{    
    unichar c;
    NSString *word = @"";
        
    for (int i = 0; i < text.length; i++) {
        c = [text characterAtIndex:i];
        word = [word stringByAppendingFormat:@"%C",c];
        
        // check whether the word is too wide for the label, if so, remove the newly added character and break.
        // note that we we use a height of 2 * (font.pointSize + 3.f) to account for newline characters, otherwise
        // we just get a width of 9999 which does us no good in that case.
        CGSize sizeThatFits = [MBDrawableLabel sizeThatFits:CGSizeMake(9999, 2 * (font.pointSize + 3.f)) 
                                                   withText:word 
                                                    andFont:font 
                                              lineBreakMode:UILineBreakModeWordWrap];
        if (sizeThatFits.width > maxWidth) {
            word = [word stringByReplacingCharactersInRange:NSMakeRange(word.length - 1, 1) withString:@""];
            break;
        }  else if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
            // we have a whitespace or newline so we are done
            break;
        }
    }
    return word;
}

+ (CGFloat)minimumSplitHeightForDrawable:(id<Drawable>)drawable
{
    MBDrawableLabel *label = (MBDrawableLabel*)drawable;
    CGSize sizeThatFits = [MBDrawableLabel sizeThatFits:CGSizeMake(drawable.rect.size.width, 9999) withText:@"A" andFont:label.font lineBreakMode:label.lineBreakMode];        
    return sizeThatFits.height;
}

@end
