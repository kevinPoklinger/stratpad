//
//  YammerNetworkChooserViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerNetworkChooserViewController.h"
#import "YammerManager.h"
#import "YammerNetworkCell.h"

@interface YammerNetworkChooserViewController ()

@end

@implementation YammerNetworkChooserViewController
@synthesize tblNetworks;

- (id)initWithYammerNetworkChooser:(id<YammerNetworkChooser>)yammerNetworkChooser andSelectedNetwork:(YammerNetwork*)network
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = LocalizedString(@"YAMMER_NETWORK", nil);
        yammerNetworkChooser_ = [yammerNetworkChooser retain];
        selectedNetwork_ = [network retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set up networks cache
    networks_ = [[NSMutableArray arrayWithCapacity:5] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // send off a request to get some networks
    [[YammerManager sharedManager] fetchNetworks:self action:@selector(networkFetchFinished:error:)];    
    
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
    [self setTblNetworks:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [networks_ release];
    [selectedNetwork_ release];
    [yammerNetworkChooser_ release];
    [tblNetworks release];
    [super dealloc];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

#pragma mark - yammer

-(void)networkFetchFinished:(NSArray*)networks error:(NSError*)error
{
    DLog(@"networks: %@", networks);
    
    [networks_ removeAllObjects];
    if (!error) {
        NSMutableArray *paths = [NSMutableArray arrayWithCapacity:networks_.count];
        [networks_ addObjectsFromArray:networks];
        for (int i=0; i<networks_.count; ++i) {
            [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        if (paths.count) {
            [tblNetworks insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        }
        
    } else {
        // error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"YAMMER_FETCH_ERROR_TITLE", nil)
                                                            message:[NSString stringWithFormat:LocalizedString(@"YAMMER_FETCH_NETWORKS_ERROR", nil), error.localizedDescription]
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
    // toggle the checkmark - nil network is not valid, 1 network max
        
    // reset checkmarks
    NSArray *visibleCellPaths = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleCellPaths) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // set checkmark
    YammerNetworkCell *cell = (YammerNetworkCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    cell.accessoryType = isSelected ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    
    // notify
    [yammerNetworkChooser_ networkChosen:cell.network];
    
    [selectedNetwork_ release];
    selectedNetwork_ = cell.network;
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [networks_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *cellIdentifier = @"NetworkCell";
    YammerNetworkCell *cell = [tblNetworks dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[YammerNetworkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    YammerNetwork *network = [networks_ objectAtIndex:indexPath.row];
    cell.network = network;
    
    cell.textLabel.text = network.name;
    
    cell.accessoryType = network.networkId == selectedNetwork_.networkId ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    return cell;
}

@end
