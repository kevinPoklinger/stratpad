//
//  YammerMessageBuilderViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-07-10.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerMessageBuilderViewController.h"
#import "MenuNavController.h"
#import "UIColor-Expanded.h"
#import "ChartSelectionViewController.h"
#import "NSString-Expanded.h"
#import "YammerManager.h"
#import "SBJsonParser.h"
#import "YammerOAuth2LoginViewController.h"
#import "UserNotificationDisplayManager.h"
#import "YammerPublishedReport.h"
#import "YammerPublishedThread.h"
#import "StratFileManager.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "PageViewController.h"
#import "EventManager.h"
#import "YammerCommentManager.h"
#import "YammerStoredComment.h"
#import "Tracking.h"

#define titleCellPath       [NSIndexPath indexPathForRow:0 inSection:0]
#define networkCellPath     [NSIndexPath indexPathForRow:0 inSection:1]
#define groupCellPath       [NSIndexPath indexPathForRow:1 inSection:1]
#define userCellPath        [NSIndexPath indexPathForRow:2 inSection:1]
#define messageCellPath     [NSIndexPath indexPathForRow:0 inSection:2]

#pragma mark YammerMessage

@implementation YammerMessage
@synthesize group, message, title, user, groupState, networkState, userState, network, stratFile, chapter, pageNumber;
@synthesize userLoadError, groupLoadError, networkLoadError;
- (void)dealloc
{
    [chapter release];
    [stratFile release];
    [userLoadError release];
    [groupLoadError release];
    [networkLoadError release];
    [network release];
    [title release];
    [group release];
    [message release];
    [user release];
    [super dealloc];
}
@end

#pragma mark - YammerMessageBuilderViewController

@interface YammerMessageBuilderViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tblMessageBuilder;
@property (retain, nonatomic) IBOutlet UIButton *btnPostToYammer;
- (IBAction)postToYammer;
@end

@implementation YammerMessageBuilderViewController
@synthesize tblMessageBuilder;
@synthesize btnPostToYammer;

