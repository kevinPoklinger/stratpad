//
//  UpgradeViewController.m
//  StratPad
//
//  Created by Julian Wood on 11-12-06.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
//  IAP doesn't work in Sim 4.3, but does in 5.0
//  http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/
//  http://troybrant.net/blog/2010/01/invalid-product-ids/

#import "UpgradeViewController.h"
#import <StoreKit/StoreKit.h>
#import "DataManager.h"
#import "StratFile.h"
#import "AppDelegate.h"
#import "PageViewController.h"
#import "RootViewController.h"
#import "EditionManager.h"
#import "IAPCell.h"
#import "TitleCell.h"
#import "BoardVideoCell.h"
#import "IAPTCell.h"
#import "MenuNavController.h"
#import "UpgradeManager.h"
#import "MessageTextCell.h"
#import "Reachability.h"
#import "UIColor-Expanded.h"
#import "NSUserDefaults+StratPad.h"
#import "UserNotificationDisplayManager.h"

@interface ActionMessage : NSObject 
- (id)initWithMessage:(NSString*)msg action:(SEL)actn;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,assign) SEL action;
@end

@implementation ActionMessage
@synthesize message,action;
- (id)initWithMessage:(NSString*)msg action:(SEL)actn
{
    self = [super init];
    if (self) {
        self.message = msg;
        self.action = actn;
    }
    return self;
}
- (void)dealloc
{
    [message release];
    [super dealloc];
}
@end

@interface UpgradeViewController (Private)
-(void)showProgress;
-(void)hideProgress;
@end

@implementation UpgradeViewController
@synthesize tblInAppPurchases;

