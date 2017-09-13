//
//  YammerGroupChooserViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-11.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerGroupChooserViewController.h"
#import "ASIFormDataRequest.h"
#import "SBJSon.h"
#import "YammerGroupCell.h"
#import "YammerManager.h"

@interface YammerGroupChooserViewController ()

@end

@implementation YammerGroupChooserViewController
@synthesize tblGroups;

- (id)initWithYammerGroupChooser:(id<YammerGroupChooser>)yammerGroupChooser andSelectedGroup:(YammerGroup*)group
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Group";
        yammerGroupChooser_ = [yammerGroupChooser retain];
        selectedGroup_ = [group retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set up groups cache
    groups_ = [[NSMutableArray arrayWithCapacity:5] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // send off a request to get some groups
    [[YammerManager sharedManager] fetchGroups:self action:@selector(groupFetchFinished:error:)];    
    
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake((self.view.frame.size.width - aSize.width)/2,
                                 (self.view.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
    [indicator release];

}

- (void)viewDidUnload
{
    [self setTblGroups:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [groups_ release];
    [selectedGroup_ release];
    [yammerGroupChooser_ release];
    [tblGroups release];
    [super dealloc];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

#pragma mark - yammer

-(void)groupFetchFinished:(NSArray*)groups error:(NSError*)error
{
    DLog(@"groups: %@", groups);

    [groups_ removeAllObjects];
    if (!error) {
        NSMutableArray *paths = [NSMutableArray arrayWithCapacity:groups_.count];
        [groups_ addObjectsFromArray:groups];
        for (int i=0; i<groups_.count; ++i) {
            [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        if (paths.count) {
            [tblGroups insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        }

    } else {
        // error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"YAMMER_FETCH_ERROR_TITLE", nil)
                                                            message:[NSString stringWithFormat:LocalizedString(@"YAMMER_FETCH_GROUPS_ERROR", nil), error.localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];

    }
    
    // remove activity indicator
    [[[self.view subviews] lastObject] removeFromSuperview];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // toggle the checkmark - nil group is valid, 1 group max
    
    NSArray *visibleCellPaths = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleCellPaths) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    YammerGroupCell *cell = (YammerGroupCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    cell.accessoryType = isSelected ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    
    [yammerGroupChooser_ groupChosen:cell.group];

    [selectedGroup_ release];
    selectedGroup_ = [cell.group retain];
    
    // save selected group and pre-populate next time
    [[YammerManager sharedManager] savePreferredGroup:selectedGroup_];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [groups_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *cellIdentifier = @"GroupCell";
    YammerGroupCell *cell = [tblGroups dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[YammerGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    YammerGroup *group = [groups_ objectAtIndex:indexPath.row];
    cell.group = group;
    
    cell.textLabel.text = group.groupName;
    
    cell.accessoryType = group.groupId == selectedGroup_.groupId ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    return cell;
}


@end
