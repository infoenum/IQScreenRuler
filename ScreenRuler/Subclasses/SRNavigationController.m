//
//  SRNavigationController.m
//  ScreenRuler
//
//  Created by Iftekhar on 02/11/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SRNavigationController.h"
#import <UIKit/UIKit.h>
#import "UIColor+ThemeColor.h"

@interface SRNavigationController ()

@end

@implementation SRNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up navigation bar and toolbar appearance
    [self updateNavigationAndToolbarAppearance];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.toolbar.tintColor = [UIColor whiteColor];

    [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];

    [self.toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleThemeChangedNotification:)
                                                 name:@"ThemeChangedNotification"
                                               object:nil];
}

// Remove the observer when the view controller is deallocated
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ThemeChangedNotification"
                                                  object:nil];
}

// Set up the title text attributes for the navigation bar and large title
- (void)updateNavigationAndToolbarAppearance {
    NSDictionary *titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor themeBackgroundColor],
        NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]
    };

    NSDictionary *largeTitleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor themeBackgroundColor],
        NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:40]
    };

    // Create and update navigation bar appearance for dynamic theme color
    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    navigationBarAppearance.backgroundColor = [UIColor themeColor];
    navigationBarAppearance.titleTextAttributes = titleTextAttributes;
    navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes;
    navigationBarAppearance.shadowColor = [UIColor clearColor];
    navigationBarAppearance.shadowImage = [UIImage new];

    self.navigationBar.standardAppearance = navigationBarAppearance;
    self.navigationBar.compactAppearance = navigationBarAppearance;
    self.navigationBar.scrollEdgeAppearance = navigationBarAppearance;

    if (@available(iOS 15.0, *)) {
        self.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance;
    }

    // Set the tint color for the navigation bar items (icons, buttons, etc.)
    self.navigationBar.tintColor = [UIColor themeTextColor];

    // Set up toolbar appearance for dynamic theme color
    UIToolbarAppearance *toolBarAppearance = [[UIToolbarAppearance alloc] init];
    toolBarAppearance.backgroundColor = [UIColor themeColor];
    toolBarAppearance.shadowColor = [UIColor clearColor];
    toolBarAppearance.shadowImage = [UIImage new];

    self.toolbar.standardAppearance = toolBarAppearance;
    self.toolbar.compactAppearance = toolBarAppearance;

    if (@available(iOS 15.0, *)) {
        self.toolbar.scrollEdgeAppearance = toolBarAppearance;
        self.toolbar.compactScrollEdgeAppearance = toolBarAppearance;
    }


    self.toolbar.tintColor = [UIColor themeTextColor];
    [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];

    [self.toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
}

// Update the theme or perform actions in response to the notification
- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSLog(@"Theme has been changed!");
    [self updateNavigationAndToolbarAppearance];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateNavigationAndToolbarAppearance];
}

- (void)changeThemeColor {
    [self updateNavigationAndToolbarAppearance];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) weakSelf = self;

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            BOOL hidden = (size.width > size.height);
            [weakSelf setNavigationBarHidden:hidden animated:YES];
            [weakSelf setToolbarHidden:hidden animated:YES];
        }

    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
}

@end
