//
//  DefineObjectivesViewController.m
//  StratPad
//
//  Created by Eric Rogers on August 16, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DefineObjectivesViewController.h"
#import "Theme.h"
#import "Objective.h"
#import "ObjectiveType.h"
#import "Frequency.h"
#import "DataManager.h"
#import "EventManager.h"
#import "NSDate-StratPad.h"
#import "NSString-Expanded.h"
#import "Metric.h"
#import "UIColor-Expanded.h"
#import "EditionManager.h"
#import "RootViewController.h"
#import "PermissionChecker.h"


@interface DefineObjectivesViewController ()
- (IBAction)addObjective:(id)sender event:(UIEvent*)event;
- (IBAction)toggleManageMode:(id)sender;

@property (nonatomic,retain) PermissionChecker *permissionChecker;

@end

@implementation DefineObjectivesViewController

@synthesize btnItemAdd = btnItemAdd_;
@synthesize btnItemManage = btnItemManage_;

@synthesize lblTitle = lblTitle_;
@synthesize lblSubTitle = lblSubTitle_;

@synthesize lblInstructions = lblInstructions_;

@synthesize lblTheme = lblTheme_;
@synthesize btnTheme = btnTheme_;

@synthesize tblObjectives = tblObjectives_;

@synthesize roundedRectView = roundedRectView_;

@synthesize headingTableCell = headingTableCell_;
@synthesize tableCell = tableCell_;
@synthesize addObjectiveTableCell = addObjectiveTableCell_;