// the rootVC holds on to this VC so even if the popover disappears during a transaction, 
// we don't have to worry about cancelling anything

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = LocalizedString(@"MENU_UPGRADE_TITLE", nil); 
        storeManager_ = [[StoreManager alloc] initWithStoreManagerDelegate:self productIds:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [rows_ release];
    [loadingView_ release];
    [storeManager_ release];
    [tblInAppPurchases release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    rows_ = [[NSMutableArray arrayWithCapacity:5] retain];      
}

- (void)viewDidUnload
{
    [loadingView_ release], loadingView_ = nil;
    [rows_ release], rows_ = nil;

    [self setTblInAppPurchases:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self hideProgress];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (reachability.isReachable) {
        [self updateIAPs];
    } else {
        NSError *error = [NSError errorWithDomain:@"com.stratpad.error.offline" 
                                             code:503 
                                         userInfo:[NSDictionary dictionaryWithObject:LocalizedString(@"ERROR_NO_NETWORK", nil) 
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self productsReceived:nil withError:error];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - StoreManagerDelegate

- (void)productTransactionStarting:(NSString *)productIdentifier
{
	DLog(@"starting: %@", productIdentifier);
	[self showProgress];
}

- (void)productTransactionFinishing:(NSString*)productIdentifier withSuccess:(BOOL)success
{
	DLog(@"finished: %@; success: %d", productIdentifier, success);
	
	if (([productIdentifier isEqualToString:kProductIdPlusToPremiumUpgrade] ||
        [productIdentifier isEqualToString:kProductIdFreeToPremiumUpgrade] ||
        [productIdentifier isEqualToString:kProductIdFreeToPlusToPremiumUpgrade]
        ) && success) {
        // to premium
        
        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:productIdentifier forKey:keyProductId];
        
        [UpgradeManager upgradeToPremium];
             
        // go and get the iap's again - some might be applicable anymore
        [self updateIAPs];
                
	} else if ([productIdentifier isEqualToString:kProductIdFreeToPlusUpgrade] && success) {
        // to plus
        
        // if we're restoring, and we have already restored to Premium (or greater), then don't bother
        if ([[EditionManager sharedManager] isEffectivelyPremium]) {
            ILog(@"Already restored to premium - skipping plus upgrade");
            return;
        }

        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:productIdentifier forKey:keyProductId];
        
        // need to give them a free, editable file
        [UpgradeManager upgradeToPlus];
        
        // go and get the iap's again - some might be applicable anymore
        [self updateIAPs];
        
    } else if (([productIdentifier isEqualToString:kProductIdPlus_StratBoardUpgrade] ||
                [productIdentifier isEqualToString:kProductIdPlusToPremium_StratBoardUpgrade] ||
                
                [productIdentifier isEqualToString:kProductIdPremium_StratBoardUpgrade] ||
                
//                [productIdentifier isEqualToString:kProductIdFree_StratBoardUpgrade] || // doesn't exist at this point
                [productIdentifier isEqualToString:kProductIdFreeToPlus_StratBoardUpgrade] ||
                [productIdentifier isEqualToString:kProductIdFreeToPremium_StratBoardUpgrade] ||
                [productIdentifier isEqualToString:kProductIdFreeToPlusToPremium_StratBoardUpgrade]
                 ) && success) {
        // add stratboard

        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:productIdentifier forKey:keyStratboard];
        
        // have to reload the nav, so that we can see the StratBoard
        [UpgradeManager upgradeToStratBoard];
        
        // just show the purchase label
        [tblInAppPurchases reloadData];
                
    } else if ([productIdentifier isEqualToString:kProductIdFree_Plus_Stratboard_ComboUpgrade] && success) {
        // to plus and stratboard
        
        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        
        // have to reload the nav, so that we can see the StratBoard
        [userDefaults setValue:productIdentifier forKey:keyStratboard];
        [UpgradeManager upgradeToStratBoard];
        
        // if we're restoring, and we have already restored to Premium (or greater), then don't bother
        if ([[EditionManager sharedManager] isEffectivelyPremium]) {
            ILog(@"Already restored to premium - skipping plus+straboard combo upgrade");
        } else {
            [userDefaults setValue:kProductIdFreeToPlusUpgrade forKey:keyProductId];
            
            // need to give them a free, editable file
            [UpgradeManager upgradeToPlus];            
        }
        
        // go and get the iap's again - some might be applicable anymore
        [self updateIAPs];

    } else if ([productIdentifier isEqualToString:kProductIdFree_Premium_Stratboard_ComboUpgrade] && success) {
        // to premium and stratboard
        
        // this is what controls look for throughout the app
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // have to reload the nav, so that we can see the StratBoard
        [userDefaults setValue:productIdentifier forKey:keyStratboard];
        [UpgradeManager upgradeToStratBoard];
        
        [userDefaults setValue:kProductIdFreeToPremiumUpgrade forKey:keyProductId];
        
        // unlock
        [UpgradeManager upgradeToPremium];
        
        // go and get the iap's again
        [self updateIAPs];

    } else {
        WLog(@"Unhandled product id: %@", productIdentifier);
    }
    
    if (success) {
        [[UserNotificationDisplayManager sharedManager] showMessage:LocalizedString(@"UPGRADE_THANKS", nil)];
    }
	
	[self hideProgress];
}


- (void)productsReceived:(NSArray*)products withError:(NSError *)error
{
    if (error == nil) {
        
        // clear up data model
        [rows_ removeAllObjects];
        
        // these are all the IAPs for Free for Plus or Premium
        NSSet *iaps = [NSSet setWithArray:[[EditionManager sharedManager] inAppPurchasesForProduct]];
                        
        // some of them may/may not apply if we have upgraded/not upgraded
        
        NSMutableArray* productArray = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableArray* boardArray = [[NSMutableArray alloc] initWithCapacity:2];
        
        for (SKProduct *product in products) {
            DLog(@"prod: %@, %@, %@, %@", product.productIdentifier, product.localizedTitle, product.localizedDescription, [StoreManager priceAsString:product]);
            
            // only add a product id if it also exists in iaps
            if ([iaps containsObject:product.productIdentifier]) {
                
                if ([product.productIdentifier containsString:@".stratbord"]) {
                    [boardArray addObject:product];
                }
                else {
                    [productArray addObject:product];
                }
                
                //[rows_ addObject:product];
            }
        }
        
        if ([productArray count] > 0) {
            ActionMessage* message = [[ActionMessage alloc] initWithMessage:@"Product" action:nil];
            [rows_ addObject:message];
            [message release];
            
            [rows_ addObject:productArray];
            [productArray release];
        }
        
        if ([boardArray count] > 0) {
            ActionMessage* message1 = [[ActionMessage alloc] initWithMessage:@"Board" action:nil];
            [rows_ addObject:message1];
            [message1 release];
            
            [rows_ addObject:boardArray];
            [boardArray release];
            
            ActionMessage* message2 = [[ActionMessage alloc] initWithMessage:@"Video" action:nil];
            [rows_ addObject:message2];
            [message2 release];
        }
        
        if ([rows_ count] == 0) {
            // if no rows, add a message
            ActionMessage *actionMessage = [[ActionMessage alloc] initWithMessage:LocalizedString(@"UPGRADE_NO_PURCHASES", nil) action:nil];
            [rows_ addObject:actionMessage];
            [actionMessage release];

        } else {
            // add restore instructions
            ActionMessage *actionMessage = [[ActionMessage alloc] initWithMessage:LocalizedString(@"UPGRADE_RESTORE_PURCHASES", nil) 
                                                                           action:@selector(restorePurchases)];
            [rows_ addObject:actionMessage];
            [actionMessage release];
        }
        
    } else {
        NSString *errorText = error.localizedDescription;
        NSString *format = [errorText hasSuffix:@"."] ? @" %@" : @". %@";
        errorText = [errorText stringByAppendingFormat:format, LocalizedString(@"UPGRADE_TRY_LATER", nil)];
                
        ActionMessage *actionMessage = [[ActionMessage alloc] initWithMessage:errorText action:nil];
        [rows_ addObject:actionMessage];
        [actionMessage release];
    }
    
    // reload the table for the new products
    [tblInAppPurchases reloadData];
    
    // calculate its height
    CGFloat height = 0;
    for (uint i=0,ct=[rows_ count]; i<ct; ++i) {
        height += [self tableView:tblInAppPurchases heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }

    // cumulative height includes the height of the navcontroller
    [[(MenuNavController*)self.navigationController popoverController] setPopoverContentSize:CGSizeMake(self.view.frame.size.width, height+44) animated:YES];

    [self hideProgress];
}

- (void)restoreFailed
{
    [self hideProgress];
}

- (void)restoreCompleted
{
    [self hideProgress];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id rowObj = [rows_ objectAtIndex:[indexPath row]];
    if ([rowObj isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray* array = (NSMutableArray*)[rows_ objectAtIndex:[indexPath row]];
        if ([array count] == 1) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IAPCell" owner:self options:nil];
            IAPCell *cell = (IAPCell*)[topLevelObjects objectAtIndex:0];
            
            SKProduct *product = [array objectAtIndex:0];
            
            // adjust the height of the description up to 150px
            CGSize size = [product.localizedDescription sizeWithFont:cell.lblDescription.font
                                                   constrainedToSize:CGSizeMake(cell.lblDescription.bounds.size.width, 150)
                                                       lineBreakMode:UILineBreakModeWordWrap];
            CGFloat h = cell.bounds.size.height - cell.lblDescription.bounds.size.height + size.height;
            TLog(@"h: %f", h);
            return h;
        }
        else {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IAPTCell" owner:self options:nil];
            IAPTCell *cell = (IAPTCell*)[topLevelObjects objectAtIndex:0];
            
            SKProduct *productOne = [array objectAtIndex:0];
            
            // adjust the height of the description up to 150px
            CGSize size = [productOne.localizedDescription sizeWithFont:cell.lblDescriptionOne.font
                                                   constrainedToSize:CGSizeMake(cell.lblDescriptionOne.bounds.size.width, 150)
                                                       lineBreakMode:UILineBreakModeWordWrap];
            CGFloat h1 = cell.bounds.size.height - cell.lblDescriptionOne.bounds.size.height + size.height;
            
            SKProduct *productTwo = [array objectAtIndex:1];
            
            // adjust the height of the description up to 150px
            CGSize size1 = [productTwo.localizedDescription sizeWithFont:cell.lblDescriptionTwo.font
                                                      constrainedToSize:CGSizeMake(cell.lblDescriptionTwo.bounds.size.width, 150)
                                                          lineBreakMode:UILineBreakModeWordWrap];
            CGFloat h2 = cell.bounds.size.height - cell.lblDescriptionTwo.bounds.size.height + size1.height;
            
            if (h1 > h2) return h1;
            return h2;
        }
    }
    else { // ActionMessage
        // match font size in MessageTextCell.xib
        NSString *text = [(ActionMessage*)rowObj message];
        if ([text isEqualToString:@"Board"]) {
            return 44;
        }
        else if ([text isEqualToString:@"Product"]) {
            return 44;
        }
        else if ([text isEqualToString:@"Video"]) {
            return 240;
        }
        else {
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14]
                           constrainedToSize:CGSizeMake(tableView.bounds.size.width-30, 999)
                               lineBreakMode:UILineBreakModeWordWrap];
            return MAX(size.height, 44);
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rows_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    id rowObj = [rows_ objectAtIndex:[indexPath row]];
    
    if ([rowObj isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray* array = (NSMutableArray*) [rows_ objectAtIndex:[indexPath row]];
        if ([array count] == 1) {
            static NSString *IAPCellIdentifier = @"IAPCell";
            IAPCell *cell = [tableView dequeueReusableCellWithIdentifier:IAPCellIdentifier];
            if (cell == nil) {
                // not localized
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:IAPCellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            SKProduct *product = [array objectAtIndex:0];
            cell.product = product;
            
            // title
            cell.lblTitle.text = product.localizedTitle;
            
            // the autosizing mask will resize the height if we can get the cell height right
            cell.lblDescription.text = product.localizedDescription;
            
            // price
            [cell.btnPurchase setTitle:[StoreManager priceAsString:product] forState:UIControlStateNormal];
            cell.target = self;
            
            // see if this IAP has been purchased already
            // this is either an edition upgrade, or stratboard
            EditionManager *editionManager = [EditionManager sharedManager];
            if ([product.productIdentifier hasSuffix:@".stratbord"]) {
                BOOL isStratBoardPurchased = [editionManager isFeatureEnabled:FeatureHasStratBoard];
                cell.btnPurchase.enabled = !isStratBoardPurchased;
                cell.lblPurchased.hidden = !isStratBoardPurchased;
            } else {
                // was an edition upgrade
                if ([editionManager isFree]) {
                    BOOL isPlusPurchased = ([product.productIdentifier isEqualToString:kProductIdFreeToPlusUpgrade]
                                            && [editionManager isEffectivelyPlus]);
                    if (isPlusPurchased) {
                        cell.btnPurchase.enabled = NO;
                        cell.lblPurchased.hidden = NO;
                    } else {
                        BOOL isPremiumPurchased = ([product.productIdentifier isEqualToString:kProductIdFreeToPlusToPremiumUpgrade]
                                                   && [editionManager isEffectivelyPremium]);
                        cell.btnPurchase.enabled = !isPremiumPurchased;
                        cell.lblPurchased.hidden = !isPremiumPurchased;
                    }
                } else if ([editionManager isPlus]) {
                    BOOL isPremium = [editionManager isEffectivelyPremium];
                    cell.btnPurchase.enabled = !isPremium;
                    cell.lblPurchased.hidden = !isPremium;
                }
                
            }
            
            return cell;
        }
        else {
            static NSString *IAPCellIdentifier = @"IAPTCell";
            IAPTCell *cell = [tableView dequeueReusableCellWithIdentifier:IAPCellIdentifier];
            if (cell == nil) {
                // not localized
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:IAPCellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            SKProduct *productOne = [array objectAtIndex:0];
            cell.productOne = productOne;
            
            // title
            cell.lblTitleOne.text = productOne.localizedTitle;
            
            // the autosizing mask will resize the height if we can get the cell height right
            cell.lblDescriptionOne.text = productOne.localizedDescription;
            
            // price
            [cell.btnPurchaseOne setTitle:[StoreManager priceAsString:productOne] forState:UIControlStateNormal];
            cell.targetOne = self;
            
            // see if this IAP has been purchased already
            // this is either an edition upgrade, or stratboard
            EditionManager *editionManager = [EditionManager sharedManager];
            if ([productOne.productIdentifier hasSuffix:@".stratbord"]) {
                BOOL isStratBoardPurchased = [editionManager isFeatureEnabled:FeatureHasStratBoard];
                cell.btnPurchaseOne.enabled = !isStratBoardPurchased;
                cell.lblPurchased.hidden = !isStratBoardPurchased;
            } else {
                // was an edition upgrade
                if ([editionManager isFree]) {
                    BOOL isPlusPurchased = ([productOne.productIdentifier isEqualToString:kProductIdFreeToPlusUpgrade]
                                            && [editionManager isEffectivelyPlus]);
                    if (isPlusPurchased) {
                        cell.btnPurchaseOne.enabled = NO;
                        cell.lblPurchased.hidden = NO;
                    } else {
                        BOOL isPremiumPurchased = ([productOne.productIdentifier isEqualToString:kProductIdFreeToPlusToPremiumUpgrade]
                                                   && [editionManager isEffectivelyPremium]);
                        cell.btnPurchaseOne.enabled = !isPremiumPurchased;
                        cell.lblPurchased.hidden = !isPremiumPurchased;
                    }
                } else if ([editionManager isPlus]) {
                    BOOL isPremium = [editionManager isEffectivelyPremium];
                    cell.btnPurchaseOne.enabled = !isPremium;
                    cell.lblPurchased.hidden = !isPremium;
                }
                
            }
            
            SKProduct *productTwo = [array objectAtIndex:1];
            cell.productTwo = productTwo;
            
            // title
            cell.lblTitleTwo.text = productTwo.localizedTitle;
            
            // the autosizing mask will resize the height if we can get the cell height right
            cell.lblDescriptionTwo.text = productTwo.localizedDescription;
            
            // price
            [cell.btnPurchaseTwo setTitle:[StoreManager priceAsString:productTwo] forState:UIControlStateNormal];
            cell.targetTwo = self;
            
            // see if this IAP has been purchased already
            // this is either an edition upgrade, or stratboard
            if ([productTwo.productIdentifier hasSuffix:@".stratbord"]) {
                BOOL isStratBoardPurchased = [editionManager isFeatureEnabled:FeatureHasStratBoard];
                cell.btnPurchaseTwo.enabled = !isStratBoardPurchased;
                cell.lblPurchasedTwo.hidden = !isStratBoardPurchased;
            } else {
                // was an edition upgrade
                if ([editionManager isFree]) {
                    BOOL isPlusPurchased = ([productTwo.productIdentifier isEqualToString:kProductIdFreeToPlusUpgrade]
                                            && [editionManager isEffectivelyPlus]);
                    if (isPlusPurchased) {
                        cell.btnPurchaseTwo.enabled = NO;
                        cell.lblPurchased.hidden = NO;
                    } else {
                        BOOL isPremiumPurchased = ([productTwo.productIdentifier isEqualToString:kProductIdFreeToPlusToPremiumUpgrade]
                                                   && [editionManager isEffectivelyPremium]);
                        cell.btnPurchaseTwo.enabled = !isPremiumPurchased;
                        cell.lblPurchasedTwo.hidden = !isPremiumPurchased;
                    }
                } else if ([editionManager isPlus]) {
                    BOOL isPremium = [editionManager isEffectivelyPremium];
                    cell.btnPurchaseTwo.enabled = !isPremium;
                    cell.lblPurchasedTwo.hidden = !isPremium;
                }
            }
            
            return cell;
        }
    }
    else {
        ActionMessage *actionMessage = (ActionMessage*)[rows_ objectAtIndex:[indexPath row]];
        if ([actionMessage.message isEqualToString:@"Product"]) {
            static NSString* identifier = @"TitleCell";
            TitleCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"titleCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            return cell;
        }
        else if ([actionMessage.message isEqualToString:@"Video"]) {
            static NSString* identifier = @"BoardVideoCell";
            BoardVideoCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BoardVideoCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            cell.controller = self;
            return cell;
        }
        else if ([actionMessage.message isEqualToString:@"Board"]) {
            static NSString* identifier = @"TitleCell";
            TitleCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"titleCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.titleText.text = @"GET STRATBOARD: CREATE GORGEOUS CHARTS AND TRACK YOUR PROGRESS!";
            return cell;
        }
        else {
            static NSString *MessageTextCellIdentifier = @"MessageTextCell";
            MessageTextCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageTextCellIdentifier];
            if (cell == nil) {
                // not localized
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MessageTextCellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            ActionMessage *actionMessage = (ActionMessage*)[rows_ objectAtIndex:[indexPath row]];
            if ([self respondsToSelector:actionMessage.action]) {
                cell.lblText.hidden = YES;
                cell.btnRestorePurchases.hidden = NO;
                
                [cell.btnRestorePurchases setTitle:actionMessage.message forState:UIControlStateNormal];
                [cell.btnRestorePurchases addTarget:self action:actionMessage.action forControlEvents:UIControlEventTouchUpInside];
                
            } else {
                cell.lblText.hidden = NO;
                cell.btnRestorePurchases.hidden = YES;
                cell.lblText.text = actionMessage.message;
            }
            
            return cell;
        }
    }
}

-(void) playBoardVideo {
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    //[rootViewController dismissAllMenus];
    MPMoviePlayerViewController* player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SP iPad StratBoard" ofType:@"mp4"]]];
    [player.view setBounds:rootViewController.view.bounds];
    [player.moviePlayer prepareToPlay];
    [player.moviePlayer setFullscreen:YES animated:YES];
    [player.moviePlayer setShouldAutoplay:YES];
    [player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [self presentMoviePlayerViewControllerAnimated:player];
    
    [player release];
}

#pragma mark - Supporting Methods

-(void)showProgress
{
    [loadingView_ removeFromSuperview];
    loadingView_ = [[MBLoadingView alloc] initWithFrame:self.view.bounds];
    [loadingView_ showInView:self.view];
}

-(void)hideProgress
{
    [loadingView_ dismiss];
    [loadingView_ release]; loadingView_ = nil;
}

-(void)restorePurchases
{
    [self showProgress];
    
    // because we may have upgraded to plus, and then to premium or then to stratboard, we need to make sure all IAP's are possible here
    // when productTransactionFinishing, we need to have the logic in place to deal with all those scenarios (and sequences)
    NSArray *productIds = [[EditionManager sharedManager] inAppPurchasesForAllEditions];
    [storeManager_ setProductIds:productIds];
    
    [storeManager_ restorePurchases];
}

-(void)updateIAPs
{
    NSArray *productIds = [[EditionManager sharedManager] inAppPurchasesForProduct];
    [storeManager_ setProductIds:productIds];
    [storeManager_ requestProductData];
    [self showProgress];        
}


#pragma mark - Actions

- (void)purchaseUpgrade:(SKProduct*)product {
    // called from IAPCell
    [storeManager_ purchaseUpgrade:product];
}


@end
