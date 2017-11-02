//
//  QuizillatorStoreObserver.m
//  Quizillator
//
//  Created by Julian Wood on 10-08-05.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import "StoreObserver.h"

@implementation StoreObserver

- (id)initWithStoreObserverDelegate:(id<StoreObserverDelegate>)storeObserverDelegate
{
    self = [super init];
    if (self) {
        storeObserverDelegate_ = storeObserverDelegate;
    }
    return self;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
			default:
				break;
		}
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	WLog(@"failed txn: %d, %@, %@, %@", transaction.error.code, transaction.error.domain, transaction.error.userInfo, transaction.payment.productIdentifier);
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Transaction Failed", @"")
															 message:transaction.error.localizedDescription
															delegate:nil 
												   cancelButtonTitle:LocalizedString(@"OK", nil)
												   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	[storeObserverDelegate_ failedTransaction:transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	DLog(@"restoring txn");
	[storeObserverDelegate_ recordTransaction: transaction];
	[storeObserverDelegate_ provideContent: transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	DLog(@"completing txn");
	[storeObserverDelegate_ recordTransaction: transaction];
	[storeObserverDelegate_ provideContent: transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - called after [[SKPaymentQueue defaultQueue] restoreCompletedTransactions]

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error 
{
	WLog(@"txns failed restore: %d", [queue.transactions count]);
    [storeObserverDelegate_ restoreFailed];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    // we really count on paymentQueue:updatedTransactions: to be called, so that restoreTransaction: is invoked
    // this is called for sure when there is nothing to be restored, and we finish up
	DLog(@"txns restored: %d", [queue.transactions count]);
    [storeObserverDelegate_ restoreCompleted];
}


@end