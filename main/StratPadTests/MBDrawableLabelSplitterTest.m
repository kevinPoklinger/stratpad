//
//  MBDrawableLabelSplitterTest.m
//  StratPad
//
//  Created by Eric Rogers on 11-11-30.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import "MBDrawableLabel.h"
#import "MBDrawableLabelSplitter.h"
#import <SenTestingKit/SenTestingKit.h>

@interface MBDrawableLabelSplitterTest : SenTestCase
@end

@implementation MBDrawableLabelSplitterTest

/*
 * Test the new word from text method to ensure it returns next words in a text string properly.
 */
- (void)testNewWordFromText
{
    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] init];
    
    
    // test blank string
    NSString *word = [splitter nextWordFromText:@"" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"", word, @"Word should have been blank, but was %@", word);
    
    
    // test single word
    word = [splitter nextWordFromText:@"Hello" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"Hello", word, @"Word should have been 'Hello', but was %@", word);

    
    // test whitespace breaks
    word = [splitter nextWordFromText:@"Hello " withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"Hello ", word, @"Word should have been 'Hello ', but was %@", word);

    word = [splitter nextWordFromText:@"Hello World" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"Hello ", word, @"Word should have been 'Hello ', but was %@", word);

    
    // test newline breaks
    word = [splitter nextWordFromText:@"\n" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"\n", word, @"Word should have been '\n', but was %@", word);

    word = [splitter nextWordFromText:@"Hello\n" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"Hello\n", word, @"Word should have been 'Hello\n', but was %@", word);

    word = [splitter nextWordFromText:@"Hello\nWorld" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:300.f];
    STAssertEqualObjects(@"Hello\n", word, @"Word should have been 'Hello\n', but was %@", word);

    
    // test text that is longer than the maximum width to ensure it splits somewhere in the text itself, rather than simply returning the entire text.
    word = [splitter nextWordFromText:@"asdfasdfasdfasdfasdfasdfasdfasdfasfasfdasdfasdfadfafdasfadfasdasdfasdfasdfasdf" withFont:[UIFont fontWithName:@"Helvetica" size:12.f] restrictedToMaxWidth:100.f];
    STAssertEqualObjects(@"asdfasdfasdfasdfa", word, @"Word should have been 'asdfasdfasdfasdfa', but was %@", word);

    
    [splitter release];
}


/*
 * Test splitting an empty label.  It is expected that we will get the same
 * label in return.
 */ 
- (void)testSplittingOfEmptyLabel
{
    MBDrawableLabel *label1 = [[MBDrawableLabel alloc] initWithText:nil
                                                              font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                             color:[UIColor blackColor] 
                                                     lineBreakMode:UILineBreakModeWordWrap 
                                                         alignment:UITextAlignmentLeft 
                                                           andRect:CGRectMake(0, 0, 300, 500)];

    MBDrawableLabel *label2 = [[MBDrawableLabel alloc] initWithText:@"" 
                                                               font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                              color:[UIColor blackColor] 
                                                      lineBreakMode:UILineBreakModeWordWrap 
                                                          alignment:UITextAlignmentLeft 
                                                            andRect:CGRectMake(0, 0, 300, 500)];

    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] initWithFirstRect:CGRectMake(0, 0, 300, 100) 
                                                                         andSubsequentRect:CGRectMake(0, 0, 300, 500)];
    NSArray *drawables = [splitter splitDrawable:label1];    
    STAssertTrue(drawables.count == 1, @"Should have only received one label in return, but got %i", drawables.count);        
    STAssertEqualObjects(label1, [drawables objectAtIndex:0], @"Should have received the same label in return but got %@", [drawables objectAtIndex:0]);

    drawables = [splitter splitDrawable:label2];    
    STAssertTrue(drawables.count == 1, @"Should have only received one label in return, but got %i", drawables.count);        
    STAssertEqualObjects(label2, [drawables objectAtIndex:0], @"Should have received the same label in return but got %@", [drawables objectAtIndex:0]);

    [label1 release];    
    [label2 release];
    [splitter release];
}

/*
 * Test splitting a label that will fit in the first rect given to the splitter.  It is expected that only one drawable
 * will be returned.
 */ 
- (void)testSplittingOfLabel1
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:@"Hello Joe what do you know?"
                                                               font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                              color:[UIColor blackColor] 
                                                      lineBreakMode:UILineBreakModeWordWrap 
                                                          alignment:UITextAlignmentLeft 
                                                            andRect:CGRectMake(0, 0, 300, 500)];
    
    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] initWithFirstRect:CGRectMake(0, 0, 300, 100) 
                                                                         andSubsequentRect:CGRectMake(0, 0, 300, 500)];
    NSArray *drawables = [splitter splitDrawable:label];    
    STAssertTrue(drawables.count == 1, @"Should have only received one label in return, but got %i", drawables.count);        
    NSString *text = [[drawables objectAtIndex:0] text];
    STAssertEqualObjects(label.text, text, @"Returned label should have contained the same text as the original but had %@", text);
        
    [label release];    
    [splitter release];
}