- (id)initWithPath:(NSString*)path
        reportName:(NSString*)reportName
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        path_ = [path retain];
        reportName_ = [reportName retain];
        yammerMessage_ = [[YammerMessage alloc] init];
        yammerMessage_.networkState = YammerLoadStateLoading;
        yammerMessage_.groupState = YammerLoadStateLoading;
        yammerMessage_.userState = YammerLoadStateLoading;
        yammerMessage_.stratFile = [[StratFileManager sharedManager] currentStratFile];
        
        AppDelegate* appDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
        PageViewController *pageVC = [(RootViewController*)[appDelegate.window rootViewController] pageViewController];
        yammerMessage_.chapter = pageVC.currentChapter;
        yammerMessage_.pageNumber = pageVC.pageNumber;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // popover window title
    self.title = LocalizedString(@"YAMMER_MESSAGE_DETAILS", nil);
    
    messageAttributes_ = [NSArray arrayWithObjects:
                
                          // file/report section
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"cellForTitle", @"constructor",
                             @"selectTitleCell:", @"action",
                             nil],
                            nil], @"rows",
                           LocalizedString(@"YAMMER_FILE", nil), @"sectionTitle",
                           nil],

                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"cellForNetwork", @"constructor",
                             @"selectNetworkCell:", @"action",
                             nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"cellForGroup", @"constructor",
                             @"selectGroupCell:", @"action",
                             nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"cellForUser", @"constructor",
                             nil],
                            nil], @"rows",
                           LocalizedString(@"YAMMER_META", nil), @"sectionTitle",
                           nil],
                          
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"cellForMessage", @"constructor",
                             @"selectMessageCell:", @"action",
                             nil],
                            nil], @"rows",
                           LocalizedString(@"YAMMER_MESSAGE_DETAILS", nil), @"sectionTitle",
                           nil],
                          
                          nil];
    
    [messageAttributes_ retain];
    
    // there is a view on top of the clear background, so let the view color show through
    tblMessageBuilder.backgroundView = nil;
    
    UIImage *btnBlue = [[UIImage imageNamed:@"btn-large-blue.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    [btnPostToYammer setBackgroundImage:btnBlue forState:UIControlStateNormal];
    [btnPostToYammer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPostToYammer setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [btnPostToYammer.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [btnPostToYammer.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];    
    [btnPostToYammer setTitle:LocalizedString(@"POST_TO_YAMMER", nil) forState:UIControlStateNormal];

    // default title is the filename
    NSString *defaultTitle = [[path_ lastPathComponent] stringByDeletingPathExtension];
    yammerMessage_.title = defaultTitle;
        
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:LocalizedString(@"YAMMER_SIGNOUT", nil)
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self
                                                                             action:@selector(resetAuthentication)] autorelease];
    // add a little fade effect to the bottom of the table
    if (!maskLayer_)
    {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = CGRectMake(0, tblMessageBuilder.bounds.size.height-30,
                                    tblMessageBuilder.bounds.size.width, 30);
        maskView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        maskLayer_ = [CAGradientLayer layer];
        
        CGColorRef outerColor = [[UIColor colorWithHexString:@"E1E4E9"] colorWithAlphaComponent:1.f].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        
        maskLayer_.colors = [NSArray arrayWithObjects:      (id)innerColor,                 (id)outerColor,                 nil];
        maskLayer_.locations = [NSArray arrayWithObjects:   [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer_.frame = CGRectMake(0, 0,
                                      maskView.bounds.size.width,
                                      maskView.bounds.size.height);
        
        [maskView.layer addSublayer:maskLayer_];
        [self.view addSubview:maskView];
        [maskView release];
        
    }
    
    [btnPostToYammer setEnabled:NO];
    
    [[YammerManager sharedManager] fetchUserForTarget:self action:@selector(userFetchFinished:error:)];

}

- (void)viewDidUnload
{
    [self setTblMessageBuilder:nil];
    [self setBtnPostToYammer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tblMessageBuilder flashScrollIndicators];
    
    // usually after choosing a topic or group
    NSIndexPath *selPath = [tblMessageBuilder indexPathForSelectedRow];
    [tblMessageBuilder deselectRowAtIndexPath:selPath animated:YES];
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(self.view.bounds.size.width, 100);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [request_ cancel];
    [request_ release];
    [path_ release];
    [reportName_ release];
    [tblMessageBuilder release];
    [btnPostToYammer release];
    [super dealloc];
}

#pragma mark - yammer

-(void)userFetchFinished:(YammerUser*)user error:(NSError*)error
{    
    if (!error) {
        yammerMessage_.user = user;
        
        // use preferredNetwork if available, otherwise use defaultNetwork
        // note that if network is somehow deleted or unsubscribed, we will be out of sync
        YammerNetwork *preferredNetwork = [[YammerManager sharedManager] preferredNetwork];
        if (preferredNetwork) {
            yammerMessage_.network = preferredNetwork;
        } else {
            yammerMessage_.network = user.authenticatedNetwork;
        }
        yammerMessage_.userState = YammerLoadStateSuccess;
        yammerMessage_.networkState = YammerLoadStateSuccess;
                
        // now we can determine groups
        [[YammerManager sharedManager] fetchGroups:self action:@selector(groupsFetchFinished:error:)];
        
        [self updatePostButton];
    } else {
        // error
        yammerMessage_.userState = YammerLoadStateError;
        yammerMessage_.userLoadError = error.localizedDescription;
    }
    
    // update user cell
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:userCellPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // make sure network is reflected
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:networkCellPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)groupsFetchFinished:(NSArray*)groups error:(NSError*)error
{   
    // we really just need the YammerManager to have a list of groups to match up against the saved group
    if (!error) {
        yammerMessage_.groupState = YammerLoadStateSuccess;
        
        YammerGroup *preferredGroup = [[YammerManager sharedManager] preferredGroup];
        
        // check to make sure it belongs to this network (these groups came from a URL designed for this network)  
        // NB. note that for now, since we always get the same groups list back, all groups will always be valid (when they shouldn't be)
        for (YammerGroup *group in groups) {
            if (group.groupId == preferredGroup.groupId) {
                yammerMessage_.group = preferredGroup;
                break;
            }
        }
        
        [self updatePostButton];
    } else {
        // error
        yammerMessage_.groupState = YammerLoadStateError;
        yammerMessage_.groupLoadError = error.localizedDescription;
    }
    
    // update group cell
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:groupCellPath] withRowAnimation:UITableViewRowAnimationFade];     
}

-(IBAction)postToYammer
{
    // if no message, use the reportname
    NSString *message = (yammerMessage_.message && ![yammerMessage_.message isBlank]) ? yammerMessage_.message : [reportName_ stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    // determine a more suitable filename
    NSString *ext = [path_ pathExtension];
    NSString *filename = [yammerMessage_.title stringByAppendingPathExtension:ext];
    
    // group is optional
    NSNumber *groupId = nil;
    if (yammerMessage_.group) {
        groupId = [NSNumber numberWithInt:yammerMessage_.group.groupId];
    }

    [[YammerCommentManager sharedManager] uploadToYammer:path_
                                                filename:filename
                                               inReplyTo:nil
                                                 message:message
                                                 groupId:groupId
                                              forNetwork:nil // use the last network chosen
                                                  target:self
                                                  action:@selector(postFinished:error:)];
    
    [Tracking logEvent:kTrackingEventYammerPostedFile];

    // dismiss and notify later
    [(MenuNavController*)self.navigationController dismissMenu];

}

-(void)postFinished:(NSDictionary*)json error:(NSError*)error
{
    if (error) {

        [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"YAMMER_UPLOAD_ERROR_MESSAGE", nil), yammerMessage_.title];
        ELog(@"Yammer post error: %@", error);

    }
    else {

        // success
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"YAMMER_UPLOAD_SUCCESS_MESSAGE", nil), yammerMessage_.title];

        NSDictionary *msgDict = [[json objectForKey:@"messages"] objectAtIndex:0];        
        NSDictionary *attDict = [[msgDict objectForKey:@"attachments"] objectAtIndex:0];

        // add a YammerPublishedReport (with threads)
        YammerPublishedReport *yammerReport = (YammerPublishedReport*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedReport class])];
        yammerReport.stratFile = yammerMessage_.stratFile;
        yammerReport.attachmentId = [attDict objectForKey:@"id"];
        yammerReport.chapterNumber = yammerMessage_.chapter.chapterNumber;
        yammerReport.chart = [Chart chartAtPage:yammerMessage_.pageNumber stratFile:yammerMessage_.stratFile];
        yammerReport.permalink = [[[YammerManager sharedManager] networkForNetworkId:[[msgDict objectForKey:@"network_id"] unsignedIntegerValue]] permalink];

        YammerPublishedThread *thread = (YammerPublishedThread*)[DataManager createManagedInstance:NSStringFromClass([YammerPublishedThread class])];
        thread.threadStarterId = [msgDict objectForKey:@"thread_id"];
        thread.creationDate = [NSDate dateTimeFromYammer:[msgDict objectForKey:@"created_at"]];

        [yammerReport addThreadsObject:thread];

        // mark and store this comment as read too
        YammerStoredComment *cmt = [YammerStoredComment commentFromDict:msgDict];
        cmt.unread = [NSNumber numberWithBool:NO];

        [DataManager saveManagedInstances];

        [YammerMessageBuilderViewController fireYammerNewPublication:yammerReport];
        
        // this will update comment counts on all our UI widgets, but will also catch any new comments from Yammer
        [[YammerCommentManager sharedManager] updateCommentCounts];
        
    }
    
    [btnPostToYammer setEnabled:YES];

}

