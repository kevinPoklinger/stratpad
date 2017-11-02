//
//  QuizillatorStoreObserver.h
//  Quizillator
//
//  Created by Julian Wood on 10-08-05.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol StoreObserverDelegate <NSObject>
@required

// notifies the delegate when a transaction completes or is restored
- (void)recordTransaction: (SKPaymentTransaction*)transaction;

// notifies the delegate that the transaction failed
- (void)failedTransaction: (SKPaymentTransaction*)transaction;

// notifies the delegate when a transaction completes or is restored
// also sets a key in the user defaults, corresponding to the key passed in with product info
- (void)provideContent: (NSString*)productIdentifier;

// a catch all for when a restore is cancelled, or fails, or completes normally (but maybe the other methods weren't invoked)
- (void)restoreFailed;

// after all txns have completed their restore (or if there were no txns to restore)
- (void)restoreCompleted;

@end

@interface StoreObserver : NSObject<SKPaymentTransactionObserver> {
    id<StoreObserverDelegate> storeObserverDelegate_;
}

- (id)initWithStoreObserverDelegate:(id<StoreObserverDelegate>)storeObserverDelegate;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;

@end