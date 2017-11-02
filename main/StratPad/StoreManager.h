//
//  QuizillatorStoreManager.h
//  Quizillator
//
//  Created by Julian Wood on 10-08-06.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "StoreObserver.h"

@protocol PurchaseViewFinishedDelegate;

// the delegate to notify when transactions start, finish and provide product info
@protocol StoreManagerDelegate<NSObject>
@required
- (void)productTransactionFinishing:(NSString*)productIdentifier withSuccess:(BOOL)success;
- (void)productTransactionStarting:(NSString*)productIdentifier;
- (void)productsReceived:(NSArray*)products withError:(NSError *)error;
- (void)restoreFailed;
- (void)restoreCompleted;
@end

@interface StoreManager : NSObject<SKProductsRequestDelegate,StoreObserverDelegate> {
	StoreObserver *storeObserver_;	
	id<StoreManagerDelegate> storeManagerDelegate_;
	NSArray* productIds_;
}

@property (nonatomic,retain) NSArray *productIds;

// @param productInfo a dict of productId (key) and the key used in NSUserDefaults (value)
- (id)initWithStoreManagerDelegate:(id<StoreManagerDelegate>)storeManagerDelegate 
                        productIds:(NSArray*)productIds;


// initiates the process of purchasing an IAP
-(void)purchaseUpgrade: (SKProduct*)product;

// will try to restore previous transactions, and hit SKProductsRequestDelegate methods 
-(void)restorePurchases;

// grab info for provided product ids, and notify the StoreManagerDelegate when received
- (void)requestProductData;

// formats the price from an SKProduct
+(NSString*)priceAsString:(SKProduct*)skProduct;

@end