+ (void)fireYammerNewPublication:(YammerPublishedReport*)yammerReport
{
    NSNotification *notification = [NSNotification notificationWithName:kEVENT_YAMMER_NEW_PUBLICATION object:nil userInfo:[NSDictionary dictionaryWithObject:yammerReport forKey:@"yammerReport"]];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP];
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the message or title cell
    CGFloat h = 44.f;
    if ( [indexPath isEqual:messageCellPath] ) {        
        if (![yammerMessage_.message isBlank]) {
            CGSize size = [yammerMessage_.message sizeWithFont:[UIFont systemFontOfSize:15.f] 
                                             constrainedToSize:CGSizeMake(self.view.bounds.size.width-2*20, 999)
                                                 lineBreakMode:UILineBreakModeWordWrap];
            h = MAX(h, size.height);
        }
    } else if ([indexPath isEqual:titleCellPath]) {
        if (![yammerMessage_.title isBlank]) {
            CGSize size = [yammerMessage_.title sizeWithFont:[UIFont systemFontOfSize:15.f] 
                                             constrainedToSize:CGSizeMake(self.view.bounds.size.width-2*20, 999)
                                                 lineBreakMode:UILineBreakModeWordWrap];
            h = MAX(h, size.height);
        }        
    }
    
    return h;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *sectionDict = [messageAttributes_ objectAtIndex:[indexPath section]];
    NSArray *rows = [sectionDict objectForKey:@"rows"];
    NSDictionary *rowDict = [rows objectAtIndex:[indexPath row]];
    
    SEL action = NSSelectorFromString([rowDict objectForKey:@"action"]);
    if (action) {
        [self performSelector:action withObject:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [messageAttributes_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[messageAttributes_ objectAtIndex:section] objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[messageAttributes_ objectAtIndex:section] objectForKey:@"sectionTitle"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    NSArray *sectionItems = [[messageAttributes_ objectAtIndex:[indexPath section]] objectForKey:@"rows"];
    NSDictionary *rowDict = [sectionItems objectAtIndex:[indexPath row]];
    
    SEL cellConstructor = NSSelectorFromString([rowDict objectForKey:@"constructor"]);
    UITableViewCell *cell = [self performSelector:cellConstructor];
    return cell;    
}

#pragma mark - Cell construction

- (UITableViewCell*)cellForTitle
{    
    static NSString *cellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tblMessageBuilder dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    // if user blanks it out, we are going to switch back to the file name
    if (yammerMessage_.title) {
        cell.textLabel.text = yammerMessage_.title;
    } else {
        NSString *defaultTitle = [[path_ lastPathComponent] stringByDeletingPathExtension];
        cell.textLabel.text = defaultTitle;
        yammerMessage_.title = defaultTitle;
    }
        
    return cell;
}

- (UITableViewCell*)cellForGroup
{    
    static NSString *cellIdentifier = @"LoadingCell";
    UITableViewCell *cell = [tblMessageBuilder dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
        
    cell.textLabel.text = LocalizedString(@"YAMMER_GROUP", nil);
        
    // cell will be filled out when request returns; this is nil to start with
    switch (yammerMessage_.groupState) {
        case YammerLoadStateLoading:
            cell.detailTextLabel.text = nil;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGSize aSize = indicator.frame.size;
            
            // right side of frame
            indicator.frame = CGRectMake(CGRectGetMaxX(cell.contentView.frame)-aSize.width-50,
                                         (cell.contentView.frame.size.height-aSize.height)/2,
                                         indicator.frame.size.width, indicator.frame.size.height);
            
            [cell.contentView addSubview:indicator];
            [indicator startAnimating];
            [indicator release];
            
            break;
        case YammerLoadStateSuccess:
            cell.detailTextLabel.text = yammerMessage_.group ? yammerMessage_.group.groupName : nil;
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"385487"]; // steel blue
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            
            break;
        case YammerLoadStateError:
            cell.detailTextLabel.text = yammerMessage_.groupLoadError ? yammerMessage_.groupLoadError : LocalizedString(@"ERROR", nil);
            cell.detailTextLabel.textColor = [UIColor redColor];
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            
            break;
        default:
            ELog(@"No such load state: %i", yammerMessage_.networkState);
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            break;
    }

    
    return cell;
}

- (UITableViewCell*)cellForNetwork
{
    static NSString *cellIdentifier = @"LoadingCell";
    UITableViewCell *cell = [tblMessageBuilder dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
    
    cell.textLabel.text = LocalizedString(@"YAMMER_NETWORK", nil);
    
    // cell will be filled out when request returns; this is nil to start with
    switch (yammerMessage_.networkState) {
        case YammerLoadStateLoading:
            cell.detailTextLabel.text = nil;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGSize aSize = indicator.frame.size;
            
            // right side of frame
            indicator.frame = CGRectMake(CGRectGetMaxX(cell.contentView.frame)-aSize.width-50,
                                         (cell.contentView.frame.size.height-aSize.height)/2,
                                         indicator.frame.size.width, indicator.frame.size.height);
            
            [cell.contentView addSubview:indicator];
            [indicator startAnimating];
            [indicator release];
            
            break;
        case YammerLoadStateSuccess:
            cell.detailTextLabel.text = yammerMessage_.network.name;
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"385487"]; // steel blue
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            
            break;
        case YammerLoadStateError:
            cell.detailTextLabel.text = yammerMessage_.networkLoadError ? yammerMessage_.networkLoadError : LocalizedString(@"ERROR", nil);
            cell.detailTextLabel.textColor = [UIColor redColor];
            [[cell.contentView.subviews lastObject] removeFromSuperview];            

            break;
        default:
            ELog(@"No such load state: %i", yammerMessage_.networkState);
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            break;
    }
        
    return cell;
}

- (UITableViewCell*)cellForUser
{
    static NSString *cellIdentifier = @"LoadingCell";
    UITableViewCell *cell = [tblMessageBuilder dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];        
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];

    cell.textLabel.text = LocalizedString(@"YAMMER_USER", nil);

    // cell will be filled out when request returns; this is nil to start with
    switch (yammerMessage_.userState) {
        case YammerLoadStateLoading:
            cell.detailTextLabel.text = nil;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGSize aSize = indicator.frame.size;
            
            // right side of frame
            indicator.frame = CGRectMake(CGRectGetMaxX(cell.contentView.frame)-aSize.width-50,
                                         (cell.contentView.frame.size.height-aSize.height)/2,
                                         indicator.frame.size.width, indicator.frame.size.height);
            
            [cell.contentView addSubview:indicator];
            [indicator startAnimating];
            [indicator release];
            
            break;
        case YammerLoadStateSuccess:
            cell.detailTextLabel.text = yammerMessage_.user.fullname;
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"385487"]; // steel blue
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            
            break;
        case YammerLoadStateError:
            cell.detailTextLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.text = yammerMessage_.userLoadError ? yammerMessage_.userLoadError : LocalizedString(@"ERROR", nil);
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            
            break;
        default:
            ELog(@"No such load state: %i", yammerMessage_.networkState);
            [[cell.contentView.subviews lastObject] removeFromSuperview];            
            break;
    }
    
    return cell;
}