@synthesize headerView = headerView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andThemeOrNil:(Theme*)theme
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        theme_ = [theme retain];
        
        objectiveGroups_ = [[NSMutableArray array] retain];
        
        objectiveTypes_ = [[NSArray arrayWithObjects:
                           [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryFinancial], 
                           [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryCustomer], 
                           [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryProcess], 
                           [ObjectiveType objectiveTypeForCategory:ObjectiveCategoryStaff],
                           nil] retain];
        
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
    [theme_ release];
    
    [btnItemAdd_ release];
    [btnItemManage_ release];
    
    [lblTitle_ release];
    [lblSubTitle_ release];
    
    [lblInstructions_ release];
    [roundedRectView_ release];
    
    [lblTheme_ release];
    [btnTheme_ release];
    
    [tblObjectives_ release];
    
    [objectiveGroups_ release];
    [objectiveTypes_ release];
    
    [themeDropDownController_ release];
    [detailController_ release];
    
    [_toolbar release];
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    SkinManager *skinMan = [SkinManager sharedManager];
    self.roundedRectView.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    self.lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    self.lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];

    self.lblSubTitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    self.lblSubTitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    self.lblInstructions.backgroundColor = [skinMan colorForProperty:kSkinSection2InfoBoxBackgroundColor];
    self.lblInstructions.strokeColor = [skinMan colorForProperty:kSkinSection2InfoBoxStrokeColor];
    self.lblInstructions.font = [skinMan fontWithName:kSkinSection2InfoBoxFontName andSize:kSkinSection2InfoBoxFontSize];
    self.lblInstructions.textColor = [skinMan colorForProperty:kSkinSection2InfoBoxFontColor];
    
    self.lblTheme.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
    
    self.btnTheme.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    self.btnTheme.label.textColor = [skinMan colorForProperty:kSkinSection2TextValueFontColor];
    
    self.tblObjectives.backgroundColor = [UIColor clearColor];
    self.tblObjectives.opaque = NO;
    [self.tblObjectives setSeparatorColor:[UIColor clearColor]];
    tblObjectives_.clipsToBounds = YES;
    
    if (!themeDropDownController_) {
        themeDropDownController_ = [[MBDropDownController alloc] initWithDropDownButton:self.btnTheme andSelectedValueOrNil:theme_];
        themeDropDownController_.delegate = self;        
    }
    
    if (theme_) {        
        self.btnTheme.label.text = theme_.title;        
    }
        
    [self groupAndSortObjectives];
    
    // load the values for the theme drop down
    [themeDropDownController_ removeAllDropDownValues];
    NSArray *sortedThemes = [stratFileManager_.currentStratFile themesSortedByOrder];
    for (Theme *theme in sortedThemes) {
        [themeDropDownController_ addDropDownValue:theme withDisplayValue:theme.title];
    }  
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [objectiveTypes_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *objectiveGroup = [objectiveGroups_ objectAtIndex: section];
    return objectiveGroup.count + 1;  // add 1 to account for the first cell (header cell or add objective cell).
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"DefineObjectivesTableViewCells" owner:self options:nil];
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSMutableArray *objectiveGroup = [objectiveGroups_ objectAtIndex:section];
        
    if (row == 0) {
        
        if (objectiveGroup.count == 0) {
            
            // add new objective cell
            AddObjectiveTableViewCell *cell = addObjectiveTableCell_;
            self.addObjectiveTableCell = nil;
            
            // disabled msg if read-only
            ObjectiveType *type = [objectiveTypes_ objectAtIndex:section];
            BOOL isWritable = [stratFileManager_.currentStratFile isWritable:UserTypeOwner];
            cell.lblAddObjective.text = isWritable ? 
                [NSString stringWithFormat:LocalizedString(@"ADD_OBJECTIVE_ROW", nil), [type nameForCurrentLocale]] :
                LocalizedString(@"ADD_OBJECTIVE_DISABLED", nil);
            
            return cell;

        } else {
            
            // headings for a section
            ObjectiveHeaderTableViewCell *cell = headingTableCell_;            
            self.headingTableCell = nil; 
            return cell;
            
        }
        
    } else {
        
        // data cells
        DefineObjectivesTableViewCell *cell = tableCell_;
        self.tableCell = nil;
                
        Objective *objective = [objectiveGroup objectAtIndex:(row - 1)];
        cell.lblDescription.text = objective.summary;
        cell.lblFrequency.text = [objective.reviewFrequency nameForCurrentLocale];
        
        int ct = objective.metrics.count;
        if (ct > 1) {
            // use italics when multiple objectives
            cell.lblMetric.font = [UIFont fontWithName:@"Helvetica-Oblique" size:[[SkinManager sharedManager] fontSizeForProperty:kSkinSection2TableCellMediumFontSize]];
            cell.lblMetric.text = LocalizedString(@"MULTIPLE_METRICS", nil);        
            cell.lblTargetValue.text = nil;
            cell.lblTargetDate.text = nil;
        } else {
            Metric *metric = [objective.metrics anyObject];
            cell.lblMetric.text = metric.summary;        
            cell.lblTargetValue.text = metric.targetValue;
            cell.lblTargetDate.text = [metric.targetDate formattedDateForDateSelection];            
        }
                
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row] > 0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{    
    NSMutableArray *objectives = [objectiveGroups_ objectAtIndex:[sourceIndexPath section]];
    
    // subtract 1 from each to account for the first header row...
    NSUInteger oldPosition = [sourceIndexPath row] - 1;
    NSUInteger newPosition = [destinationIndexPath row] - 1;
    
    if (oldPosition == newPosition) {
        // don't care if nothing has changed order wise.
        return;
    }
    
    if (oldPosition < newPosition) {
        // user moved the cell down, so decrease the order of those
        // themes with orders less than or equal to the new position.
        Objective *objective;
        for (int i = oldPosition; i <= newPosition; i++) {
            objective = [objectives objectAtIndex:i];
            objective.order = [NSNumber numberWithInt:([objective.order intValue] - 1)];
        }
        
    } else if (oldPosition > newPosition) {
        // user moved the cell up, so increase the order of those
        // themes with orders greater than or equal to the new position.
        Objective *objective;
        for (int i = newPosition; i <= oldPosition; i++) {
            objective = [objectives objectAtIndex:i];
            objective.order = [NSNumber numberWithInt:([objective.order intValue] + 1)];
        }        
    } 
    
    Objective *movedObjective = [objectives objectAtIndex:oldPosition];
    movedObjective.order = [NSNumber numberWithInt:newPosition];
    
    [stratFileManager_ saveCurrentStratFile];
    
    // don't have to reload the table, but have to reload the model so its ordering is updated.
    [self groupAndSortObjectives];
        
    [EventManager fireObjectivesReorderedEvent];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];    
    NSArray *objectiveGroup = [objectiveGroups_ objectAtIndex:section];

    if ((row == 0) && (objectiveGroup.count == 0)) {
        // add objective cell.
        return 50;
    } else if (row == 0) {
        // header cell
        return 40;
    } else {
        // objective cell
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [[[LocalizedManager sharedManager] currentBundle] loadNibNamed:@"DefineObjectivesHeaderView" owner:self options:nil];
            
    ObjectiveType *objectiveType = [objectiveTypes_ objectAtIndex:section];
    headerView_.lblObjectiveType.text = [NSString stringWithFormat:@"%@:", [objectiveType nameForCurrentLocale]];
    
    NSString *key = [NSString stringWithFormat:@"OBJECTIVE_INSTRUCTIONS_%@", objectiveType.category];
    headerView_.lblInstructions.text = LocalizedString(key, nil);

    // make sure the objective type label fits the text.
    [headerView_.lblObjectiveType sizeToFit];
    
    // offset the instructions label 5px to the right of the objective type label.
    headerView_.lblInstructions.frame = CGRectMake(headerView_.lblObjectiveType.frame.origin.x + headerView_.lblObjectiveType.frame.size.width + 5 , 
                                                  headerView_.lblInstructions.frame.origin.y + 2, // manual tweak 
                                                  headerView_.lblInstructions.frame.size.width, 
                                                  headerView_.lblInstructions.frame.size.height);
    
    return headerView_;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_permissionChecker checkReadWrite]) {
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];    
        NSArray *objectiveGroup = [objectiveGroups_ objectAtIndex:section];
        
        if ((row == 0) && (objectiveGroup.count == 0)) {
            // allows the creation of an objective after the user taps the Add Objective cell for a given section.
            ObjectiveType *objectiveType = [objectiveTypes_ objectAtIndex:section];
            Objective *objective = [self createObjectiveWithType:objectiveType];
            [self showObjectiveDetailViewFromView:[tableView cellForRowAtIndexPath:indexPath] withObjective:objective];
            
        } else if (row > 0) {    
            NSMutableArray *objectives = [objectiveGroups_ objectAtIndex:[indexPath section]];
            Objective *objective = [objectives objectAtIndex:(row - 1)]; //account for the header cell    
            [self showObjectiveDetailViewFromView:[tableView cellForRowAtIndexPath:indexPath] withObjective:objective];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row] == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row] > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *objectives = [objectiveGroups_ objectAtIndex:[indexPath section]];
        NSUInteger row = [indexPath row] - 1;  //account for the header cell in the first row.    
        Objective *objective = [objectives objectAtIndex:row];
        [objectives removeObject:objective];
        [DataManager deleteManagedInstance:objective];        
        [self.tblObjectives deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // update the order of each objective to for good measure, since a gap will have been created by 
        // the deletion.
        for (int i = 0; i < objectives.count; i++) {
            ((Objective*)[objectives objectAtIndex:i]).order = [NSNumber numberWithInt:i];             
        }
        
        [stratFileManager_ saveCurrentStratFile];
        
        // reload the current section if we just deleted the last objective, so we can load the add objective cell.
        if (objectives.count == 0) {
            [self.tblObjectives reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:YES];    
        }        
        
        [EventManager fireObjectiveDeletedEvent];
    }    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // only permit moving a row within its own section and not into position 0, since there will be a header cell there.    
    NSUInteger row = [proposedDestinationIndexPath row] == 0 ? [sourceIndexPath row] : [proposedDestinationIndexPath row];
    return [NSIndexPath indexPathForRow:row inSection:[sourceIndexPath section]];
}


