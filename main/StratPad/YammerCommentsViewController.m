//
//  YammerCommentsViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-09-28.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "YammerCommentsViewController.h"
#import "YammerCommentManager.h"
#import "YammerComment.h"
#import "UIColor-Expanded.h"
#import "YammerRootMessageCell.h"
#import "YammerReplyMessageCell.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "UnreadBulletView.h"
#import "MultilineEditorCell.h"
#import "NSString-Expanded.h"
#import "YammerThread.h"
#import "UserNotificationDisplayManager.h"
#import "YammerStoredComment.h"
#import "DataManager.h"
#import "PdfHelper.h"
#import "Tracking.h"
#import "UIView+ObjectTagAdditions.h"

@interface NSDate (YammerCommentsViewController)
-(NSString*)formattedDateForYammer;
@end

@implementation NSDate (YammerCommentsViewController)
-(NSString*)formattedDateForYammer
{
    // locale dependent, tz-sensitive
    // used in most reports
    // August 4, 2012 at 3:43 PM
    NSString *identifier = [[LocalizedManager sharedManager] localeIdentifier];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
    NSString *yammerCommentFormatString = LocalizedString(@"YAMMER_COMMENT_DATE_FORMAT_STRING", nil);
    NSString *format = [NSDateFormatter dateFormatFromTemplate:yammerCommentFormatString options:0 locale:locale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:locale];
    NSString *formattedDate = [formatter stringFromDate:self];
    [formatter release];
    [locale release];
    
    return formattedDate;
}
@end

@interface YammerCommentsViewController () {
    @private
    UIPopoverController *popoverController_;
    YammerPublishedReport *yammerReport_;

    // we sort threads by the creation date of their last reply, but only the first time
    // so even if we post another reply, the order will stay the same until we refresh
    // store the order of threads
    NSArray *threadIds_;
    
    // this is a dict of threadId -> YammerReport (which contains an array of YammerComment, and more available)
    NSMutableDictionary *threads_;
    
    // when we go out to load a profile image, we'll place it in this set
    // if the indexPath changes before it has finished loading, as happens when you tap the more button, we won't update the waiting image containers (from the same section)
    // we'll then start the image loading again for those affected cells
    // as we successfully place images after loading, remove them from this set
    //
    NSMutableSet *loadingImages_;

    // if we press 'more' in a section, record it here, so that any images loading in that section can cancel and start reloading (indexpaths change)
    NSDictionary *morePressedForSection_;
    
    // the filename used to publish the original attachment; derived from the user-entered title
    NSString *filename_;
    
    // the yammer group id used to publish the original attachment; can be nil
    NSNumber *groupId_;
    
    // the id of the root comment of the original thread created when the file was first published
    NSNumber *originalThreadId_;
    
}

// the last cell of each section is a text editor
// the textview in that cell records its NSIndexPath at creation time
// when we start editing, we temporarily store that path here
// this is useful for calculating the height of the cell as we add multiline text
// it is also useful for determining which editor's contents (from multiple sections) to post
@property (retain, nonatomic) NSIndexPath *editingPath;

// after we post a comment, the postingPath takes on the editingPath value, so that the editingPath can be reset and used again
// after the post is completed, it is reset
// note that after a post is completed, we must also update the textview's indexPath, because we added a row
@property (retain, nonatomic) NSIndexPath *postingPath;

@end

@implementation YammerCommentsViewController
@synthesize tblConversations, editingPath, postingPath;

#pragma mark - Lifecycle