- (UITableViewCell*)cellForMessage
{
    static NSString *cellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tblMessageBuilder dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
        
    if (yammerMessage_.message) {
        cell.textLabel.text = yammerMessage_.message;
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.text = LocalizedString(@"YAMMER_MESSAGE_HELP", nil);
        cell.textLabel.textColor = [UIColor grayColor];
    }

    return cell;
}

#pragma mark - Actions

- (void)selectTitleCell:(NSIndexPath*)indexPath
{
    YammerMessageViewController *vc = [[YammerMessageViewController alloc] initWithYammerMessageEditorContainer:self 
                                                                                                        message:yammerMessage_.title 
                                                                                                placeholderText:LocalizedString(@"YAMMER_TITLE_PLACEHOLDER", nil)
                                                                                                         action:@selector(titleChanged:)
                                       ];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectGroupCell:(NSIndexPath*)indexPath
{
    YammerGroupChooserViewController *vc = [[YammerGroupChooserViewController alloc] initWithYammerGroupChooser:self andSelectedGroup:yammerMessage_.group];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)selectTopicCell:(NSIndexPath*)indexPath
{
    YammerTopicChooserViewController *vc = [[YammerTopicChooserViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];    
}

- (void)selectNetworkCell:(NSIndexPath*)indexPath
{
    YammerNetworkChooserViewController *vc = [[YammerNetworkChooserViewController alloc] initWithYammerNetworkChooser:self andSelectedNetwork:yammerMessage_.network];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];    
}

- (void)selectMessageCell:(NSIndexPath*)indexPath
{
    YammerMessageViewController *vc = [[YammerMessageViewController alloc] initWithYammerMessageEditorContainer:self 
                                                                                                     message:yammerMessage_.message
                                                                                                placeholderText:LocalizedString(@"YAMMER_MESSAGE_PLACEHOLDER", nil)
                                                                                                         action:@selector(messageChanged:)
                                       ];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - YammerGroupChooser

- (void)groupChosen:(YammerGroup *)group
{
    yammerMessage_.group = group;
    
    // save selected group and pre-populate next time
    [[YammerManager sharedManager] savePreferredGroup:group];
    
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:groupCellPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - YammerNetworkChooser

- (void)networkChosen:(YammerNetwork *)network
{
    yammerMessage_.network = network;
    
    // save selected network, pre-populate next time and use for future API calls
    [[YammerManager sharedManager] savePreferredNetwork:network];
    
    // we need to deal with groups now - does this network contain the preferred group, and if so, then show it
    yammerMessage_.groupState = YammerLoadStateLoading;
    yammerMessage_.group = nil;
    [[YammerManager sharedManager] fetchGroups:self action:@selector(groupsFetchFinished:error:)];
    
    // update network cell
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:networkCellPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - messages from shared YammerMessageViewController

-(void)messageChanged:(NSString *)message
{
    // make sure any empty message is stored as nil
    yammerMessage_.message = [message isBlank] ? nil : message;
    
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:messageCellPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
}

-(void)titleChanged:(NSString *)title
{
    // make sure any empty message is stored as nil
    yammerMessage_.title = [title isBlank] ? nil : title;
    
    [tblMessageBuilder reloadRowsAtIndexPaths:[NSArray arrayWithObject:titleCellPath] 
                             withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Private

-(void)resetAuthentication
{
    [[YammerManager sharedManager] resetAuthentication];
    
    // make new array of vc's with root and login vc's
    NSMutableArray *vcs = [[self.navigationController viewControllers] mutableCopy];
    while (vcs.count > 1) {
        [vcs removeLastObject];
    }
    YammerOAuth2LoginViewController *loginVC = [[YammerOAuth2LoginViewController alloc] initWithPath:path_ reportName:reportName_];
    [vcs addObject:loginVC];
    [loginVC release];
    
    [self.navigationController setViewControllers:vcs animated:YES];
    
    [vcs release];
}

-(void)updatePostButton
{
    // must have all necessary aspects of yammerMessage fetched
    // we do a default message if none is entered
    if (yammerMessage_.networkState == YammerLoadStateSuccess 
        && yammerMessage_.userState == YammerLoadStateSuccess 
        && yammerMessage_.groupState == YammerLoadStateSuccess
        ) {
        btnPostToYammer.enabled = YES;
    } else {
        btnPostToYammer.enabled = NO;
    }
}


@end
