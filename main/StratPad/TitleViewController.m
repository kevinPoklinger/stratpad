//
//  TitleViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-06.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "TitleViewController.h"
#import "StratFileManager.h"

@interface TitleViewController ()

@end

@implementation TitleViewController
@synthesize textView;

- (id)initWithChart:(Chart*)chart andTitleChooser:(id<TitleChooser>)titleChooser;
{
    self = [super initWithNibName:NSStringFromClass([TitleViewController class]) bundle:nil];
    if (self) {
        chart_ = chart;
        titleChooser_ = titleChooser;
        self.title = LocalizedString(@"CHART_TITLE", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    textView.delegate = self;
    textView.text = chart_.title;
    textView.placeholder = LocalizedString(@"CHART_NO_TITLE", nil);
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [textView becomeFirstResponder];
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    chart_.title = textView.text;
    [[StratFileManager sharedManager] saveCurrentStratFile];
    [titleChooser_ titleChosen];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return self.view.bounds.size;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    if([text isEqualToString:@"\n"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [textView release];
    [super dealloc];
}
@end
