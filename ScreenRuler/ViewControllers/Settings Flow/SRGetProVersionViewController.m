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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.subscriptionButton.enabled = NO;
    [self requestProductInfo];
    self.backButton.tintColor = [UIColor themeColor];
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
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.infoenum.ruler_for_1_month", @"com.infoenum.ruler_for_1_year", nil];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (response.products.count > 0) {
        self.availableProducts = response.products;
    } else {
        NSLog(@"No products found");
    }
}

- (IBAction)monthlyViewTapped:(id)sender {
    self.subscriptionButton.enabled = YES;
    self.yearlySubscriptionView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.subscriptionButton setTitle:@"Monthly Subscription" forState:UIControlStateNormal];
    self.monthlySubscriptionView.layer.borderColor = [UIColor greenColor].CGColor;


    [self setSelectedProductForMonthlySubscription];
}

- (IBAction)yearlyViewTapped:(id)sender {
    self.subscriptionButton.enabled = YES;
    self.monthlySubscriptionView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.subscriptionButton setTitle:@"Yearly Subscription" forState:UIControlStateNormal];
    self.yearlySubscriptionView.layer.borderColor = [UIColor greenColor].CGColor;


    [self setSelectedProductForYearlySubscription];
}

- (void)setSelectedProductForMonthlySubscription {

    self.selectedProduct = nil;
    for (SKProduct *product in self.availableProducts) {
        if ([product.productIdentifier isEqualToString:@"com.infoenum.ruler_for_1_month"]) {
            self.selectedProduct = product;
            break;
        }
    }
}

- (void)setSelectedProductForYearlySubscription {

    self.selectedProduct = nil;
    for (SKProduct *product in self.availableProducts) {
        if ([product.productIdentifier isEqualToString:@"com.infoenum.ruler_for_1_year"]) {
            self.selectedProduct = product;
            break;
        }
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

- (IBAction)backButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self handlePurchaseSuccessForTransaction:transaction];
                break;

            case SKPaymentTransactionStateFailed:
                [self handlePurchaseFailureForTransaction:transaction];
                break;

            case SKPaymentTransactionStateRestored:
                [self handleRestoreSuccessForTransaction:transaction];
                break;

            default:
                break;
        }
    }
}


- (void)handlePurchaseSuccessForTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Purchase Successful");

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [AdManager sharedManager].isSubscribed = YES;
    [[AdManager sharedManager] saveSubscriptionStatus];

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handlePurchaseFailureForTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Purchase Failed: %@", transaction.error.localizedDescription);
    [AdManager sharedManager].isSubscribed = NO;
    [[AdManager sharedManager] saveSubscriptionStatus];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)handleRestoreSuccessForTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Restore Successful");
    [AdManager sharedManager].isSubscribed = YES;
    [[AdManager sharedManager] saveSubscriptionStatus];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