- (id)initWithYammerPublishedReport:(YammerPublishedReport*)yammerReport
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        yammerReport_ = [yammerReport retain];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [filename_ release];
    [groupId_ release];
    [originalThreadId_ release];
    [threadIds_ release];
    [cache_ release];
    [cacheLock_ release];
    [postingPath release];
    [editingPath release];
    [threads_ release];
    [yammerReport_ release];
    [popoverController_ release];
    [tblConversations release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    // go grab the comments for this file (max 20)
    [[YammerCommentManager sharedManager] fetchConversationsForFile:yammerReport_.attachmentId
                                                         forNetwork:yammerReport_.permalink
                                                             target:self action:@selector(showThreads:error:userInfo:)];
        
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake((self.view.frame.size.width - aSize.width)/2,
                                 (self.view.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
    [indicator release];
        
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    // post comment button in nav
    UIBarButtonItem *barBtnItemPostComment = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"YAMMER_POST_COMMENT", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(postComment)];
    barBtnItemPostComment.enabled = NO;
    [self.navigationItem setRightBarButtonItem:barBtnItemPostComment];
    [barBtnItemPostComment release];

    // update file button in nav
    UIBarButtonItem *barBtnItemUpdateFile = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"YAMMER_UPDATE_FILE", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(updateFile)];
    [self.navigationItem setLeftBarButtonItem:barBtnItemUpdateFile];
    [barBtnItemUpdateFile release];

    // for user photos
    cache_ = [[NSMutableDictionary dictionary] retain];
    cacheLock_ = [[NSLock alloc] init];
}

- (void)viewDidUnload
{
    [self setTblConversations:nil];
    [super viewDidUnload];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // we can make sure all these comments are now marked as read
    for (YammerThread *yammerThread in [threads_ allValues]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unread=1"];
        NSArray *comments = [yammerThread.comments filteredArrayUsingPredicate:predicate];
        [[YammerCommentManager sharedManager] markAsRead:comments forNetwork:yammerReport_.permalink];
    }

    // this will update comment counts on all our UI widgets, but will also catch any new comments from Yammer
    [[YammerCommentManager sharedManager] updateCommentCounts];

    [popoverController_ release];
	popoverController_ = nil;
}

#pragma mark - Public

- (void)showPopoverFromControl:(UIControl*)control title:(NSString*)title
{
    if (popoverController_) {
        [popoverController_ release]; popoverController_ = nil;
    }
    
    // always show in rootVC.view, so calculate coords of control in rootVC.view
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *parentView = [control superview];
    CGRect f = [parentView convertRect:control.frame toView:rootViewController.view];
        
    self.title = title;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:navController];
    popoverController_.delegate = self;
    popoverController_.popoverContentSize = self.view.bounds.size;
    [popoverController_ presentPopoverFromRect:f
                                        inView:rootViewController.view
                      permittedArrowDirections:UIPopoverArrowDirectionRight
                                      animated:YES];
    [navController release];
}

#pragma mark - Callbacks

-(void)showThreads:(NSMutableDictionary*)threads error:(NSError*)error userInfo:(NSDictionary*)userInfo
{
    DLog(@"threads: %@", threads);

    if (!error) {
        threads_ = [threads retain];
        
        DLog(@"userInfo: %@", userInfo);
        
        
        NSDictionary *msgDict = [userInfo objectForKey:@"message"];
        NSDictionary *attDict = [[msgDict objectForKey:@"attachments"] objectAtIndex:0];

        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tblConversations.frame.size.width, 30)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 5, tblConversations.frame.size.width, 20);
        [btn setTitle:LocalizedString(@"YAMMER_VIEW_ON_WEB", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"394B79"] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(goYammer:) forControlEvents:UIControlEventTouchUpInside];
        [btn setObjectTag:[attDict objectForKey:@"web_url"]];
        [footerView addSubview:btn];
        tblConversations.tableFooterView = footerView;
        [footerView release];

        filename_ = [[attDict objectForKey:@"name"] retain];
        groupId_ = [[attDict objectForKey:@"group_id"] retain];
        originalThreadId_ = [[msgDict objectForKey:@"thread_id"] retain];
        
        [tblConversations reloadData];
    } else {
        // error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"YAMMER_FETCH_ERROR_TITLE", nil)
                                                            message:[NSString stringWithFormat:LocalizedString(@"YAMMER_FETCH_FILE_COMMENTS_ERROR", nil), error.localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }

    // remove activity indicator
    [[[self.view subviews] lastObject] removeFromSuperview];

}

