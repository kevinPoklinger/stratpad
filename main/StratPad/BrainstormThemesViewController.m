//
//  BrainstormThemesViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 5, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "BrainstormThemesViewController.h"
#import "StratFileManager.h"
#import "EventManager.h"
#import "DataManager.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString-Expanded.h"
#import "UIColor-Expanded.h"
#import "CustomUpgradeViewController.h"
#import "RootViewController.h"
#import "SkinManager.h"
#import "PermissionChecker.h"


@interface BrainstormThemesViewController ()
@property (nonatomic,retain) PermissionChecker *permissionChecker;
@end


@implementation BrainstormThemesViewController

@synthesize lblTitle = lblTitle_;
@synthesize lblSubTitle = lblSubTitle_;
@synthesize roundedRectView = roundedRectView_;
@synthesize tblThemes = tblThemes_;
@synthesize tableHeaderView = tableHeaderView_;
@synthesize tableCell = tableCell_;
@synthesize lblBodyText1 = lblBodyText1_;
@synthesize lblBodyText2 = lblBodyText2_;
@synthesize btnItemManage = btnItemManage_;
@synthesize btnItemAdd = btnItemAdd_;

#pragma mark - Memory Management

- (void)dealloc
{
    [_permissionChecker release];
    [lblTitle_ release];
    [lblSubTitle_ release];
    [lblBodyText1_ release];
    [lblBodyText2_ release];
    [roundedRectView_ release];
    [tblThemes_ release];
    [sortedThemes_ release];
    [detailController_ release];
    [noRowsTableDataSource_ release];
    [btnItemManage_ release];
    [btnItemAdd_ release];
    
    [_themeToolBar release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tblThemes_.clipsToBounds = YES;
    
    StratFile *stratFile = [StratFileManager sharedManager].currentStratFile;

    PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:stratFile];
    self.permissionChecker = checker;
    [checker release];
    
    SkinManager *skinMan = [SkinManager sharedManager];
        
    self.roundedRectView.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    self.lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];

    self.lblSubTitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    self.lblSubTitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];

    self.lblBodyText1.font = [skinMan fontWithName:kSkinSection2BodyFontName andSize:kSkinSection2BodyFontSize];
    self.lblBodyText1.textColor = [skinMan colorForProperty:kSkinSection2BodyFontColor];
    
    self.lblBodyText2.font = [skinMan fontWithName:kSkinSection2BodyFontName andSize:kSkinSection2BodyFontSizeSmall];
    self.lblBodyText2.textColor = [skinMan colorForProperty:kSkinSection2BodyFontColor];

    
    self.tblThemes.backgroundColor = [UIColor clearColor];
    [self.tblThemes setSeparatorColor:[UIColor clearColor]];
    noRowsTableDataSource_ = [[NoRowsTableDataSource alloc] initWithTitle:LocalizedString(@"ADD_NEW_THEME", nil)];
    
    [self loadThemes];
    
