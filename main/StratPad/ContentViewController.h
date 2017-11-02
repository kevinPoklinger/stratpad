//
//  ContentViewController.h
//  StratPad
//
//  Created by Eric on 11-07-27.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileManager.h"
#import "MBDisabledView.h"
#import "LMViewController.h"
#import <MediaPlayer/MediaPlayer.h>

// tag textviews in F2 for easy retrieval
#define TextViewTag 4343

@interface ContentViewController : LMViewController<UITextFieldDelegate,UITextViewDelegate> {
@protected
    StratFileManager *stratFileManager_;
           
    CGFloat originalHeight_;

    MBDisabledView *disabledView_;
    
    // the fields on the page, used to implement next/prev behaviour
    // default impl just retains an empty array
    NSArray *responderChain_;
    
    // if the virtual keyboard is up; important because we don't want to adjust textview sizes and scroll positions when using a physical kb
    BOOL isKeyboardShowing_;
    
    MPMoviePlayerViewController *player;
}

@property(nonatomic,assign,readonly) NSUInteger keyboardHeight;

// chapter to which this VC belongs; changing it will do nothing (except screw things up)
@property(nonatomic,retain) Chapter *chapter;

// 0-based page number in its chapter; don't change it
@property(nonatomic,assign) NSUInteger pageNumber;


// by default does nothing - needs to be overridden
// you should write to the current graphics context with a full page in mind.  The current graphics 
// context will be an active PDF context.  Add PDF pages as necessary, but do not end the context.
- (void)exportToPDF;

// should we disable the page and show a message?
- (BOOL)isEnabled;

- (NSString*)messageWhenDisabled;

// add all the fields in the page
- (void)configureResponderChain;

@end

@interface ContentViewController (Protected)
- (void)addBackgroundImageToView:(UIImage*)backgroundImage;
- (void)addYammerCommentsButtonToView:(UIView*)subview;

// shows a video controller in place of the content view
- (void)playHelpVideo:(UIButton*)button;

// do we have a video for this piece of content? default is NO
-(BOOL)hasVideo;

// the url of the video to play; should be youtube
-(NSString*)helpVideoURL;

@end