#pragma mark - Actions

- (IBAction)addObjective:(id)sender event:(UIEvent*)event
{
    if ([_permissionChecker checkReadWrite]) {
        Objective *objective = [self createObjectiveWithType:[objectiveTypes_ objectAtIndex:0]];
        [self showObjectiveDetailViewFromView:[[event.allTouches anyObject] view] withObjective:objective];        
    }
}

- (IBAction)toggleManageMode:(id)sender
{    
    if ([_permissionChecker checkReadWrite]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        if (self.tblObjectives.editing) {
            // switch off editing mode.
            [button setTitle:LocalizedString(@"MANAGE", nil)];
            [self.tblObjectives setEditing:NO animated:YES];        
        } else {
            [button setTitle:LocalizedString(@"DONE", nil)];
            [self.tblObjectives setEditing:YES animated:YES];        
        }
    }
}


#pragma mark - DropDownDelegate

- (void)valueSelected:(id)value forDropDownButton:(MBDropDownButton *)button
{
    [EventManager fireJumpToThemeEventWithTheme:(Theme*)value fromViewController:self];
}


#pragma mark - ObjectiveDetailDelegate

- (void)editingCompleteForObjective:(Objective *)objective
{
    [self hideObjectiveDetailView];
  
    // if we don't have an objective name, give it one
    if (!objective.summary || [objective.summary isBlank]) {
        objective.summary = LocalizedString(@"UNNAMED_OBJECTIVE", nil);
        [stratFileManager_ saveCurrentStratFile];
    }    
 
    NSUInteger section = [objectiveTypes_ indexOfObject:objective.objectiveType];
    NSMutableArray *objectiveGroup = [objectiveGroups_ objectAtIndex:section];

    if (![objectiveGroup containsObject:objective]) {
        // new objective, so assign it an order of the objective count for the section.
        objective.order = [NSNumber numberWithInt:[objectiveGroup count]];
        [stratFileManager_ saveCurrentStratFile];
        [EventManager fireObjectiveCreatedEvent];
    }

    // load up the cached array
    [self groupAndSortObjectives];
    
    // reassign objectiveGroup here as it is no longer valid after the call groupAndSortObjectives
    objectiveGroup = [objectiveGroups_ objectAtIndex:section];
 
    // find the appropriate row
    NSUInteger row = [objectiveGroup indexOfObject:objective]+1; // +1 to account for the first row which is a header
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    [self.tblObjectives reloadData];
    
    // it's not selected anymore after being reloaded, so select it again
    NSArray *visCellPaths = [self.tblObjectives indexPathsForVisibleRows];
    if ([visCellPaths indexOfObject:indexPath] != NSNotFound) {
        [self.tblObjectives selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];            
    } else {
        [self.tblObjectives selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
   
    [self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.5];
    
}

-(void)deselectRow:(NSIndexPath*)indexPath
{
    [self.tblObjectives deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Support

- (Objective*)createObjectiveWithType:(ObjectiveType*)type
{
    Objective *objective = (Objective*)[DataManager createManagedInstance:NSStringFromClass([Objective class])];
    objective.objectiveType = type;
    objective.reviewFrequency = [Frequency frequencyForCategory:FrequencyCategoryMonthly];
    
    Metric *metric = (Metric*)[DataManager createManagedInstance:NSStringFromClass([Metric class])];
    [objective addMetricsObject:metric];
    
    NSArray *objectiveGroup = [objectiveGroups_ objectAtIndex:[objectiveTypes_ indexOfObject:type]];
    objective.order = [NSNumber numberWithInt:[objectiveGroup count]];    

    [theme_ addObjectivesObject:objective];
    
    [stratFileManager_ saveCurrentStratFile];
    [EventManager fireObjectiveCreatedEvent];
    return objective;
}

- (void)groupAndSortObjectives
{
    [objectiveGroups_ removeAllObjects];
    
    for (int i = 0; i < 6; i++) {
        [objectiveGroups_ addObject:[NSMutableArray array]];
    }
    
    // group each objective by their objective type and sort each group by order.
    for (Objective *objective in theme_.objectives) {
        [[objectiveGroups_ objectAtIndex:[objectiveTypes_ indexOfObject:objective.objectiveType]] addObject:objective];
    }
    
    NSSortDescriptor *orderSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];    
    NSMutableArray *objectiveGroup, *sortedObjectiveGroup;

    for (int i = 0; i < 6; i++) {
        objectiveGroup = [objectiveGroups_ objectAtIndex:i];
        sortedObjectiveGroup = [NSMutableArray arrayWithArray:[objectiveGroup sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderSort]]];
        [objectiveGroups_ replaceObjectAtIndex:i withObject:sortedObjectiveGroup];
    }    
    [orderSort release];
}

- (void)showObjectiveDetailViewFromView:(UIView*)view withObjective:(Objective *)objective 
{
    // detail controller is released in hideObjectiveDetailView, as well as dealloc
    detailController_ = [[ObjectiveDetailViewController alloc] initWithNibName:nil bundle:nil andObjective:objective];
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

- (void)hideObjectiveDetailView
{
    UIView *detailView = detailController_.view;    
    
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
    return ([stratFileManager_.currentStratFile.themes count] > 0);
}

- (NSString*)messageWhenDisabled
{
    return LocalizedString(@"MSG_NO_THEMES", nil);
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
    //return @"http://player.vimeo.com/external/70704411.m3u8?p=high,standard,mobile&s=99c7ea26622bb0bf15932084836cfc19";
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SP iPad F6" ofType:@"mp4"];
    return path;
}


@end