//    BOOL isWritable = [stratFile isWritable:UserTypeOwner];
//    self.tblThemes.allowsSelection = isWritable;
    
    if ([sortedThemes_ count] == 0) {
        tblThemes_.dataSource = noRowsTableDataSource_;        
    } else {
        tblThemes_.dataSource = self;
    }
    
    [self.tblThemes reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    viewDisappearing_ = NO;
    [_themeToolBar setNeedsLayout];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    viewDisappearing_ = YES;        
    
    // ensure we wrap things up with the detail controller
    if (detailController_) {                
        [detailController_ done];
    }
    
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedThemes_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeTableViewCell *cell = (ThemeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ThemeTableViewCell"];
    
    if (cell == nil) {
        [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"ThemeTableViews" owner:self options:nil];		
        cell = tableCell_;
        self.tableCell = nil;           
    }
        
    Theme *theme = [sortedThemes_ objectAtIndex:[indexPath row]];  
    
    cell.lblTitle.text = theme.title;
    cell.lblMandatory.text = [theme.mandatory boolValue] ? LocalizedString(@"YES", nil) : LocalizedString(@"NO", nil);
    cell.lblEnhanceUniqueness.text = [theme.enhanceUniqueness boolValue] ? LocalizedString(@"YES", nil) : LocalizedString(@"NO", nil);
    cell.lblEnhanceCustomerValue.text = [theme.enhanceCustomerValue boolValue] ? LocalizedString(@"YES", nil) : LocalizedString(@"NO", nil);
    
    return cell;                
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger oldPosition = [fromIndexPath row];
    NSUInteger newPosition = [toIndexPath row];
    
    if (oldPosition == newPosition) {
        // don't care if nothing has changed order wise.
        return;
    }
    
    if (oldPosition < newPosition) {
        // user moved the cell down, so decrease the order of those
        // themes with orders less than or equal to the new position.
        Theme *theme;
        for (int i = oldPosition; i <= newPosition; i++) {
            theme = [sortedThemes_ objectAtIndex:i];
            theme.order = [NSNumber numberWithInt:([theme.order intValue] - 1)];
        }
                
    } else if (oldPosition > newPosition) {
        // user moved the cell up, so increase the order of those
        // themes with orders greater than or equal to the new position.
        Theme *theme;
        for (int i = newPosition; i <= oldPosition; i++) {
            theme = [sortedThemes_ objectAtIndex:i];
            theme.order = [NSNumber numberWithInt:([theme.order intValue] + 1)];
        }
                
    } 
    
    Theme *movedTheme = [sortedThemes_ objectAtIndex:oldPosition];
    movedTheme.order = [NSNumber numberWithInt:newPosition];    

    [stratFileManager_ saveCurrentStratFile];
    
    // don't have to reload the table, but have to reload the model so its ordering is updated.
    [self loadThemes];
    
    [EventManager fireThemesReorderedEvent];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80; // the height of the rounded rect view in ThemeTableViews.xib
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"ThemeTableViews" owner:self options:nil];
    return tableHeaderView_;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite]) {
        if ([sortedThemes_ count] == 0) {
            Theme *theme = [self createTheme];
            [self showThemeOptionsViewFromView:tableView withTheme:theme];
        } else {
            Theme *theme = [sortedThemes_ objectAtIndex:[indexPath row]];
            [self showThemeOptionsViewFromView:[tableView cellForRowAtIndexPath:indexPath] withTheme:theme];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];    
        Theme *theme = [sortedThemes_ objectAtIndex:row];
        [sortedThemes_ removeObject:theme];
        [DataManager deleteManagedInstance:theme];        
        [self.tblThemes deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // update the order of each theme to for good measure, since a gap will have been created by 
        // the deletion.
        for (int i = 0; i < sortedThemes_.count; i++) {
            ((Theme*)[sortedThemes_ objectAtIndex:i]).order = [NSNumber numberWithInt:i];             
        }
        
        [stratFileManager_ saveCurrentStratFile];
        [EventManager fireThemeDeletedEvent];
        
        // if we deleted last row, put in the add theme row
        if ([sortedThemes_ count] == 0) {
            tblThemes_.dataSource = noRowsTableDataSource_;
            [tblThemes_ reloadData];
        }
    }    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Actions

- (IBAction)addTheme:(id)sender event:(UIEvent*)event
{
    if ([_permissionChecker checkReadWrite]) {
        Theme *theme = [self createTheme];    
        [self showThemeOptionsViewFromView:[[event.allTouches anyObject] view] withTheme:theme];
    }
}

- (IBAction)toggleManageMode:(id)sender
{    
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (self.tblThemes.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblThemes setEditing:NO animated:YES];        
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [self.tblThemes setEditing:YES animated:YES];        
        }

    }
}

- (IBAction)expandThemesTable:(id)sender event:(UIEvent*)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch tapCount] == 2) {
        if (expanded_) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect f = roundedRectView_.frame;
                roundedRectView_.frame = CGRectMake(f.origin.x, 125 + expandedBy_, f.size.width, f.size.height-expandedBy_);            
                expanded_ = NO;                
            }];
            
        } 
        else {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect f = roundedRectView_.frame;
                expandedBy_ = f.origin.y - 125;
                roundedRectView_.frame = CGRectMake(f.origin.x, 125, f.size.width, f.size.height+expandedBy_);
                expanded_ = YES;                
            }];
        }
    }
}