-(void)showMoreCommentsInThread:(YammerThread*)updatedThread error:(NSError*)error userInfo:(NSDictionary*)userInfo
{
    NSIndexPath *indexPath = [userInfo objectForKey:@"indexPath"];

    TLog(@"fullThread: %@", updatedThread);
    // todo: show the more row as many times as necessary
        
    if (!error) {
        // going to remove this cell and add in some reply cells
        
        // now we have to update the appropriate thread in threads_, with the new comments here
        NSNumber *threadId = [NSNumber numberWithInt:[(YammerComment*)[updatedThread.comments objectAtIndex:0] threadId]];

        // the existing thread, missing some messages
        YammerThread *shortThread = [threads_ objectForKey:threadId];

        // figure out which indexes need to be updated
        // this should deal with the case where we have the shortened thread open, make a post from yammer, and then we hit more
        NSUInteger diff = updatedThread.comments.count - shortThread.comments.count;
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:diff];
        
        // determine differences between arrays, then get them back in order
        NSMutableSet *shortSet = [NSMutableSet setWithArray:shortThread.comments];
        NSMutableSet *missingSet = [NSMutableSet setWithArray:updatedThread.comments];
        [missingSet minusSet:shortSet];
        
        // more than 20 comments causes a problem; eg 29 comments: ((1+2)+1+1) + 18 = 23 after update; new comments should be indexes 2 through 20
        // or 1+2+1 + 17 = 21 if there were 20 comments
        NSUInteger offset = 1;
        if (diff != missingSet.count) {
            // fullThread doesn't include the root comment if we have more than 20 messages in the thread
            offset = 2;
        }
        
        // now go through updated array of comments (to maintain order) and add matching comments to indexPaths (for animations)
        for (int i=0, ct=updatedThread.comments.count; i<ct; ++i) {
            YammerComment *cmt = [updatedThread.comments objectAtIndex:i];
            if ([missingSet containsObject:cmt]) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i+offset inSection:indexPath.section]];
            }
        }
        
        // need to merge comments, and maintain the order; should be the root message plus the updated messages + the last 2
        if (diff != missingSet.count) {
            YammerComment *threadStarterComment = [shortThread.comments objectAtIndex:0];
            [updatedThread.comments insertObject:threadStarterComment atIndex:0];
        }
        
        // now update model
        [threads_ setObject:updatedThread forKey:threadId];
        
        // refresh relevant rows
        [tblConversations beginUpdates];
        // delete the more button
        [tblConversations deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
        // insert the new comments
        [tblConversations insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [tblConversations endUpdates];
        
        // update path in reply editor
        NSIndexPath *replyEditorIndexPath = [NSIndexPath indexPathForRow:updatedThread.comments.count inSection:indexPath.section];
        MultilineEditorCell *cell = (MultilineEditorCell*)[tblConversations cellForRowAtIndexPath:replyEditorIndexPath];
        cell.textView.indexPath = replyEditorIndexPath;
        
    } else {
        // error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"YAMMER_FETCH_ERROR_TITLE", nil)
                                                            message:[NSString stringWithFormat:LocalizedString(@"YAMMER_FETCH_THREAD_ERROR", nil), error.localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
    
    // remove activity indicator
    UITableViewCell *cell = [tblConversations cellForRowAtIndexPath:indexPath];
    [[cell viewWithTag:4000] removeFromSuperview];    
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self keysSortedByLatestReplyDate];
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:[indexPath section]]];
    NSArray *comments =  thread.comments;
    NSUInteger numComments = comments.count;
    NSUInteger lastRowIndex = numComments + ([thread hasMoreComments] ? 1 : 0);
    
    YammerMessageCell *cell;
    if ([indexPath row] == 0) {
        
        // stretch it out vertically
        static NSString *RootCellIdentifier = @"YammerRootMessageCell";
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:RootCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    else if ([indexPath row] == lastRowIndex) {
        // editor

        if (indexPath.section == editingPath.section && indexPath.row == editingPath.row) {
            // adjust for the number of lines
            CGFloat lineHeight = 18.f;
            return 35.f-lineHeight + MAX(numLines_, 1)*lineHeight;
        }
        else {
            // empty editor
            return 35.f;
        }
    }
    else {
        
        if ([indexPath row] == 1 && [thread hasMoreComments]) { // the first row can potentially be the 'more' cell
            return 45;
        } else {
            // stretch it out vertically
            static NSString *ReplyCellIdentifier = @"YammerReplyMessageCell";
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:ReplyCellIdentifier owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
    }
    
    CGFloat h = cell.contentView.frame.size.height;
    CGFloat lh = cell.lblCommentText.frame.size.height;
    
    int cmtIdx = MAX([indexPath row] - ([thread hasMoreComments] ? 1 : 0), 0);
    YammerComment *cmt = [comments objectAtIndex:cmtIdx];
    
    // we don't know the width of the cell before it has been displayed and computed
    CGSize sz = [cmt.text sizeWithFont:cell.lblCommentText.font
                     constrainedToSize:CGSizeMake(510, 999)
                         lineBreakMode:UILineBreakModeWordWrap];
    return h-lh+sz.height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only allow More cell to be selected
    NSArray *keys = [self keysSortedByLatestReplyDate];
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:[indexPath section]]];

    if (indexPath.row == 1 && thread.hasMoreComments) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self keysSortedByLatestReplyDate];
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:[indexPath section]]];
    NSNumber *threadId = [NSNumber numberWithInt:[(YammerComment*)[thread.comments objectAtIndex:0] threadId]];
    
    UITableViewCell *cell = [tblConversations cellForRowAtIndexPath:indexPath];
    
    // activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGSize aSize = indicator.frame.size;
    indicator.tag = 4000;
    
    indicator.frame = CGRectMake((cell.contentView.frame.size.width - aSize.width - 10),
                                 (cell.contentView.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    
    [cell.contentView addSubview:indicator];
    [indicator startAnimating];
    [indicator release];

    [[YammerCommentManager sharedManager] fetchThread:threadId
                                           forNetwork:yammerReport_.permalink
                                               target:self
                                               action:@selector(showMoreCommentsInThread:error:userInfo:)
                                             userInfo:[NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"]];

    [tblConversations deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [threads_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self keysSortedByLatestReplyDate];
    
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:section]];
    NSArray *comments =  thread.comments;
    NSUInteger numComments = comments.count;

    if ([thread hasMoreComments]) {
        // add 1 for the reply editor, 1 for the more cell
        return numComments + 2;
    } else {
        // add 1 for the reply editor
        return numComments + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // no titles
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self keysSortedByLatestReplyDate];
    
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:[indexPath section]]];
    NSArray *comments =  thread.comments;
    NSUInteger numComments = comments.count;
    NSUInteger lastRowIndex = numComments + ([thread hasMoreComments] ? 1 : 0);
    
    UITableViewCell *cell;
    if ([indexPath row] == 0) { // first
        YammerComment *cmt = [comments objectAtIndex:0];
        cell = [self cellForRootMessage:cmt indexPath:indexPath];
    }
    else if ([indexPath row] == lastRowIndex) { // beyond the last comment
        YammerComment *cmt = [comments objectAtIndex:0];
        cell = [self cellForReplyEditor:cmt indexPath:indexPath];
    }
    else if ([indexPath row] == 1) { // the first row can potentially be the 'more' cell
        if ([thread hasMoreComments]) {
            cell = [self cellForMoreReplies:thread indexPath:indexPath];
        } else {
            YammerComment *cmt = [comments objectAtIndex:1];
            cell = [self cellForReply:cmt indexPath:indexPath];
        }
    }
    else { // in between
        int cmtIdx = MAX([indexPath row] - ([thread hasMoreComments] ? 1 : 0), 0);
        YammerComment *cmt = [comments objectAtIndex:cmtIdx];
        cell = [self cellForReply:cmt indexPath:indexPath];
    }
    return cell;
}

