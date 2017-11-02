//
//  YammerMessageViewController.h
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPlaceHolderTextView.h"

@class YammerMessageBuilderViewController;

@interface YammerMessageViewController : UIViewController<UITextViewDelegate> {
    YammerMessageBuilderViewController *messageEditorContainer_;
    NSString *message_;
    NSString *placeholderText_;
    SEL action_;
}

- (id)initWithYammerMessageEditorContainer:(YammerMessageBuilderViewController*)messageEditorContainer 
                                   message:(NSString*)message
                           placeholderText:(NSString*)placeholderText
                                    action:(SEL)action;

@property (retain, nonatomic) IBOutlet MBPlaceHolderTextView *textView;

@end
