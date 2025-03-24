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
    self.navigationBar.tintColor = [UIColor themeTextColor];
    self.toolbar.tintColor = [UIColor themeTextColor];

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
        NSForegroundColorAttributeName: [UIColor themeTextColor],
        NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]
    };

    NSDictionary *largeTitleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor themeTextColor],
        NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:40]
    };

    // Create and update navigation bar appearance for dynamic theme color
    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navigationBarAppearance configureWithDefaultBackground];
    navigationBarAppearance.backgroundColor = [UIColor themeColor];
    navigationBarAppearance.titleTextAttributes = titleTextAttributes;
    navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes;
    navigationBarAppearance.shadowColor = [UIColor clearColor];
    navigationBarAppearance.shadowImage = [UIImage new];

    // Reset and configure toolbar appearance
    UIToolbarAppearance *toolBarAppearance = [[UIToolbarAppearance alloc] init];
    [toolBarAppearance configureWithDefaultBackground];
    toolBarAppearance.backgroundColor = [UIColor themeColor];
    toolBarAppearance.shadowColor = [UIColor clearColor];
    toolBarAppearance.shadowImage = [UIImage new];

    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView performWithoutAnimation:^{
            // Update navigation bar appearance
            weakSelf.navigationBar.standardAppearance = navigationBarAppearance;
            weakSelf.navigationBar.compactAppearance = navigationBarAppearance;
            weakSelf.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
            weakSelf.navigationBar.tintColor = [UIColor themeTextColor];
            weakSelf.navigationBar.barTintColor = [UIColor themeColor];
            
            // Update toolbar appearance
            weakSelf.toolbar.standardAppearance = toolBarAppearance;
            weakSelf.toolbar.compactAppearance = toolBarAppearance;
            weakSelf.toolbar.tintColor = [UIColor themeTextColor];
            weakSelf.toolbar.barTintColor = [UIColor themeColor];
            
            // Force layout update
            [weakSelf.navigationBar setNeedsLayout];
            [weakSelf.navigationBar layoutIfNeeded];
            [weakSelf.toolbar setNeedsLayout];
            [weakSelf.toolbar layoutIfNeeded];
            
            // Update all navigation and toolbar items
            [weakSelf updateNavigationBarItemColors];
            
            // Force immediate update of the view hierarchy
            [weakSelf.view setNeedsLayout];
            [weakSelf.view layoutIfNeeded];
            
            // Post notification for other views to update
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BarButtonItemsNeedUpdate" object:nil];
        }];
    });

    // Force visibility in inverted mode
    self.navigationBar.backgroundColor = [UIColor themeColor];
    self.toolbar.backgroundColor = [UIColor themeColor];

    // Update barTintColor for better visibility
    self.navigationBar.barTintColor = [UIColor themeColor];
    self.toolbar.barTintColor = [UIColor themeColor];

    // Force redraw by updating frame
    CGRect navFrame = self.navigationBar.frame;
    self.navigationBar.frame = CGRectMake(navFrame.origin.x, navFrame.origin.y, navFrame.size.width + 1, navFrame.size.height);
    self.navigationBar.frame = navFrame;

    CGRect toolFrame = self.toolbar.frame;
    self.toolbar.frame = CGRectMake(toolFrame.origin.x, toolFrame.origin.y, toolFrame.size.width + 1, toolFrame.size.height);
    self.toolbar.frame = toolFrame;
}

// Method to update tint colors for individual navigation bar and toolbar items
- (void)updateNavigationBarItemColors {
    // Update all items in the navigation bar
    for (UIViewController *viewController in self.viewControllers) {
        // Update left items
        for (UIBarButtonItem *item in viewController.navigationItem.leftBarButtonItems) {
            item.tintColor = [UIColor themeTextColor];
        }
        
        // Update right items
        for (UIBarButtonItem *item in viewController.navigationItem.rightBarButtonItems) {
            item.tintColor = [UIColor themeTextColor];
        }
        
        // Update toolbar items
        for (UIBarButtonItem *item in viewController.toolbarItems) {
            item.tintColor = [UIColor themeTextColor];
        }
    }
    
    // Force update the current view controller's items
    [self.topViewController.navigationItem.leftBarButtonItems makeObjectsPerformSelector:@selector(setTintColor:) withObject:[UIColor themeTextColor]];
    [self.topViewController.navigationItem.rightBarButtonItems makeObjectsPerformSelector:@selector(setTintColor:) withObject:[UIColor themeTextColor]];
    
    // Update toolbar items
    [self.toolbar.items makeObjectsPerformSelector:@selector(setTintColor:) withObject:[UIColor themeTextColor]];
}

// Update the theme or perform actions in response to the notification
- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSLog(@"Theme has been changed!");
    [self updateNavigationAndToolbarAppearance];
}

// Add viewWillAppear override to ensure updates when views appear
- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    [self updateNavigationBarItemColors];
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