#pragma mark - Cell construction

-(UITableViewCell*)cellForRootMessage:(YammerComment*)yammerComment indexPath:(NSIndexPath*)indexPath
{
    static NSString *RootCellIdentifier = @"YammerRootMessageCell";
    YammerRootMessageCell *cell = [tblConversations dequeueReusableCellWithIdentifier:RootCellIdentifier];
    
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:RootCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.lblSender.text = [NSString stringWithFormat:@"%@ ▸ %@", yammerComment.sender.fullname, yammerComment.group.groupName];
    cell.lblCreationDate.text = [yammerComment.creationDate formattedDateForYammer];
    
    cell.lblCommentText.text = yammerComment.text;
    [cell.btnLike setTitle:LocalizedString(@"YAMMER_LIKE", nil) forState:UIControlStateNormal];
    
    [[cell viewWithTag:2000] removeFromSuperview];
    
    // it's critical here, to only mark the messages unread that were judged unread when we downloaded the latest 20
    // if it doesn't add up, we have to put a bullet on the more cell
    // those cells should check in the same manner
    
    if (yammerComment.isUnread) {
        UnreadBulletView *bullet = [[UnreadBulletView alloc] initWithFrame:CGRectMake(20, 22, 15, 15)];
        bullet.tag = 2000;
        [cell addSubview:bullet];
        [bullet release];
    }
        
#if DEBUG
    [[cell.contentView viewWithTag:1000] removeFromSuperview];
    UILabel *lbl1 = [[UILabel alloc] init];
    lbl1.backgroundColor = [UIColor clearColor];
    lbl1.text = [[NSNumber numberWithInt:yammerComment.commentId] stringValue];
    lbl1.textColor = [UIColor grayColor];
    lbl1.font = [UIFont systemFontOfSize:12];
    lbl1.tag = 1000;
    [lbl1 sizeToFit];
    lbl1.frame = CGRectMake(450, 5, lbl1.bounds.size.width, lbl1.bounds.size.height);
    [cell.contentView addSubview:lbl1];
    [lbl1 release];
#endif
        
    // load image on a background thread
    NSURL *profileImageURL = [NSURL URLWithString:yammerComment.sender.mugshotURL];
    

    UIImage *img = [cache_ objectForKey:profileImageURL];
    if (img) {
        cell.imgSenderPhoto.image = img;
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     profileImageURL, @"url",
                                     indexPath, @"indexPath",
                                     nil];
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:dict];
    }
    
    return cell;
}

