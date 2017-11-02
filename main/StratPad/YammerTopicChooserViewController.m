//
//  YammerTopicChooserViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerTopicChooserViewController.h"
#import "SBJSon.h"

@interface YammerTopicChooserViewController ()

@end

@implementation YammerTopicChooserViewController

- (id)initWithYammerTopicChooser:(id<YammerTopicChooser>)yammerTopicChooser
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Topic";
        yammerTopicChooser_ = [yammerTopicChooser retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set up topics cache
    [topics_ release];
    topics_ = nil;
    topics_ = [[NSMutableArray arrayWithCapacity:5] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // send off a request to get some topics
    [topics_ removeAllObjects];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [yammerTopicChooser_ release];
    [super dealloc];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}


@end
