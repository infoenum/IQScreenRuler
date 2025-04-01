// AdManager.h
// Screen Ruler

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h> // UIViewController ko use karne ke liye

NS_ASSUME_NONNULL_BEGIN

@interface AdManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL isSubscribed;

- (void)loadInterstitialAd;
- (void)showAd:(UIViewController *)viewController;
- (void)saveSubscriptionStatus;

@end

NS_ASSUME_NONNULL_END
//

#ifndef AdManager_h
#define AdManager_h


#endif /* AdManager_h */