-(UITableViewCell*)cellForReply:(YammerComment*)yammerComment indexPath:(NSIndexPath*)indexPath
{
    static NSString *ReplyCellIdentifier = @"YammerReplyMessageCell";
    YammerReplyMessageCell *cell = [tblConversations dequeueReusableCellWithIdentifier:ReplyCellIdentifier];
    
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:ReplyCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.lblSender.text = [NSString stringWithFormat:@"%@ ▸ %@", yammerComment.sender.fullname, yammerComment.group.groupName];
    cell.lblCreationDate.text = [yammerComment.creationDate formattedDateForYammer];
    
    cell.lblCommentText.text = yammerComment.text;
    [cell.btnLike setTitle:LocalizedString(@"YAMMER_LIKE", nil) forState:UIControlStateNormal];
    
    [[cell viewWithTag:2000] removeFromSuperview];
    if (yammerComment.isUnread) {
        UnreadBulletView *bullet = [[UnreadBulletView alloc] initWithFrame:CGRectMake(20, 22, 15, 15)];
        bullet.tag = 2000;
        [cell addSubview:bullet];
        [bullet release];
    }
    
#if DEBUG
    [[cell.contentView viewWithTag:1000] removeFromSuperview];
    UILabel *lbl1 = [[UILabel alloc] init];
    lbl1.backgroundColor = [UIColor clearColor];
    lbl1.text = [[NSNumber numberWithInt:yammerComment.commentId] stringValue];
    lbl1.textColor = [UIColor grayColor];
    lbl1.font = [UIFont systemFontOfSize:12];
    lbl1.tag = 1000;
    [lbl1 sizeToFit];
    lbl1.frame = CGRectMake(450, 5, lbl1.bounds.size.width, lbl1.bounds.size.height);
    [cell.contentView addSubview:lbl1];
    [lbl1 release];
#endif    
        
    // load image on a background thread
    NSURL *profileImageURL = [NSURL URLWithString:yammerComment.sender.mugshotURL];
    UIImage *img = [cache_ objectForKey:profileImageURL];
    if (img) {
        cell.imgSenderPhoto.image = img;
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     profileImageURL, @"url",
                                     indexPath, @"indexPath",
                                     nil];
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:dict];
    }
    
    return cell;
}

