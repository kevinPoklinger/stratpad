//
//  ActivityViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 18, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityViewController.h"
#import "Activity.h"
#import "Frequency.h"
#import "NSDate-StratPad.h"
#import "NSNumber-StratPad.h"
#import "EventManager.h"
#import "DataManager.h"
#import "Responsible.h"
#import "NSString-Expanded.h"
#import "UIColor-Expanded.h"
#import "EditionManager.h"
#import "SkinManager.h"
#import "PermissionChecker.h"

@interface ActivityViewController ()
@property (nonatomic,retain) PermissionChecker *permissionChecker;
@end


@implementation ActivityViewController

@synthesize lblTitle = lblTitle_;
@synthesize lblSubTitle = lblSubTitle_;
@synthesize lblInstructions = lblInstructions_;
@synthesize lblTheme = lblTheme_;
@synthesize btnTheme = btnTheme_;
@synthesize lblObjective = lblObjective_;
@synthesize btnObjective = btnObjective_;
@synthesize roundedRectView = roundedRectView_;
@synthesize tblActivities = tblActivities_;
@synthesize tableHeaderView = tableHeaderView_;
@synthesize tableCell = tableCell_;
@synthesize btnItemManage = btnItemManage_;
@synthesize btnItemAdd = btnItemAdd_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme andObjectiveOrNil:(Objective*)objective
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        theme_ = [theme retain];
        objective_ = [objective retain];
        
        PermissionChecker *checker = [[PermissionChecker alloc] initWithStratFile:theme.stratFile];
        self.permissionChecker = checker;
        [checker release];
    }
    return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    [_permissionChecker release];
    [objectiveDropDownController_ release];
    [themeDropDownController_ release];
    [lblTitle_ release];
    [lblSubTitle_ release];
    [lblInstructions_ release];
    [roundedRectView_ release];
    [lblTheme_ release];
    [btnTheme_ release];
    [lblObjective_ release];
    [btnObjective_ release];    
    [tblActivities_ release];
    [detailController_ release];
    [noRowsTableDataSource_ release];
    [activities_ release];
    [theme_ release];
    [objective_ release];
    
    [_toolbar release];
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    SkinManager *skinMan = [SkinManager sharedManager];
    
    tblActivities_.clipsToBounds = YES;
    
    self.roundedRectView.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];
    
    self.lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize forMediaType:MediaTypeScreen];
    self.lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor forMediaType:MediaTypeScreen];
    
    self.lblSubTitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize forMediaType:MediaTypeScreen];
    self.lblSubTitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor forMediaType:MediaTypeScreen];

    self.lblInstructions.backgroundColor = [skinMan colorForProperty:kSkinSection2InfoBoxBackgroundColor forMediaType:MediaTypeScreen];
    self.lblInstructions.strokeColor = [skinMan colorForProperty:kSkinSection2InfoBoxStrokeColor forMediaType:MediaTypeScreen];
    self.lblInstructions.font = [skinMan fontWithName:kSkinSection2InfoBoxFontName andSize:kSkinSection2InfoBoxFontSize forMediaType:MediaTypeScreen];
    self.lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2InfoBoxFontColor forMediaType:MediaTypeScreen];

    self.lblTheme.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];
    self.lblObjective.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor forMediaType:MediaTypeScreen];

    self.btnTheme.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];
    self.btnTheme.label.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    
    self.btnObjective.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor forMediaType:MediaTypeScreen];
    self.btnObjective.label.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor forMediaType:MediaTypeScreen];
    
    self.tblActivities.backgroundColor = [UIColor clearColor];
    [self.tblActivities setSeparatorColor:[UIColor clearColor]];
    
    if (!themeDropDownController_) {
        themeDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.btnTheme andSelectedValueOrNil:theme_];
        themeDropDownController_.delegate = self;        
    }
    
    if (!objectiveDropDownController_) {
        objectiveDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.btnObjective andSelectedValueOrNil:objective_];
        objectiveDropDownController_.delegate = self;        
    }
    
    // if there are no activities
    BOOL isWritable = [stratFileManager_.currentStratFile isWritable:UserTypeOwner];
    NSString *noRowsTitle = isWritable ? LocalizedString(@"ADD_ACTIVITY_ROW", nil) : LocalizedString(@"ADD_ACTIVITY_ROW_DISABLED", nil);
    noRowsTableDataSource_ = [[NoRowsTableDataSource alloc] initWithTitle:noRowsTitle];
    
    [self loadActivities];
    
    if ([activities_ count] == 0) {
        tblActivities_.dataSource = noRowsTableDataSource_;        
    } else {
        tblActivities_.dataSource = self;
    }
    
    [self.tblActivities reloadData];
    
    // load the values for the theme drop down
    [themeDropDownController_ removeAllDropDownValues];
    NSArray *sortedThemes = [stratFileManager_.currentStratFile themesSortedByOrder];
    for (Theme *theme in sortedThemes) {
        [themeDropDownController_ addDropDownValue:theme withDisplayValue:theme.title];
    }        
    
    // reload the values for the objective drop down
    [objectiveDropDownController_ removeAllDropDownValues];
    NSArray *sortedObjectives = [objective_.theme objectivesSortedByOrder];
    
    for (Objective *objective in sortedObjectives) {            
        [objectiveDropDownController_ addDropDownValue:objective withDisplayValue:objective.summary];
    }
    
    self.btnTheme.label.text = theme_.title;
    self.btnObjective.label.text = objective_.summary;        
            
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    viewDisappearing_ = NO;
        
    [super viewWillAppear:animated];
    [_toolbar setNeedsLayout];
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [activities_ count];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityTableViewCell *cell = (ActivityTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];
    
    if (cell == nil) {
        [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"ActivityTableViews" owner:self options:nil];
        cell = tableCell_;
        self.tableCell = nil;        
    }
    
    NSUInteger row = [indexPath row];    
    Activity *activity = [activities_ objectAtIndex:row];
    
    cell.lblAction.text = activity.action;
    cell.lblResponsible.text = activity.responsible.summary;

    if (activity.startDate && activity.endDate) {
        cell.lblDateRange.text = [NSString stringWithFormat:@"%@ - %@", 
                                  [activity.startDate formattedDateForDateSelection], [activity.endDate formattedDateForDateSelection]];    
    } else if (activity.startDate) {
        cell.lblDateRange.text = [NSString stringWithFormat:@"%@ -", [activity.startDate formattedDateForDateSelection]];
        
    } else if (activity.endDate) {
        cell.lblDateRange.text = [NSString stringWithFormat:@"- %@", [activity.endDate formattedDateForDateSelection]];
        
    } else {
        cell.lblDateRange.text = @"";
    }    
    
    cell.lblUpfrontCost.text = [activity.upfrontCost decimalFormattedNumberWithZeroDisplay:NO];

    NSString *ongoingCost = @"";
    if (activity.ongoingCost && activity.ongoingFrequency) {
        ongoingCost = [NSString stringWithFormat:@"%@/%@", [activity.ongoingCost decimalFormattedNumberWithZeroDisplay:NO], [activity.ongoingFrequency abbreviationForCurrentLocale]];
        
    } else if (activity.ongoingCost) {
        ongoingCost = [activity.ongoingCost decimalFormattedNumberWithZeroDisplay:NO];
        
    } 

    cell.lblOngoingCost.text = ongoingCost;
    
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
        // activities with orders less than or equal to the new position.
        Activity *activity;
        for (int i = oldPosition; i <= newPosition; i++) {
            activity = [activities_ objectAtIndex:i];
            activity.order = [NSNumber numberWithInt:([activity.order intValue] - 1)];
        }
        
    } else if (oldPosition > newPosition) {
        // user moved the cell up, so increase the order of those
        // activities with orders greater than or equal to the new position.
        Activity *activity;
        for (int i = newPosition; i <= oldPosition; i++) {
            activity = [activities_ objectAtIndex:i];
            activity.order = [NSNumber numberWithInt:([activity.order intValue] + 1)];
        }
        
    } 
    
    Activity *movedActivity = [activities_ objectAtIndex:oldPosition];
    movedActivity.order = [NSNumber numberWithInt:newPosition];
    
    [stratFileManager_ saveCurrentStratFile];
    
    // don't have to reload the table, but have to reload the model so its ordering is updated.
    [self loadActivities];
    
    [EventManager fireActivitiesReorderedEvent];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24+10; // the height of rounded rect view in ActivityTableViews.xib
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"ActivityTableViews" owner:self options:nil];
    return tableHeaderView_;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite]) {
        if ([activities_ count] == 0) {
            Activity *activity = [self createActivity];
            [self showActivityDetailViewFromView:tableView withActivity:activity];
        } else {
            Activity *activity = [activities_ objectAtIndex:[indexPath row]];
            [self showActivityDetailViewFromView:[tableView cellForRowAtIndexPath:indexPath] withActivity:activity];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];    
        Activity *activity = [activities_ objectAtIndex:row];
        [activities_ removeObject:activity];
        [DataManager deleteManagedInstance:activity];        
        [self.tblActivities deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // update the order of each activity to for good measure, since a gap will have been created by 
        // the deletion.
        for (int i = 0; i < activities_.count; i++) {
            ((Activity*)[activities_ objectAtIndex:i]).order = [NSNumber numberWithInt:i];             
        }
        
        [stratFileManager_ saveCurrentStratFile];
        [EventManager fireActivityDeletedEvent];
        
        // if we deleted last row, put in the add theme row
        if ([activities_ count] == 0) {
            tblActivities_.dataSource = noRowsTableDataSource_;
            [tblActivities_ reloadData];
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

- (IBAction)addActivity:(id)sender event:(UIEvent*)event
{
    if ([_permissionChecker checkReadWrite]) {
        Activity *activity = [self createActivity];
        [self showActivityDetailViewFromView:[[event.allTouches anyObject] view] withActivity:activity];
    }
}

- (IBAction)toggleManageMode:(id)sender
{    
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (self.tblActivities.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblActivities setEditing:NO animated:YES];        
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [self.tblActivities setEditing:YES animated:YES];        
        }
    }
}


#pragma mark - DropDownDelegate

- (void)valueSelected:(id)value forDropDownButton:(MBDropDownButton *)button
{
    if (button == self.btnTheme) {
        [EventManager fireJumpToThemeEventWithTheme:(Theme*)value fromViewController:self];
    } else {
        [EventManager fireJumpToObjectiveEventWithObjective:(Objective*)value fromViewController:self];
    }
}


#pragma mark - ActivityDetailDelegate

- (void)editingCompleteForActivity:(Activity *)activity
{
    [self hideActivityDetailView];
    
    if (!activity.action || [activity.action isBlank]) {
        activity.action = LocalizedString(@"UNNAMED_ACTIVITY", nil);
        [stratFileManager_ saveCurrentStratFile];
    }
    
    BOOL isNew = ![activities_ containsObject:activity];
    if (isNew) {        
        // new theme, so we need assign it an order of theme count
        activity.order = [NSNumber numberWithInt:[activities_ count]];
        [stratFileManager_ saveCurrentStratFile];
        [EventManager fireActivityCreatedEvent];
    }    
    
    // load up the cached array
    [self loadActivities];

    // may have to switch datasources
    // have to be careful because norows has 1 row, so the first time we have a real row, we need to reloadData instead of insertRows
    BOOL isFirst = (self.tblActivities.dataSource != self);
    if (isFirst) {
        self.tblActivities.dataSource = self;        
        [self.tblActivities reloadData];
    }
    
    // find the appropriate row
    NSUInteger idx = [activities_ indexOfObject:activity];
    if (idx != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        if (!isFirst) {
            if (isNew) {
                [self.tblActivities insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {            
                [self.tblActivities reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                          withRowAnimation:UITableViewRowAnimationNone];
            }            
        }
        
        // it's not selected anymore after being reloaded, so select it again
        NSArray *visCellPaths = [self.tblActivities indexPathsForVisibleRows];
        if ([visCellPaths indexOfObject:indexPath] != NSNotFound) {
            [self.tblActivities selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];            
        } else {
            [self.tblActivities selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }

        [self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.5];
    }
}

-(void)deselectRow:(NSIndexPath*)indexPath
{
    [self.tblActivities deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private

- (Activity*)createActivity
{
    Activity *activity = (Activity*)[DataManager createManagedInstance:NSStringFromClass([Activity class])];
    activity.order = [NSNumber numberWithInt:[activities_ count]];
    activity.ongoingFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    [objective_ addActivitiesObject:activity];
    [stratFileManager_ saveCurrentStratFile];
    [EventManager fireActivityCreatedEvent];
    return activity;
}

- (void)loadActivities
{    
    [activities_ release];
    activities_ = [[objective_ activitiesSortedByOrder] retain];    
}

- (void)showActivityDetailViewFromView:(UIView*)view withActivity:(Activity*)activity
{
    detailController_ = [[ActivityDetailViewController alloc] initWithNibName:nil bundle:nil andActivity:activity];
    detailController_.delegate = self;

    UIView *detailView = detailController_.view;
    detailView.center = [self.roundedRectView convertPoint:view.center toView:self.view];
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

- (void)hideActivityDetailView
{
    UIView *detailView = detailController_.view;    
    
    // just hide it straight away if we are swiping away from the page
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

#pragma mark - overrides

- (BOOL)isEnabled
{
    return theme_ != nil && objective_ != nil;
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_OBJECTIVES", nil);
}

# pragma mark - Help Video

// @override
-(BOOL)hasVideo
{
    return [[[LocalizedManager sharedManager] localeIdentifier] hasPrefix:@"en"];
}

// @override
-(NSString*)helpVideoURL
{
    //return @"http://player.vimeo.com/external/70704416.m3u8?p=high,standard,mobile&s=f4dad522cc2e0dc38cf631e7d64fe90a";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F7" ofType:@"mp4"];
    return path;
}



@end
