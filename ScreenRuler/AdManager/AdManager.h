// AdManager.h
// Screen Ruler

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h> // UIViewController ko use karne ke liye

NS_ASSUME_NONNULL_BEGIN

@interface AdManager : NSObject

// Singleton method to get the shared instance of AdManager
+ (instancetype)sharedManager;

// Methods to load and show interstitial ads
- (void)loadInterstitialAd;
- (void)showAd:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
//

#ifndef AdManager_h
#define AdManager_h


#endif /* AdManager_h */
