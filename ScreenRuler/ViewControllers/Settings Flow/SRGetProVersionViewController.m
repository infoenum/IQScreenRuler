//
//  SRGetProVersionViewController.m
//  ScreenRuler
//
//  Created by IE13 on 13/03/25.
//  Copyright © 2025 InfoEnum Software Systems. All rights reserved.
//
#import "SRGetProVersionViewController.h"
#import "UIColor+ThemeColor.h"
#import "UIImage+Color.h"
#import <StoreKit/StoreKit.h>
#import "AdManager.h"

@interface SRGetProVersionViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (strong, nonatomic) SKProduct *selectedProduct;
@property (strong, nonatomic) NSArray<SKProduct *> *availableProducts;
@property (weak, nonatomic) IBOutlet UIView *monthlySubscriptionView;
@property (weak, nonatomic) IBOutlet UIView *yearlySubscriptionView;
@property (weak, nonatomic) IBOutlet UIButton *subscriptionButton;

@end

@implementation SRGetProVersionViewController

const NSString *productIdentifier = @"com.infoenum.ruler_non_consumable";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backButton.tintColor = [UIColor themeColor];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestProductInfo];
    [self setViewSubscription];
}
- (void)setViewSubscription {
    self.monthlySubscriptionView.layer.masksToBounds = false;
    self.monthlySubscriptionView.layer.shadowOpacity = 0.2;
    self.monthlySubscriptionView.layer.shadowRadius = 8;
    self.monthlySubscriptionView.layer.borderWidth = 0.90;
    self.monthlySubscriptionView.layer.cornerRadius = 10;

    self.yearlySubscriptionView.layer.masksToBounds = false;
    self.yearlySubscriptionView.layer.shadowOpacity = 0.2;
    self.yearlySubscriptionView.layer.shadowRadius = 8;
    self.yearlySubscriptionView.layer.borderWidth = 0.90;
    self.yearlySubscriptionView.layer.cornerRadius = 10;
}

- (void)requestProductInfo {
    NSSet *productIdentifiers = [NSSet setWithObject: productIdentifier];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.availableProducts = response.products;

    if (self.availableProducts.count > 0) {
        self.selectedProduct = self.availableProducts.firstObject;
        NSLog(@"Product is available: %@", self.selectedProduct.localizedTitle);
    } else {
        NSLog(@"Product not found");
    }
}

- (IBAction)continueButtonAction:(id)sender {
    if (self.selectedProduct) {
        SKPayment *payment = [SKPayment paymentWithProduct:self.selectedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"Product not available");
    }
}



- (void)handlePurchasedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Purchase successful: %@", transaction.payment.productIdentifier);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    [AdManager sharedManager].isSubscribed = YES;
    [[AdManager sharedManager] saveSubscriptionStatus];

    [self dismissViewControllerAnimated:YES completion:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Successful"
                                                                   message:@"You have successfully purchased the Pro version."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleFailedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Purchase failed: %@", transaction.error.localizedDescription);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Failed"
                                                                   message:transaction.error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)handleRestoredTransaction:(SKPaymentTransaction *)transaction {

    if (transaction.transactionState == SKPaymentTransactionStateRestored) {

        if (![transaction.payment.productIdentifier isEqualToString: productIdentifier]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Previous Purchases"
                                                                           message:@"You have not made any previous purchases to restore."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }

    NSLog(@"Transaction restored: %@", transaction.payment.productIdentifier);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    [AdManager sharedManager].isSubscribed = YES;
    [[AdManager sharedManager] saveSubscriptionStatus];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Content Restored"
                                                                   message:@"Your previous purchase has been restored."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)crossButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorePurchasesButtonTapped:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// new Delegate method-24 - 3- 2025
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self handlePurchasedTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self handleRestoredTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (queue.transactions.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Purchases"
                                                                       message:@"You haven't made any purchases to restore."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // Handle the case where purchases are restored
        for (SKPaymentTransaction *transaction in queue.transactions) {
            if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                NSLog(@"Transaction restored: %@", transaction.payment.productIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

                [AdManager sharedManager].isSubscribed = YES;
                [[AdManager sharedManager] saveSubscriptionStatus];

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Restored"
                                                                           message:@"Your previous purchase has been restored."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                                               }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

@end
