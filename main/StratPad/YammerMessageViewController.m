//
//  YammerMessageViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerMessageViewController.h"
#import "YammerMessageBuilderViewController.h"

@interface YammerMessageViewController ()

@end

@implementation YammerMessageViewController
@synthesize textView=textView_;

- (id)initWithYammerMessageEditorContainer:(YammerMessageBuilderViewController*)messageEditorContainer 
                                   message:(NSString*)message
                           placeholderText:(NSString*)placeholderText
                                    action:(SEL)action
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        messageEditorContainer_ = [messageEditorContainer retain];
        message_ = [message retain];
        placeholderText_ = [placeholderText retain];
        action_ = action;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    textView_.placeholder = placeholderText_;
    textView_.delegate = self;
    textView_.text = message_;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [textView_ becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

- (void)dealloc {
    [placeholderText_ release];
    [message_ release];
    [messageEditorContainer_ release];
    [textView_ release];
    [super dealloc];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [messageEditorContainer_ performSelector:action_ withObject:textView.text];
}

@end
