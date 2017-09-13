//
//  StratFilesMenuViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-08-11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFilesMenuViewController.h"
#import "DataManager.h"
#import "StratFile.h"
#import "Theme.h"
#import "StratFileManager.h"
#import "UIColor-Expanded.h"
#import "MenuNavController.h"
#import "NSDate-StratPad.h"
#import "NavigationConfig.h"
#import "EditionManager.h"
#import "CustomUpgradeViewController.h"
#import "RootViewController.h"
#import "EventManager.h"
#import "YammerCommentManager.h"
#import "Tracking.h"

#define altColor @"F2F2F2"
#define selColor @"C5DEFD"

@interface StratFilesMenuViewController ()

@end

@implementation StratFilesMenuViewController

@synthesize tableView = tableView_;
@synthesize tableCell = tableCell_;

#pragma mark - Memory Management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // add button
        UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self action:@selector(addStratFile:event:)];
        [addBtnItem setStyle:UIBarButtonItemStyleBordered];
        
        UIBarButtonItem *cloneBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clone"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self action:@selector(cloneStratFile:event:)];
        [cloneBtnItem setStyle:UIBarButtonItemStyleBordered];

        NSArray *items = [NSArray arrayWithObjects:addBtnItem, cloneBtnItem, nil];
        [addBtnItem release];
        [cloneBtnItem release];
        
        [self.navigationItem setRightBarButtonItems:items];
        
        // trash button
        UIBarButtonItem *trashBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(toggleManageMode:event:)];
        [trashBtnItem setStyle:UIBarButtonItemStyleBordered];
        self.navigationItem.leftBarButtonItem = trashBtnItem;        
        [trashBtnItem release];            
        
        // title
        self.navigationItem.title = LocalizedString(@"MY_STRATFILES", nil);
        
        // yammer comments
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateYammerCommentCounts:)
                                                     name:kEVENT_YAMMER_COMMENTS_UPDATED
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc 
{
    [stratFiles_ release];
    [tableCell_ release];
    [tableView_ release];
    
    [super dealloc];    
}


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{    
    [self refreshStratFiles];

    // make sure any changes from outside are reflected
    [tableView_ reloadData];
                
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stratFiles_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    
    StratFilesTableViewCell *cell = (StratFilesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StratFilesTableViewCell"];
    
    if (cell == nil) {
        // not localized
        [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([StratFilesTableViewCell class]) owner:self options:nil];
        cell = tableCell_;
        self.tableCell = nil;       
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    StratFile *stratFile = [stratFiles_ objectAtIndex:[indexPath row]];
    cell.name.text = stratFile.name;
    cell.company.text = stratFile.companyName ? stratFile.companyName : LocalizedString(@"UNNAMED_COMPANY", nil);
    
    // update yammer message count, across networks
    NSUInteger unreadMsgCt = [[YammerCommentManager sharedManager] unreadMessageCountForStratFile:stratFile];
    
    if (unreadMsgCt) {
        DLog(@"Showing badge for row: %i with count: %u", indexPath.row, unreadMsgCt);
        cell.lblUnreadComments.hidden = NO;
        [[cell.lblUnreadComments viewWithTag:789789] removeFromSuperview];
        cell.lblUnreadComments.text = [NSString stringWithFormat:@"%i", unreadMsgCt];

    } else {
        cell.lblUnreadComments.text = nil;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stratFile = %@", stratFile];
        NSUInteger ct = [DataManager countForEntity:NSStringFromClass([YammerPublishedReport class]) predicateOrNil:predicate];
        BOOL hasYammerPubs = ct > 0;
        
        if (hasYammerPubs) {
            cell.lblUnreadComments.hidden = NO;
            // add a yammer icon if empty
            UIImage *img = [UIImage imageNamed:@"yammer-y"];
            UIImageView *view = [[UIImageView alloc] initWithImage:img];
            view.frame = CGRectMake(5, 3, 11, 11);
            view.alpha = 0.7;
            view.tag = 789789;
            [cell.lblUnreadComments addSubview:view];
            [view release];

        } else {
            cell.lblUnreadComments.hidden = YES;
        }
        
    }
    
    if (indexPath.row == 0) {
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.backgroundView.backgroundColor = [UIColor colorWithHexString:selColor];
    }
    else {        
        // alternate row background colors
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.backgroundView.backgroundColor = ([indexPath row] & 1) ? [UIColor colorWithHexString:altColor] : [UIColor whiteColor];
    }
    
    cell.dateLastAccessed.text = [stratFile.dateLastAccessed defaultFormattedDateForLocalTimeZone];
    cell.dateLastAccessed.hidden = NO;

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	   
    // show activity indicator
    StratFilesTableViewCell *cell = (StratFilesTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    UIView *contentView = [cell contentView];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake(contentView.frame.size.width - aSize.width - 10,
                                 (contentView.frame.size.height-aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [contentView addSubview:indicator];
    [indicator startAnimating];
    [indicator release];
    
    // hide date to give room for indicator
    cell.dateLastAccessed.hidden = YES;
    cell.lblUnreadComments.hidden = YES;
      
    // perform action (giving the activity indicator a chance to start animating)
    StratFile *stratFile = [stratFiles_ objectAtIndex:[indexPath row]];
    [self performSelector:@selector(loadStratFile:) withObject:stratFile afterDelay:0.1];    
}

// private - just for delayed load
- (void)loadStratFile:(StratFile*)stratFile
{
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexNone];    
    [(MenuNavController*)self.navigationController dismissMenu];    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // can't delete the open stratfile, which will always be the first row anyway
//    uint openStratFileIndex = [stratFiles_ indexOfObject:[[StratFileManager sharedManager] currentStratFile]];
//    if ([[EditionManager sharedManager] isEffectivelyPremium]) {
//        return ([indexPath row] == openStratFileIndex) ? UITableViewCellEditingStyleNone :UITableViewCellEditingStyleDelete;        
//    } else {
//        // in plus or free mode, disable swipe to delete too
//        return ([indexPath row] == openStratFileIndex) ? UITableViewCellEditingStyleNone : (tableView.editing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone);        
//    }
    
    // disable delete for Free and Plus
    return ([[EditionManager sharedManager] isFeatureEnabled:FeatureDeleteStratFiles]) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        DLog(@"Deleting row %i", row);

        // if it's row 0, load the next stratfile
        // if no stratfile, create an empty one and load that
        if (row == 0) {
            if (stratFiles_.count > 1) {
                // load the next most recent stratfile
                StratFile *stratFile = [stratFiles_ objectAtIndex:1];
                [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexAboutYourStrategy];
                
                // now delete the 0th one
                StratFile *stratFileToDelete = [stratFiles_ objectAtIndex:0];
                [[StratFileManager sharedManager] deleteStratFile:stratFileToDelete];
                
                // update our cache
                [self refreshStratFiles];
                
                // update tableview
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                
            }
            else {
                // deleting the only stratfile, so make a new one
                StratFile *stratFile = [[StratFileManager sharedManager] createManagedEmptyStratFile];
                [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexAboutYourStrategy];
                
                StratFile *stratFileToDelete = [stratFiles_ objectAtIndex:0];
                [[StratFileManager sharedManager] deleteStratFile:stratFileToDelete];
                
                // update our cache
                [self refreshStratFiles];
                
                // update tableview
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
                
            }
        }
        else {
            // nothing special - just delete it
            StratFile *stratFileToDelete = [stratFiles_ objectAtIndex:row];
            [[StratFileManager sharedManager] deleteStratFile:stratFileToDelete];
            
            // update our cache
            [self refreshStratFiles];
            
            // update tableview
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
        }
        
        // redo the stripes
        [self refreshCellBackgrounds];
        
    }
}


#pragma mark - Actions

- (void)toggleManageMode:(id)sender event:(UIEvent*)event
{       
    BOOL canAddStratFiles = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
    
    if (canAddStratFiles) {

        UIBarButtonItem *barBtnItem;
        if (self.tableView.editing) {
            barBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(toggleManageMode:event:)];
            
            [self.tableView setEditing:NO animated:YES];        
        } else {
            barBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleManageMode:event:)];
            
            [self.tableView setEditing:YES animated:YES];        
        }
        
        [barBtnItem setStyle:UIBarButtonItemStyleBordered];
        
        self.navigationItem.leftBarButtonItem = barBtnItem;
        
        [barBtnItem release];
    } else {
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController dismissAllMenus];
        
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];
    }

}

