//
//  QuizillatorStoreManager.m
//  Quizillator
//
//  Created by Julian Wood on 10-08-06.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//

#import "StoreManager.h"
#import "SynthesizeSingleton.h"
#import "StoreObserver.h"
#import "Tracking.h"

@implementation StoreManager

@synthesize productIds=productIds_;

- (id)initWithStoreManagerDelegate:(id<StoreManagerDelegate>)storeManagerDelegate 
                       productIds:(NSArray*)productIds;
{
    self = [super init];
    if (self) {
        productIds_ = [productIds retain];
        storeManagerDelegate_ = [storeManagerDelegate retain];
		storeObserver_ = [[StoreObserver alloc] initWithStoreObserverDelegate:self];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:storeObserver_];
    }
    return self;    
}

- (void)dealloc {
    [storeManagerDelegate_ release];
    [productIds_ release];
    [storeObserver_ release];
    [super dealloc];
}

#pragma mark - StoreObserverDelegate

- (void)restoreFailed
{
    [storeManagerDelegate_ restoreFailed];
}

- (void)restoreCompleted
{
    [storeManagerDelegate_ restoreCompleted];
}

- (void)recordTransaction: (SKPaymentTransaction*)transaction
{
	NSString *description;
	if (transaction.transactionState == SKPaymentTransactionStateRestored) {
		description = transaction.originalTransaction.payment.productIdentifier;
	} else {
		description = transaction.payment.productIdentifier;
        
        // track the transaction with google
        [Tracking trackTransaction:transaction.transactionIdentifier productId:description];
	}
    
	[Tracking logEvent:kTrackingEventIAP withParameters:[NSDictionary dictionaryWithObject:description forKey:@"description"]];
}

-(void)failedTransaction: (SKPaymentTransaction*)transaction
{
	NSString *productIdentifier;
	if (transaction.transactionState == SKPaymentTransactionStateRestored) {
		productIdentifier = transaction.originalTransaction.payment.productIdentifier;
	} else {
		productIdentifier = transaction.payment.productIdentifier;
	}
	
	[storeManagerDelegate_ productTransactionFinishing:productIdentifier withSuccess:NO];
}

- (void)provideContent: (NSString*)productIdentifier
{
	ILog(@"purchase received: %@", productIdentifier);
		    
    if ([productIds_ indexOfObject:productIdentifier] == NSNotFound) {
        WLog(@"Unknown product id (or not suitable for this effective edition): %@", productIdentifier);
        [storeManagerDelegate_ productTransactionFinishing:productIdentifier withSuccess:NO];
        return;
    } else {
        [storeManagerDelegate_ productTransactionFinishing:productIdentifier withSuccess:YES];
        return;
    }		
}

#pragma mark - Public

-(void)purchaseUpgrade: (SKProduct*)product
{
	[storeManagerDelegate_ productTransactionStarting:product.productIdentifier];
	if ([SKPaymentQueue canMakePayments]) {
		SKPayment *payment = [SKPayment paymentWithProduct:product];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"NO_PAYMENTS_TITLE", nil)
														message:LocalizedString(@"NO_PAYMENTS_MSG", nil)
													   delegate:nil
											  cancelButtonTitle:LocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
		
}

- (void)restorePurchases {
	// so this is supposed to send off new txns to our observer, which would then update userDefaults as well
	// however, it doesn't for test users, even though when trying to buy an upgrade, it says it has already been purchased
	// pressing okay to re-download an already purchased item simply results in a failed txn - as if the user cancelled it
	//		- there is no apparent way to see that this failure should mean to unlock the functionality
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)requestProductData 
{
	TLog(@"Requesting product data with product ids: %@", productIds_);
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
								 [NSSet setWithArray:productIds_]];
	request.delegate = self;
	[request start];
}	


#pragma mark - SKProductsRequestDelegate

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	WLog(@"%@", error); // usually cause we're in 4.3 simulator; 5.0 simulator works
	[storeManagerDelegate_ productsReceived:nil withError:error];
	[request autorelease];
}

- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response 
{
	TLog(@"Received product data: %@", response.products);
	[storeManagerDelegate_ productsReceived:response.products withError:nil];		
	[request autorelease];
}

#pragma mark - Support

+(NSString*)priceAsString:(SKProduct*)skProduct
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setLocale:[skProduct priceLocale]];
	
	NSString *str = [formatter stringFromNumber:[skProduct price]];
	[formatter release];
	return str;
}


@end