-(UITableViewCell*)cellForMoreReplies:(YammerThread*)yammerThread indexPath:(NSIndexPath*)indexPath
{
    static NSString *MoreCellIdentifier = @"YammerMoreCommentsCell";
    UITableViewCell *cell = [tblConversations dequeueReusableCellWithIdentifier:MoreCellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MoreCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    }
    
    cell.indentationWidth = 64.f - 10;
    cell.indentationLevel = 1;

    NSArray *keys = [self keysSortedByLatestReplyDate];
    YammerThread *thread = [threads_ objectForKey:[keys objectAtIndex:[indexPath section]]];

    // 3 = root message + latest 2 replies
    cell.textLabel.text = [NSString stringWithFormat:LocalizedString(@"YAMMER_MORE_REPLIES", nil), thread.totalComments-3];
                    
    return cell;
}


-(UITableViewCell*)cellForReplyEditor:(YammerComment*)rootYammerComment indexPath:(NSIndexPath*)indexPath
{
    static NSString *ReplyEditorCellIdentifier = @"MultilineEditorCell";
    MultilineEditorCell *cell = [tblConversations dequeueReusableCellWithIdentifier:ReplyEditorCellIdentifier];
    
    if (!cell) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:ReplyEditorCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    cell.textView.delegate = self;
    cell.textView.indexPath = indexPath;
    
    cell.textView.textColor = [UIColor lightGrayColor];
    cell.textView.text = LocalizedString(@"YAMMER_COMMENT_REPLY_PLACEHOLDER", nil);
        
    return cell;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(TableCellTextView *)textView
{    
    // check if we need to increase the size of the table row
    CGFloat numLines = floorf(textView.contentSize.height/textView.font.lineHeight);
    if (numLines != numLines_) {
        numLines_ = numLines;
        [self tableViewNeedsToUpdateHeight];
    }
    
    if (![textView.text isBlank] && !textView.isShowingPlaceHolder) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)textView:(TableCellTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // check if we need to show placeholder
    BOOL willBeEmpty = textView.text.length == range.length;
    BOOL isReplacementEmpty = [text isBlank];
    
    // we have deleted all the text
    if (willBeEmpty && range.location == 0 && isReplacementEmpty) {
        [textView showPlaceHolder];
        return NO;
    }
    
    // this case occurs when we have deleted all text, reshown the placeholder, and then start typing again
    else if (textView.isShowingPlaceHolder) {
        [textView hidePlaceHolder];
        return YES;
    }
    return YES;
}


- (void)textViewDidBeginEditing:(TableCellTextView *)textView
{
    self.editingPath = textView.indexPath;
    numLines_ = floorf(textView.contentSize.height/textView.font.lineHeight);
    
    // hide the placeholder if necessary
    if (textView.isShowingPlaceHolder) {
        [textView hidePlaceHolder];
    }
}

#pragma mark - Private

- (void)tableViewNeedsToUpdateHeight
{
    // update table height without losing focus or keyboard
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [tblConversations beginUpdates];
    [tblConversations endUpdates];
    [UIView setAnimationsEnabled:animationsEnabled];
}

- (void)postComment
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MultilineEditorCell *cell = (MultilineEditorCell*)[tblConversations cellForRowAtIndexPath:editingPath];
    [cell showActivity];
    [cell.textView resignFirstResponder];
    
    NSArray *keys = [self keysSortedByLatestReplyDate];
    NSArray *thread = [[threads_ objectForKey:[keys objectAtIndex:[editingPath section]]] comments];
    YammerComment *rootComment = [thread objectAtIndex:0];
    
    [[YammerCommentManager sharedManager] postComment:cell.textView.text
                                            inReplyTo:rootComment
                                           forNetwork:yammerReport_.permalink
                                               target:self
                                               action:@selector(commentPosted:error:)];
    
    self.postingPath = editingPath;
    self.editingPath = nil;
    
    [Tracking logEvent:kTrackingEventYammerCommented];
}