- (void)addStratFile:(id)sender event:(UIEvent*)event
{
    BOOL canAddStratFiles = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
    
    if (canAddStratFiles) {
        StratFile *stratFile = [[StratFileManager sharedManager] createManagedEmptyStratFile];
        [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexAboutYourStrategy];
        
        [self refreshStratFiles];
        
        // because we're sorting on lastAccessed, ascending, make this first row
        [tableView_ insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (tableView_.contentSize.height > tableView_.frame.size.height) {
            [tableView_ flashScrollIndicators];
        }
        
        [self refreshCellBackgrounds];
        
        [Tracking logEvent:kTrackingEventStratfileCreated];
    } else {
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController dismissAllMenus];
        
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];
    }
    
}

- (void)cloneStratFile:(id)sender event:(UIEvent*)event
{
    BOOL canAddStratFiles = [[EditionManager sharedManager] isFeatureEnabled:FeatureAddStratFiles];
    
    if (canAddStratFiles) {
        StratFile *currentStratFile = [[StratFileManager sharedManager] currentStratFile];
        StratFile *clonedStratFile = [[StratFileManager sharedManager] cloneStratFile:currentStratFile];
        [[StratFileManager sharedManager] loadStratFile:clonedStratFile withChapterIndex:ChapterIndexAboutYourStrategy];
        
        [self refreshStratFiles];
        
        // because we're sorting on lastAccessed, ascending, make this first row
        [tableView_ insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (tableView_.contentSize.height > tableView_.frame.size.height) {
            [tableView_ flashScrollIndicators];
        }
        
        [self refreshCellBackgrounds];
        
        [Tracking logEvent:kTrackingEventStratfileCreated];
    } else {
        RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController dismissAllMenus];
        
        CustomUpgradeViewController *upgradeVC = [[CustomUpgradeViewController alloc] init];
        [upgradeVC showPopoverInView:rootViewController.view];
        [upgradeVC release];
    }
    
}



#pragma mark - Private

- (void)refreshStratFiles
{
    [stratFiles_ release]; stratFiles_ = nil;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateLastAccessed" ascending:NO];
    stratFiles_ = [[DataManager arrayForEntity:NSStringFromClass([StratFile class]) sortDescriptorsOrNil:[NSArray arrayWithObject:sortDescriptor]] retain];
}

- (void)refreshCellBackgrounds
{
    if (stratFiles_.count) {
        UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.backgroundView.backgroundColor = [UIColor colorWithHexString:selColor];

    }
    for (uint i=1, ct=[stratFiles_ count]; i<ct; ++i) {
        UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.backgroundView.backgroundColor = (i & 1) ? [UIColor colorWithHexString:altColor] : [UIColor whiteColor];

    }
}

#pragma mark - Notifications

-(void)updateYammerCommentCounts:(NSNotification*)notification
{
    [self.tableView reloadData];
}


@end
