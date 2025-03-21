// AdManager.m
// Screen Ruler

#import "AdManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdManager ()  

@property (nonatomic, strong) GADInterstitialAd *interstitial;

@end

@implementation AdManager

+ (instancetype)sharedManager {
    static AdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance loadSubscriptionStatus];
    });
    return sharedInstance;
}

- (void)loadSubscriptionStatus {
    self.isSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
}

- (void)saveSubscriptionStatus {
    [[NSUserDefaults standardUserDefaults] setBool:self.isSubscribed forKey:@"isSubscribed"];
    [[NSUserDefaults standardUserDefaults] synchronize];  // Make sure it's saved immediately
}

- (void)loadInterstitialAd {
//#if DEBUG
//    
//#else
    [GADInterstitialAd
       loadWithAdUnitID:@"ca-app-pub-4071068218793215/1611921991"
                request:[GADRequest request]
      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            return;
        }
        self.interstitial = ad;
        self.interstitial.fullScreenContentDelegate = self;  
    }];
//#endif
}

- (void)showAd:(UIViewController *)viewController {
//#if DEBUG
//    
//#else
    if (self.interstitial && !self.isSubscribed) {
        [self.interstitial presentFromRootViewController:viewController];
    } else {
        NSLog(@"Interstitial ad is not ready yet.");
        [self loadInterstitialAd];
    }
    
//#endif
}


#pragma mark - GADInterstitialAdDelegate Methods

- (void)didDismissFullScreenContent {
    NSLog(@"Interstitial ad was dismissed.");
    [self loadInterstitialAd];
}


//#pragma GADFullScreeContentDelegate implementation
//
//// [START ad_events]
//- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
//  NSLog(@"%s called", __PRETTY_FUNCTION__);
//}
//
//- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
//  NSLog(@"%s called", __PRETTY_FUNCTION__);
//}
//
//- (void)ad:(id<GADFullScreenPresentingAd>)ad
//    didFailToPresentFullScreenContentWithError:(NSError *)error {
//  NSLog(@"%s called with error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
//  // Clear the interstitial ad.
//  self.interstitial = nil;
//}
//
//- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
//  NSLog(@"%s called", __PRETTY_FUNCTION__);
//}
//
//- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
//  NSLog(@"%s called", __PRETTY_FUNCTION__);
//}
//
//- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
//  NSLog(@"%s called", __PRETTY_FUNCTION__);
//  // Clear the interstitial ad.
//  self.interstitial = nil;
//}
@end