- (void)commentPosted:(YammerComment*)yammerComment error:(NSError*)error
{
    // keep post button disabled until we start writing again
    
    MultilineEditorCell *cell = (MultilineEditorCell*)[tblConversations cellForRowAtIndexPath:postingPath];
    [cell finishActivity];
    
    if (!error) {
        
        // we can type in other areas, but can't post
        // place an activity indicator over the current textview and disable it until response
        // update threads_ and then reset the textview, insert the new comment (or if fail, just put textview back into edit mode)
        // what if the popover disappears??
        
        [cell.textView showPlaceHolder];
        
        NSMutableArray *thread = [[threads_ objectForKey:[NSNumber numberWithInt:yammerComment.threadId]] comments];
        [thread addObject:yammerComment];
        [tblConversations insertRowsAtIndexPaths:[NSArray arrayWithObject:postingPath]
                                withRowAnimation:UITableViewRowAnimationBottom];
        
        // update path in reply editor
        cell.textView.indexPath = [NSIndexPath indexPathForRow:postingPath.row+1 inSection:postingPath.section];
        
//        self.editingPath = nil;
        self.postingPath = nil;
        
    } else {
        // error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@"YAMMER_FETCH_ERROR_TITLE", nil)
                                                            message:[NSString stringWithFormat:LocalizedString(@"YAMMER_POST_COMMENT_ERROR", nil), error.localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        self.editingPath = postingPath;
        self.postingPath = nil;
    }

}

- (void)loadImageInBackground:(NSMutableDictionary *)params
{
    // todo: there is one issue here - if you tap more before all images have loaded, then the indexPath will be wrong for images in this section and we'll set the wrong images
    // see loadImages_ and morePressedForSection_
    NSURL *url = [params objectForKey:@"url"];
    [cacheLock_ lock];
    UIImage *img = [cache_ objectForKey:url];
    [cacheLock_ unlock];
    if (!img) {
        // this is a synchronous op which takes time
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        img = [[[UIImage alloc] initWithData:imgData] autorelease];
        if (img) {
            [cacheLock_ lock];
            [cache_ setObject:img forKey:url];
            [cacheLock_ unlock];
        }
    }
    if (img) {
        [params setObject:img forKey:@"image"];
        [self performSelectorOnMainThread:@selector(assignImageToCell:) withObject:params waitUntilDone:YES];
    } else {
        // leave the existing placeholder image alone
        WLog(@"Couldn't load image at url: %@", url);
    }
}

- (void)assignImageToCell:(NSMutableDictionary *)params
{
    UIImage *img = [params objectForKey:@"image"];
    YammerMessageCell *cell = (YammerMessageCell*)[self.tblConversations cellForRowAtIndexPath:[params objectForKey:@"indexPath"]];
    if (cell) {        
        cell.imgSenderPhoto.image = img;
    }
}

- (NSArray*)keysSortedByLatestReplyDate
{
    // rather than organizing conversations by the creation date of the thread (ie the root message), look at
    //    the messages in the thread instead - the last reply will be the latest
    if (!threadIds_) {
        threadIds_ = [[threads_ keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *cDate1 = [[[obj1 comments] lastObject] creationDate];
            NSDate *cDate2 = [[[obj2 comments] lastObject] creationDate];
            return [cDate2 compare:cDate1];
        }] retain];
    }
    return threadIds_;
}

-(void)updateFile
{
    [Tracking logEvent:kTrackingEventYammerUpdatedFile];
    
    // new bar button item to hold the activity indicator
    UIBarButtonItem *barBtnItemIndicator = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:nil];
    [self.navigationItem setLeftBarButtonItem:barBtnItemIndicator];
    [barBtnItemIndicator release];

    // disable
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    

    // add the activity indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGSize aSize = indicator.frame.size;
    
    indicator.frame = CGRectMake(14, 5, aSize.width, aSize.height);
    
    // 1 is title item, 2 is left item
    [[[self.navigationController.navigationBar subviews] objectAtIndex:2] addSubview:indicator];

    [indicator startAnimating];
    [indicator release];

    
    // the plan is to add a comment with an attachment
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PageViewController *pageVC = rootViewController.pageViewController;
    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:pageVC.currentChapter.title
                                                      chapter:pageVC.currentChapter
                                                   pageNumber:pageVC.pageNumber
                                                   reportSize:ReportSizeCurrentChapter
                                                 reportAction:ReportActionYammerUpdate];
    
    // we provide the message, and specify chart/report or stratcard
    NSString *fileType = [helper isStratCard] ?
        LocalizedString(@"REPORT_CARD", nil) :
        (helper.isStratBoard ? LocalizedString(@"ACTION_CHART_PARAM", nil) : LocalizedString(@"ACTION_REPORT_PARAM", nil)
     );
    NSString *message = [NSString stringWithFormat:LocalizedString(@"YAMMER_UPDATE_FILE_MESSAGE", nil), [helper isStratCard] ? fileType : [fileType lowercaseString]];
    
    helper.allTasksCompletedBlock = ^(NSString* path) {
        
        // upload
        [[YammerCommentManager sharedManager] uploadToYammer:path
                                                    filename:filename_
                                                   inReplyTo:originalThreadId_
                                                     message:message
                                                     groupId:groupId_
                                                  forNetwork:yammerReport_.permalink
                                                      target:self
                                                      action:@selector(updateFinished:error:)];
    };
    
    [helper generatePdf];
    [helper release];    
}