#pragma mark - ThemeOptionsDelegate

- (void)editingCompleteForTheme:(Theme *)theme
{
    [self hideThemeOptionsView];
    
    if (!theme.title || [theme.title isBlank]) {
        theme.title = LocalizedString(@"UNNAMED_THEME", nil);
        [stratFileManager_ saveCurrentStratFile];
    }

    BOOL isNew = ![sortedThemes_ containsObject:theme];
    
    // load up the cached array
    [self loadThemes];
    
    // may have to switch datasources
    // have to be careful because norows has 1 row, so the first time we have a real row, we need to reloadData instead of insertRows
    BOOL isFirst = (self.tblThemes.dataSource != self);
    if (isFirst) {
        self.tblThemes.dataSource = self;        
        [self.tblThemes reloadData];
    }

    // find the appropriate row
    NSUInteger idx = [sortedThemes_ indexOfObject:theme];
    if (idx != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        if (!isFirst) {
            if (isNew) {
                [self.tblThemes insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {            
                [self.tblThemes reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                      withRowAnimation:UITableViewRowAnimationNone];
            }            
        }
        
        // it's not selected anymore after being reloaded, so select it again
        NSArray *visCellPaths = [self.tblThemes indexPathsForVisibleRows];
        if ([visCellPaths indexOfObject:indexPath] != NSNotFound) {
            [self.tblThemes selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];            
        } else {
            [self.tblThemes selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        [self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.5];
    }
}

-(void)deselectRow:(NSIndexPath*)indexPath
{
    [self.tblThemes deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Support

- (Theme*)createTheme
{
    Theme *theme = (Theme*)[DataManager createManagedInstance:NSStringFromClass([Theme class])]; 
    theme.order = [NSNumber numberWithInt:[sortedThemes_ count]];    
    [stratFileManager_.currentStratFile addThemesObject:theme];
    [stratFileManager_ saveCurrentStratFile];    
    [EventManager fireThemeCreatedEvent];
    return theme;
}

- (void)loadThemes
{    
    [sortedThemes_ release];
    sortedThemes_  = [[[StratFileManager sharedManager].currentStratFile themesSortedByOrder] retain];    
}

- (void)showThemeOptionsViewFromView:(UIView*)view withTheme:(Theme*)theme
{
    // detailController_ is released and nil'd in hideThemeOptionsView, and ultimate dealloc.
    [detailController_ release];
    detailController_ = [[ThemeOptionsViewController alloc] initWithNibName:nil bundle:nil andTheme:theme];
    detailController_.delegate = self;
    
    UIView *detailView = detailController_.view;
    detailView.center = [self.tblThemes convertPoint:view.center toView:self.view];
    detailView.transform = CGAffineTransformMakeScale(0.2, 0.2);

    [detailController_ viewWillAppear:YES];
    [self.view addSubview:detailView];

    [UIView animateWithDuration:0.2
                     animations:^{
                         detailView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
                         detailView.transform = CGAffineTransformMakeScale(1.0, 1.0);                         
                     } completion:^(BOOL finished) {                         
                         [detailController_ viewDidAppear:YES];
                     }
     ];    
}

- (void)hideThemeOptionsView
{
    UIView *detailView = detailController_.view;    
    
    // just close the detailview if we swiped away
    if (viewDisappearing_) {
        [detailController_ viewWillDisappear:NO];
        [detailView removeFromSuperview];                         
        [detailController_ viewDidDisappear:NO];
        [detailController_ release], detailController_ = nil;

    } else {
        [detailController_ viewWillDisappear:YES];

        [UIView animateWithDuration:0.2
                         animations:^{
                             detailView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                         } completion:^(BOOL finished) {
                             [detailView removeFromSuperview];                         
                             [detailController_ viewDidDisappear:YES];
                             [detailController_ release], detailController_ = nil;
                         }
         ];        
    } 
}

#pragma mark - Help Video

-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70581330.m3u8?p=high,standard,mobile&s=f57657c30309267c77f3226774a2431c";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F4.mov" ofType:@"mp4"];
    return path;
}


@end