/*
 * Test splitting a label that will not fit in the first rect given to the splitter.  It is expected that multiple drawable
 * labels will be returned each containing text split across them on a word boundary.
 */ 
- (void)testSplittingOfLabel2
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                                              font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                             color:[UIColor blackColor] 
                                                     lineBreakMode:UILineBreakModeWordWrap 
                                                         alignment:UITextAlignmentLeft 
                                                           andRect:CGRectMake(0, 0, 300, 100)];
    
    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] initWithFirstRect:CGRectMake(0, 0, 300, 20) 
                                                                         andSubsequentRect:CGRectMake(0, 0, 300, 200)];
    NSArray *drawables = [splitter splitDrawable:label];    
    STAssertTrue(drawables.count == 2, @"Should have received two labels in return, but got %i", drawables.count);        

    NSString *text = [[drawables objectAtIndex:0] text];    
    STAssertEqualObjects(@"Lorem ipsum dolor sit amet, consectetur adipisicing elit,", text, @"Returned label should have contained the same text as the original but had %@", text);
    
    text = [[drawables objectAtIndex:1] text];
    STAssertEqualObjects(@"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", text, @"Returned label should have contained the same text as the original but had %@", text);
    
    [label release];    
    [splitter release];
}

/*
 * Test splitting a label that will not fit in the first rect given to the splitter, and one that has endlines.  It is expected that multiple drawable
 * labels will be returned each containing text split across them on a word or endline boundaries.
 */ 
- (void)testSplittingOfLabel3
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:@"Lorem ipsum dolor sit amet, consectetur adipisicing elit,\nsed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                                              font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                             color:[UIColor blackColor] 
                                                     lineBreakMode:UILineBreakModeWordWrap 
                                                         alignment:UITextAlignmentLeft 
                                                           andRect:CGRectMake(0, 0, 300, 100)];
    
    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] initWithFirstRect:CGRectMake(0, 0, 300, 20) 
                                                                         andSubsequentRect:CGRectMake(0, 0, 300, 200)];
    NSArray *drawables = [splitter splitDrawable:label];    
    STAssertTrue(drawables.count == 2, @"Should have received two labels in return, but got %i", drawables.count);        
    
    NSString *text = [[drawables objectAtIndex:0] text];    
    STAssertEqualObjects(@"Lorem ipsum dolor sit amet, consectetur adipisicing elit,", text, @"Returned label should have contained the same text as the original but had %@", text);
    
    text = [[drawables objectAtIndex:1] text];
    STAssertEqualObjects(@"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", text, @"Returned label should have contained the same text as the original but had %@", text);
    
    [label release];    
    [splitter release];
}

/*
 * Test an edge case where the text for a label contains no spaces or newlines and is larger than the first rect provided.  It is expected that the
 * label will be split into multiple labels in the middle of the text, since it cannot do it using any spaces or newlines.
 */ 
- (void)testSplittingOfLabel4
{
    MBDrawableLabel *label = [[MBDrawableLabel alloc] initWithText:@"Loremipsumdolorsitametconsecteturadipisicingelitseddoeiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                                              font:[UIFont fontWithName:@"Helvetica" size:12.f] 
                                                             color:[UIColor blackColor] 
                                                     lineBreakMode:UILineBreakModeWordWrap 
                                                         alignment:UITextAlignmentLeft 
                                                           andRect:CGRectMake(0, 0, 300, 100)];
    
    MBDrawableLabelSplitter *splitter = [[MBDrawableLabelSplitter alloc] initWithFirstRect:CGRectMake(0, 0, 300, 20) 
                                                                         andSubsequentRect:CGRectMake(0, 0, 300, 200)];
    NSArray *drawables = [splitter splitDrawable:label];    
    STAssertTrue(drawables.count == 2, @"Should have received two labels in return, but got %i", drawables.count);        
    
    NSString *text = [[drawables objectAtIndex:0] text];    
    STAssertEqualObjects(@"Loremipsumdolorsitametconsecteturadipisicingelitseddo", text, @"Returned label should have had text 'Loremipsumdolorsitametconsecteturadipisicingelitseddo' but had %@", text);
    
    text = [[drawables objectAtIndex:1] text];
    STAssertEqualObjects(@"eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", text, @"Returned label should have contained the text 'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' but had %@", text);
    
    [label release];    
    [splitter release];
}

@end