// finished sending the new file
-(void)updateFinished:(NSDictionary*)json error:(NSError*)error
{
    if (error) {
        
        [[UserNotificationDisplayManager sharedManager] showErrorMessage:LocalizedString(@"YAMMER_UPDATE_ERROR_MESSAGE", nil)];
        ELog(@"Yammer post error: %@", error);
        
    }
    else {
        
        // success
        NSDictionary *msgDict = [[json objectForKey:@"messages"] objectAtIndex:0];
        NSDictionary *attDict = [[msgDict objectForKey:@"attachments"] objectAtIndex:0];

        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"YAMMER_UPLOAD_SUCCESS_MESSAGE", nil), [attDict objectForKey:@"full_name"]];
                
        // mark and store this comment as read too; no need to update counts
        YammerStoredComment *storedComment = [YammerStoredComment commentFromDict:msgDict];
        storedComment.unread = [NSNumber numberWithBool:NO];
        
        [DataManager saveManagedInstances];
        
        // now let's add in the new row

        // update table model with a new YammerComment
        NSMutableDictionary *refs = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *refsArray = [json objectForKey:@"references"];
        for (NSDictionary *refDict in refsArray) {
            // store types thread, user, etc - problem is message will trump types of thread with the same id
            if (![[refDict objectForKey:@"type"] isEqualToString:@"message"]) {
                [refs setObject:refDict forKey:[refDict objectForKey:@"id"]];
            }
        }
        
        YammerComment *cmt = [YammerComment commentFromDict:msgDict];
        cmt.sender = [YammerUser yammerUserFromDict:[refs objectForKey:[msgDict objectForKey:@"sender_id"]]];
        cmt.group = [YammerGroup yammerGroupFromDict:[refs objectForKey:[msgDict objectForKey:@"group_id"]]];
        cmt.isUnread = NO;

        NSMutableArray *thread = [[threads_ objectForKey:[NSNumber numberWithInt:cmt.threadId]] comments];
        [thread addObject:cmt];
        
        // we have to find the appropriate indexpath to insert this row
        // it's in the section which matches our original thread, and then it is equal to the last row in that section
        NSNumber *threadId = [NSNumber numberWithInt:cmt.threadId];
        
        // these are threadIds
        NSArray *keys = [self keysSortedByLatestReplyDate];
        
        // determine row and section
        NSUInteger section = [keys indexOfObject:threadId];
        NSUInteger row = [self tableView:self.tblConversations numberOfRowsInSection:section] - 2; // because we've already added the row to the model
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        // now update the cells
        [tblConversations insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationBottom];
        
        
        // now, update the indexPath in the editor
        row = [self tableView:self.tblConversations numberOfRowsInSection:section] - 1;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        MultilineEditorCell *cell = (MultilineEditorCell*)[self.tblConversations cellForRowAtIndexPath:indexPath];
        cell.textView.indexPath = indexPath;
    }

    // restore update file button in nav, getting rid of activity indicator in the process
    UIBarButtonItem *barBtnItemUpdateFile = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"YAMMER_UPDATE_FILE", nil)
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(updateFile)];
    [self.navigationItem setLeftBarButtonItem:barBtnItemUpdateFile];
    [barBtnItemUpdateFile release];

    // re-enable
    [self.navigationItem.leftBarButtonItem setEnabled:YES];

}

-(void)goYammer:(UIButton*)button
{
    NSString *webUrl = [button objectTag];
    NSURL *url = [NSURL URLWithString:webUrl];
    [[UIApplication sharedApplication] openURL:url];
}

@end
