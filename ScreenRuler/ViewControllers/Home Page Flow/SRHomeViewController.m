//
//  ViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRHomeViewController.h"
#import "IQRulerView.h"
#import "IQProtractorView.h"
#import "SRToolbarButton.h"
#import "UIImage+Color.h"
#import "UIColor+HexColors.h"
#import <Photos/Photos.h>
#import "UIFont+AppFont.h"
#import "UIImage+Resizing.h"
#import "IQLineFrameView.h"
#import "ACMagnifyingGlass.h"
#import "MPCoachMarkView.h"
#import "IQGeometry+Rect.h"
#import "SREditOptionViewController.h"
#import "UIColor+ThemeColor.h"
#import <Social/Social.h>
#import "SRImagePickerController.h"
#import "IQScrollContainerView.h"
#import "SRScreenshotCollectionViewController.h"
#import "UIImage+fixOrientation.h"
#import <Crashlytics/Answers.h>
#import "SRSettingTableViewController.h"
#import "CBZSplashView.h"
#import "UIBezierPath+Shapes.h"
#import "SRDebugHelper.h"
#import "SROnboardingNavigationController.h"
#import "AdManager.h"

//https://www.iconfinder.com/iconsets/hawcons-gesture-stroke

@interface SRHomeViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIToolbarDelegate,UIPopoverPresentationControllerDelegate,MPCoachMarksViewDelegate,SRImageControllerDelegate,SRScreenshotCollectionViewControllerDelegate,IQLineFrameViewDelegate>
{
    BOOL isLockedOrientation;
    CGPoint protractorCenterInImage;
    CGPoint rulerCenterInImage;
}

@property (nonatomic, strong) NSTimer *coachMarkTimer;

@property(nonatomic, strong) ACMagnifyingGlass *magnifyingGlass;

@property(nonatomic, strong) IQRulerView *freeRulerView;

@property(nonatomic, strong) IQProtractorView *freeProtractorView;

@property (strong, nonatomic) IBOutlet IQLineFrameView *lineFrameView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@property (strong, nonatomic) IBOutlet IQScrollContainerView *scrollContainerView;

@property (strong, nonatomic) IBOutlet UIView *viewNoScreenshotInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelNoScreenshotsTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelNoScreenshotsDiscription;
@property (strong, nonatomic) IBOutlet UIButton *noScreenshotActionButton;


@property (strong, nonatomic) IBOutlet SRToolbarButton *sideRulerButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideRulerBarButton;
@property (strong, nonatomic) IBOutlet SRToolbarButton *freeHandButton; // Opacity button
@property (strong, nonatomic) IBOutlet UIBarButtonItem *freeHandBarButton;
@property (strong, nonatomic) IBOutlet SRToolbarButton *straighenButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *straightenBarButton;
@property (strong, nonatomic) IBOutlet SRToolbarButton *protractorButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *protractorBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editOptionBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rationBarButon;
@property (strong, nonatomic) IBOutlet SRToolbarButton *ratioButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *libraryBarButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsMenuBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *optionBarButton;

@property (strong, nonatomic) IBOutlet UIView *topColorView;
@property (strong, nonatomic) IBOutlet UIView *viewColorLabelContainer;
@property (strong, nonatomic) IBOutlet UILabel *labelRed;
@property (strong, nonatomic) IBOutlet UILabel *labelGreen;
@property (strong, nonatomic) IBOutlet UILabel *labelBlue;
@property (strong, nonatomic) IBOutlet UILabel *labelColorLocation;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingColorDataIndicator;
@property (strong, nonatomic) IBOutlet UISlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UIView *sliderView;

@property (nonatomic, strong) CBZSplashView *splashView;

@end

@implementation SRHomeViewController
@dynamic image;


-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AdManager sharedManager] loadInterstitialAd];
//    self.additionalSafeAreaInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    
    
    //    self.additionalSafeAreaInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kRASettingsChangedNotification object:nil];

        self.topColorView.translatesAutoresizingMaskIntoConstraints = YES;

        self.magnifyingGlass = [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 115, 115)];
        self.magnifyingGlass.viewToMagnify = self.scrollContainerView.imageView;

        BOOL shouldLineFrameShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"LineFrameShow"];
        BOOL shouldFreeHandRulerShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"FreeHandRulerShow"];
        BOOL shouldFreeProtractorShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"FreeProtractorShow"];
        BOOL shouldSideRulerShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"SideRulerShow"];

        {
            {
            self.sideRulerButton.layer.cornerRadius = 3.0;
            self.sideRulerButton.layer.masksToBounds = YES;
            self.sideRulerButton.selected = shouldSideRulerShow;
            self.sideRulerButton.frame = CGRectMake(0, 0, 35, 35);
        }
        
        {
            self.freeHandButton.layer.cornerRadius = 3.0;
            self.freeHandButton.layer.masksToBounds = YES;
            self.freeHandButton.selected = shouldFreeHandRulerShow;
            [self.freeHandButton addTarget:self action:@selector(freeRulerAction:) forControlEvents:UIControlEventTouchUpInside];
            self.freeHandButton.frame = CGRectMake(0, 0, 35, 35);
        }
        
        {
            self.protractorButton.layer.cornerRadius = 3.0;
            self.protractorButton.layer.masksToBounds = YES;
            self.protractorButton.selected = shouldFreeProtractorShow;
            [self.protractorButton addTarget:self action:@selector(protractorAction:) forControlEvents:UIControlEventTouchUpInside];
            self.protractorButton.frame = CGRectMake(0, 0, 35, 35);
        }
        
        {
            self.straighenButton.layer.cornerRadius = 3.0;
            self.straighenButton.layer.masksToBounds = YES;
            self.straighenButton.selected = shouldLineFrameShow;
            [self.straighenButton addTarget:self action:@selector(straightenFrameAction:) forControlEvents:UIControlEventTouchUpInside];
            self.straighenButton.frame = CGRectMake(0, 0, 35, 35);
        }
    }
    
    {
        self.lineFrameView.delegate = self;
        
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.lineFrameView.scaleMargin = CGSizeMake(32, 32);
            }
            else
            {
                self.lineFrameView.scaleMargin = CGSizeMake(20, 20);
            }
            
            self.scrollContainerView.imageView.scaleMargin = self.lineFrameView.scaleMargin;
        }

        self.lineFrameView.respectiveView = self.scrollContainerView.imageView;
        self.scrollContainerView.imageView.hideLine = !shouldLineFrameShow;
        self.lineFrameView.hideRuler = !shouldSideRulerShow;

        CGFloat width = sqrtf(powf(self.view.frame.size.width, 2)+powf(self.view.frame.size.height, 2));
        CGFloat height = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?90:55;

        _freeRulerView = [[IQRulerView alloc] initWithFrame:CGRectMake(0, 0, width ,height)];
        [_freeRulerView.panRecognizer addTarget:self action:@selector(rulerPanAction:)];
        _freeRulerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        _freeRulerView.alpha = shouldFreeHandRulerShow?1.0:0.0;
        _freeRulerView.hidden = !shouldFreeHandRulerShow;
        _freeRulerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.view insertSubview:_freeRulerView belowSubview:self.lineFrameView];

        CGFloat halfScreenWidth = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)/2;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            halfScreenWidth = 200;
        }
        
        _freeProtractorView = [[IQProtractorView alloc] initWithFrame:CGRectMake(0, 0,  halfScreenWidth ,halfScreenWidth)];
        [_freeProtractorView.panRecognizer addTarget:self action:@selector(protractorPanAction:)];
        
        _freeProtractorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        _freeProtractorView.alpha = shouldFreeProtractorShow?1.0:0.0;
        _freeProtractorView.hidden = !shouldFreeProtractorShow;
        _freeProtractorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.view insertSubview:_freeProtractorView belowSubview:self.lineFrameView];
    }
    
    {
        self.ratioButton.selected = YES;
        
        NSInteger selectedRatio = [[UIScreen mainScreen] scale];
        [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
        
        _scrollContainerView.imageView.deviceScale = _lineFrameView.deviceScale = _freeRulerView.deviceScale = selectedRatio;
    }
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
    _longPressRecognizer.minimumPressDuration = 1.0;
    _longPressRecognizer.delegate = self;
    _longPressRecognizer.enabled = NO;
    [self.scrollContainerView.scrollView addGestureRecognizer:_longPressRecognizer];
    
    [self openWithLatestScreenshot];
    
    UIBezierPath *bezier = [UIBezierPath rulerShape];
    UIColor *color = [UIColor originalThemeColor];
    
    CBZSplashView *splashView = [CBZSplashView splashViewWithBezierPath:bezier
                                                        backgroundColor:color];
    
    splashView.animationDuration = 1.4;
    
    [self.navigationController.view addSubview:splashView];
    
    self.splashView = splashView;
    
    
    
    //MARK: Hide and show slider
    UITapGestureRecognizer *hideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSlider:)];
       [self.scrollContainerView addGestureRecognizer:hideTapGesture];

       UITapGestureRecognizer *showTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSlider:)];
       [self.freeRulerView addGestureRecognizer:showTapGesture];
       
       UITapGestureRecognizer *showProtractorTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSlider:)];
       [self.freeProtractorView addGestureRecognizer:showProtractorTapGesture];
    
    if ((self.freeRulerView.alpha != 0) || (self.freeProtractorView.alpha)) {
        self.sliderView.alpha = 1;
    } else {
        self.sliderView.alpha = 0;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateTheme];
}

-(void)updateTheme
{
    self.scrollContainerView.showZoomControls = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowZoomOption"];

    UIColor *originalThemeColor = [UIColor originalThemeColor];
    UIColor *backgroundColor = [UIColor themeBackgroundColor];

    self.view.backgroundColor = backgroundColor;

    UIColor *shadeFactorColor = [[UIColor themeColor] colorWithShadeFactor:0.9];
    
    //Free
    {
        self.freeRulerView.rulerColor = self.freeProtractorView.protractorColor = originalThemeColor;
        self.freeRulerView.lineColor = self.freeProtractorView.textColor = shadeFactorColor;
    }
    
    //Line
    {
        self.lineFrameView.rulerColor = shadeFactorColor;
        self.scrollContainerView.imageView.lineColor = self.lineFrameView.lineColor = originalThemeColor;
    }
    
    {
        //sliderView
        self.sliderView.backgroundColor = [UIColor themeColor];
    }
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.navigationController.navigationBar.barTintColor = [UIColor themeColor];
        weakSelf.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
        weakSelf.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];
        weakSelf.navigationController.toolbar.barTintColor = [UIColor themeColor];
        weakSelf.navigationController.toolbar.tintColor = [UIColor themeTextColor];
        weakSelf.navigationController.toolbar.barStyle = ![UIColor isThemeInverted];
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* wait a beat before animating in */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.splashView startAnimation];
    });
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

-(UIImage*)image
{
    return self.scrollContainerView.image;
}

-(void)setImage:(UIImage*)image
{
    if (image)
    {
        self.scrollContainerView.image = image;
        
        _freeRulerView.zoomScale = self.scrollContainerView.zoomScale;
        _lineFrameView.zoomScale = self.scrollContainerView.zoomScale;
        _lineFrameView.startingScalePoint = CGPointZero;
        self.freeProtractorView.transform = CGAffineTransformIdentity;
        [self.freeProtractorView setNeedsLayout];
        self.freeRulerView.transform = CGAffineTransformIdentity;
        
        CGPoint rulerCenterPoint = IQRectGetCenter(self.freeRulerView.bounds);
        rulerCenterInImage = [self.freeRulerView convertPoint:rulerCenterPoint toView:self.scrollContainerView.imageView];
        
        CGPoint protractorCenterPoint = IQRectGetCenter(self.freeProtractorView.bounds);
        protractorCenterInImage = [self.freeProtractorView convertPoint:protractorCenterPoint toView:self.scrollContainerView.imageView];
    }
    else
    {
        self.scrollContainerView.image = nil;
    }

    _longPressRecognizer.enabled = image != nil;
    _editOptionBarButton.enabled = image != nil;
    _sideRulerButton.enabled = image != nil;
    _sideRulerButton.selected = (image != nil && !_lineFrameView.hideRuler);
    _freeHandButton.enabled = image != nil;
    _freeHandButton.selected = (image != nil && _freeRulerView.alpha != 0.0);
    _protractorButton.enabled = image != nil;
    _protractorButton.selected = (image != nil && _freeProtractorView.alpha != 0.0);
    _straighenButton.enabled = image != nil;
    _straighenButton.selected = (image != nil && !_scrollContainerView.imageView.hideLine);
    _optionBarButton.enabled = image != nil;

    _viewNoScreenshotInfo.hidden = image != nil;
    _lineFrameView.hidden = image == nil;
    _freeRulerView.hidden = image == nil;
    _opacitySlider.hidden = image == nil;
    _sliderView.hidden = image == nil;
    _freeProtractorView.hidden = image == nil;
}

// MARK: OPtionAction
- (IBAction)optionAction:(UIBarButtonItem *)sender
{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  __weak typeof(self) weakSelf = self;
  [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"share_photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [Answers logShareWithMethod:@"Share Photo" contentName:@"Share Activity" contentType:@"share" contentId:@"share.photo" customAttributes:nil];
    // Take Screenshot & Crop it
    UIImage *croppedScreenshot = [weakSelf captureCroppedScreenshot];
    if (croppedScreenshot) {
      UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[croppedScreenshot] applicationActivities:nil];
      shareController.excludedActivityTypes = @[
        UIActivityTypeAssignToContact,
        UIActivityTypeAddToReadingList,
        UIActivityTypeOpenInIBooks,
        UIActivityTypePostToTencentWeibo,
        UIActivityTypePostToVimeo,
        UIActivityTypePostToWeibo,
        UIActivityTypePostToFacebook,
        UIActivityTypePostToTwitter,
        UIActivityTypePostToFlickr,
        UIActivityTypePrint
      ];
      shareController.popoverPresentationController.barButtonItem = sender;
      [weakSelf presentViewController:shareController animated:YES completion:nil];
    }
  }]];
  [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"start_help_tour", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [Answers logCustomEventWithName:@"Start Help Tour" customAttributes:nil];
    [weakSelf startHelpTour];
  }]];
  [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
  alertController.popoverPresentationController.barButtonItem = sender;
  [self presentViewController:alertController animated:YES completion:nil];
}

// MARK: Capture Cropped Screenshot
- (UIImage *)captureCroppedScreenshot {
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
  [keyWindow drawViewHierarchyInRect:keyWindow.bounds afterScreenUpdates:YES];
  UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  if (!fullScreenshot) {
    return nil;
  }
  CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
  CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
  CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
  CGFloat bottomInset = keyWindow.safeAreaInsets.bottom; // Notch wale devices ke liye
  CGFloat cropY = statusBarHeight + navBarHeight;
  CGFloat cropHeight = fullScreenshot.size.height - cropY - tabBarHeight - bottomInset;
  CGRect cropRect = CGRectMake(0, cropY * fullScreenshot.scale, fullScreenshot.size.width * fullScreenshot.scale, cropHeight * fullScreenshot.scale);
  // Crop Screenshot
  CGImageRef imageRef = CGImageCreateWithImageInRect(fullScreenshot.CGImage, cropRect);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:fullScreenshot.scale orientation:fullScreenshot.imageOrientation];
  CGImageRelease(imageRef);
  return croppedImage;
}

-(void)startHelpTour
{
    if ([SRDebugHelper isBeingDebugged])
    {
        SROnboardingNavigationController *navController = [[SROnboardingNavigationController alloc] init];
        [self presentViewController:navController animated:YES completion:nil];
        return;
    }
    
    {
        [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        self.scrollContainerView.imageView.hideLine = NO;
        self.straighenButton.selected = YES;
        
        self.lineFrameView.hideRuler = NO;
        self.sideRulerButton.selected = YES;
        
        self.freeHandButton.selected = NO;
        self.freeRulerView.alpha = 0.0;
        
        self.protractorButton.selected = NO;
        self.freeProtractorView.alpha = 0.0;
    }
    
    CGRect rect = IQRectSetCenter(CGRectMake(0, 0, 160, 160), self.view.center);
    
    UIColor *originalThemeColor = [UIColor originalThemeColor];

    MPCoachMark *mark2 = [MPCoachMark markWithAttributes:@{
                                                           @"rect": [NSValue valueWithCGRect:rect],
                                                           @"caption": NSLocalizedString(@"double_tap_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"shape": @(SHAPE_CIRCLE),
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"DoubleTap"]
                                                           }];
    
    MPCoachMark *mark3 = [MPCoachMark markWithAttributes:@{
                                                           @"view": self.ratioButton,
                                                           @"caption": NSLocalizedString(@"device_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsMake(-5, -5, -5, -5)],
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"arrow-top"]
                                                           }];
    
    MPCoachMark *mark4 = [MPCoachMark markWithAttributes:@{
                                                           @"rect": [NSValue valueWithCGRect:rect],
                                                           @"caption": NSLocalizedString(@"long_tap_color_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"shape": @(SHAPE_CIRCLE),
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Press-and-Drag"]
                                                           }];
    
    MPCoachMark *mark5 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, self.lineFrameView.frame.origin.y, 20, self.lineFrameView.frame.size.height)],
                                                           @"caption": NSLocalizedString(@"vertical_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_RIGHT),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Scroll-Vertical"]
                                                           }];
    
    MPCoachMark *mark6 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20)],
                                                           @"caption": NSLocalizedString(@"horizontal_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Scroll-Horizontal"]
                                                           }];
    
    MPCoachMark *mark7 = [MPCoachMark markWithAttributes:@{
                                                           @"view":_lineFrameView,
                                                           @"rect": [NSValue valueWithCGRect:CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20)],
                                                           @"caption": NSLocalizedString(@"long_tap_scale_help", nil),
                                                           @"borderColor":originalThemeColor,
                                                           @"inset":[NSValue valueWithUIEdgeInsets: UIEdgeInsetsZero],
                                                           @"shape": @(SHAPE_SQUARE),
                                                           @"position":@(LABEL_POSITION_BOTTOM),
                                                           @"alignment":@(LABEL_ALIGNMENT_CENTER),
                                                           @"image":[UIImage imageNamed:@"Press"]
                                                           }];
    // Show coach marks
    MPCoachMarkView *coachMark= [MPCoachMarkView startWithCoachMarks:@[mark2,mark3,mark4,mark5,mark6,mark7]];
    coachMark.delegate=self;
}

-(void)coachMarkTimer:(NSTimer*)timer
{
    MPCoachMarkView *coachMarksView = timer.userInfo[@"object"];
    
    switch (coachMarksView.markIndex)
    {
        case 0:
        {
            if (self.scrollContainerView.zoomScale == self.scrollContainerView.minimumZoomScale)
            {
                [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*2 animated:YES];
            }
            else
            {
                [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
            }
        }
            break;
        case 1:
        {
            NSInteger currentRatio = [[[self.ratioButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(1, 1)] integerValue];

            NSInteger selectedRatio = (currentRatio-1)%3+1;
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _scrollContainerView.imageView.deviceScale = _lineFrameView.deviceScale = _freeRulerView.deviceScale = selectedRatio;
            
            if (self.presentedViewController == nil)
            {
                [self.ratioButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }

        }
            break;
        case 2:
        {
            CGPoint point = self.view.center;
            point.x -= self.magnifyingGlass.touchPointOffset.x;
            point.y -= self.magnifyingGlass.touchPointOffset.y;

            CGPoint location = [self.view convertPoint:point toView:self.scrollContainerView.imageView];

            [self showRGBAtLocation:location];
        }
            break;

        case 3:
        {
            if (self.lineFrameView.startingScalePoint.y <= 0)
            {
                for (NSInteger i = 0; i<=200; i = i+3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.y = i;
                    
                    __weak typeof(self) weakSelf = self;

                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        weakSelf.lineFrameView.startingScalePoint = point;
                    }];
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
            else
            {
                for (NSInteger i = 200; i>=-2; i= i-3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.y = i;
                    
                    __weak typeof(self) weakSelf = self;

                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        weakSelf.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
        }
            break;
        case 4:
        {
            if (self.lineFrameView.startingScalePoint.x <= 0)
            {
                for (NSInteger i = 0; i<=200; i = i+3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.x = i;
                    
                    __weak typeof(self) weakSelf = self;

                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        weakSelf.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
            else
            {
                for (NSInteger i = 200; i>=-2; i= i-3)
                {
                    CGPoint point = self.lineFrameView.startingScalePoint;
                    point.x = i;
                    
                    __weak typeof(self) weakSelf = self;

                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        weakSelf.lineFrameView.startingScalePoint = point;
                    }];
                    
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }
        }
            break;
        case 5:
        {
            if (self.presentedViewController == nil)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"set_scale_point_location", nil) preferredStyle:UIAlertControllerStyleActionSheet];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"reset_scale_to_original", nil) style:UIAlertActionStyleDestructive handler:nil]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"mark_as_y_reference", nil) style:UIAlertActionStyleDefault handler:nil]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                
                alertController.popoverPresentationController.sourceView = self.lineFrameView;
                
                CGPoint touchPoint = CGPointMake(CGRectGetMidX(self.lineFrameView.bounds), 10);
                alertController.popoverPresentationController.sourceRect = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
                
                [self presentViewController:alertController animated:YES completion:^{
                }];
            }
            else
            {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
    }
}

-(void)coachMarksView:(MPCoachMarkView *)coachMarksView willMoveFromIndex:(NSUInteger)index
{
    [self.coachMarkTimer invalidate];
    self.coachMarkTimer = nil;
    
    switch (coachMarksView.markIndex)
    {
        case 0:
        {
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
        case 1:
        {
            NSInteger selectedRatio = [[UIScreen mainScreen] scale];
            [self.ratioButton setTitle:[NSString localizedStringWithFormat:@"@%ldx",(long)selectedRatio] forState:UIControlStateNormal];
            _scrollContainerView.imageView.deviceScale = _lineFrameView.deviceScale = _freeRulerView.deviceScale = selectedRatio;
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case 2:
        {
            __weak typeof(self) weakSelf = self;

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf hideRGB];
            }];
        }
            break;
        case 3:
        {
            self.lineFrameView.startingScalePoint = CGPointZero;
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
        case 4:
        {
            self.lineFrameView.startingScalePoint = CGPointZero;
            [self.scrollContainerView zoomToMinimumScaleAnimated:YES];
        }
            break;
            
        case 5:
        {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
    }
}

-(void)coachMarksView:(MPCoachMarkView *)coachMarksView willNavigateToIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
        {
            isLockedOrientation = YES;
        }
            break;
        case 3:
        {
            [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*2 animated:YES];
            
            MPCoachMark *mark = [coachMarksView.coachMarks objectAtIndex:index];
            mark.rect = CGRectMake(0, 0, 20, self.lineFrameView.frame.size.height);
        }
            break;
        case 4:
        {
            [self.scrollContainerView setZoomScale:self.scrollContainerView.minimumZoomScale*3 animated:YES];

            MPCoachMark *mark = [coachMarksView.coachMarks objectAtIndex:index];
            mark.rect = CGRectMake(0, 0, self.lineFrameView.frame.size.width, 20);
        }
            break;
            
        default:
            break;
    }
}

- (void)coachMarksView:(MPCoachMarkView *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    if (index == 1 || index == 2 || index == 5)
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:NO];
    }
    else if (index == 3 || index == 4)
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:YES];
    }
    else
    {
        self.coachMarkTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(coachMarkTimer:) userInfo:@{@"object":coachMarksView} repeats:YES];
    }
    
    [self.coachMarkTimer fire];
}

- (void)coachMarksViewWillCleanup:(MPCoachMarkView *)coachMarksView
{
    [self.coachMarkTimer invalidate];
    self.coachMarkTimer = nil;

    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)coachMarksViewDidCleanup:(MPCoachMarkView *)coachMarksView
{
    isLockedOrientation = NO;
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (IBAction)optionPhotoOptions:(id)sender {
//    [self loadInterstitial];
//    [self showAd];
    __weak typeof(self) weakSelf = self;

    void (^loadWithAuthorizationStatus)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status){
        
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied)
        {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            SRScreenshotCollectionViewController *controller = [weakSelf.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SRScreenshotCollectionViewController class])];
            controller.delegate = weakSelf;
            [controller presentOverViewController:weakSelf.navigationController completion:nil];
        }
    };
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                loadWithAuthorizationStatus(status);
            }];
        }];
    }
    else
    {
        [[AdManager sharedManager] loadInterstitialAd];
        [[AdManager sharedManager] showAd:self];
        loadWithAuthorizationStatus([PHPhotoLibrary authorizationStatus]);
    }
}

-(void)screenshotControllerDidSelectOpenPhotoLibrary:(SRScreenshotCollectionViewController*)controller
{
    __weak typeof(self) weakSelf = self;

    [controller dismissViewControllerCompletion:^{
        if ([SRImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            SRImagePickerController *controller = [[SRImagePickerController alloc] init];
            controller.delegate = weakSelf;
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.modalPresentationStyle = UIModalPresentationPopover;
            controller.popoverPresentationController.barButtonItem = weakSelf.libraryBarButton;
            controller.popoverPresentationController.delegate = self;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                controller.preferredContentSize = CGSizeMake(375, 667);
            }
            else
            {
                controller.preferredContentSize = self.view.bounds.size;
            }

            
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
    }];
}

-(void)screenshotControllerDidSelectOpenCamera:(SRScreenshotCollectionViewController*)controller
{
    __weak typeof(self) weakSelf = self;

    [controller dismissViewControllerCompletion:^{
        if ([SRImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            SRImagePickerController *controller = [[SRImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.delegate = weakSelf;
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
    }];
}

-(void)screenshotController:(SRScreenshotCollectionViewController*)controller didSelectScreenshot:(UIImage*)image
{
    __weak typeof(self) weakSelf = self;

    [controller dismissViewControllerCompletion:^{
        weakSelf.image = image;
    }];
}

-(void)imagePickerController:(SRImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    self.image = image;
    [self.scrollContainerView zoomToMinimumScaleAnimated:YES];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)openWithLatestScreenshot
{
    __weak typeof(self) weakSelf = self;

    void (^loadWithAuthorizationStatus)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status){
        
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied)
        {
            weakSelf.libraryBarButton.enabled = NO;
            [weakSelf.noScreenshotActionButton setImage:[UIImage imageNamed:@"photo_access"] forState:UIControlStateNormal];
            weakSelf.labelNoScreenshotsTitle.text = NSLocalizedString(@"photo_access_denied_title", nil);
            weakSelf.labelNoScreenshotsDiscription.text = NSLocalizedString(@"photo_access_denied_description", nil);
            weakSelf.image = nil;
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            weakSelf.libraryBarButton.enabled = YES;
            [weakSelf.noScreenshotActionButton setImage:[UIImage imageNamed:@"iPhone-sceenshot"] forState:UIControlStateNormal];
            weakSelf.labelNoScreenshotsTitle.text = NSLocalizedString(@"no_screenshots_title", nil);
            weakSelf.labelNoScreenshotsDiscription.text = NSLocalizedString(@"no_screenshots_description", nil);
            
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityView.color = [UIColor lightGrayColor];
            activityView.center = CGPointMake(CGRectGetMidX(weakSelf.view.bounds), CGRectGetMidY(weakSelf.view.bounds));
            [activityView startAnimating];
            [weakSelf.view addSubview:activityView];
            
            [weakSelf getLatestScreenshot:^(UIImage *image) {
                [activityView stopAnimating];
                [activityView removeFromSuperview];
                
                if (weakSelf.isRequestShouldIgnore == NO)
                {
                    weakSelf.image = image;
                    [weakSelf.scrollContainerView zoomToMinimumScaleAnimated:YES];
                }

                weakSelf.isRequestingImage = NO;
                weakSelf.isRequestShouldIgnore = YES;
            }];
        }
    };
    
    self.libraryBarButton.enabled = NO;
    self.isRequestingImage = YES;
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                loadWithAuthorizationStatus(status);
            }];
        }];
    }
    else
    {
        loadWithAuthorizationStatus([PHPhotoLibrary authorizationStatus]);
    }
}

-(void)getLatestScreenshot:(void(^)(UIImage*))completionBlock
{
    [[NSOperationQueue new] addOperationWithBlock:^{

        PHFetchResult <PHAssetCollection *> *albums = nil;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_x_Max)
        {
            albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        }
        else
        {
            albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
        }
        
        PHAssetCollection *screenshotCollection = [albums firstObject];
        
        if (screenshotCollection)
        {
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            fetchOptions.fetchLimit = 1;
            
            PHAsset *asset = [[PHAsset fetchAssetsInAssetCollection:screenshotCollection options:fetchOptions] firstObject];
            
            if (asset)
            {
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];

                PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
                requestOptions.version = PHImageRequestOptionsVersionCurrent;
                requestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
                
                [imageManager requestImageForAsset:asset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:requestOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         
                                         if (completionBlock)
                                         {
                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                 completionBlock(result);
                                             }];
                                         }
                                     }];
            }
            else
            {
                if (completionBlock)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(nil);
                    }];
                }
            }
        }
        else
        {
            if (completionBlock)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil);
                }];
            }
        }
    }];
}

#pragma mark - Ratio

- (IBAction)ratioAction:(UIButton *)sender
{
    NSString *currentTitle = [sender titleForState:UIControlStateNormal];
    NSInteger currentRatio = 0;

    if ([currentTitle containsString:@"px"]) {
        currentRatio = [[currentTitle componentsSeparatedByString:@"px"][0] integerValue];
        
        [self.scrollContainerView.imageView setCurrentUnit: measureUnitPx];
    } else if ([currentTitle containsString:@"cm"]) {
        currentRatio = 38;
        [self.scrollContainerView.imageView setCurrentUnit: measureUnitCm];
    } else if ([currentTitle containsString:@"Inch"]) {
        currentRatio = 96;
        [self.scrollContainerView.imageView setCurrentUnit: measureUnitInches];
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"change_scale_multiplier", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;

    // @1px option
    if (currentRatio != 1)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%dpx",1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Answers logCustomEventWithName:@"Change Scale Multiplier" customAttributes:@{@"value":@"1"}];

            NSInteger selectedRatio = 1;
            [weakSelf.ratioButton setTitle:[NSString localizedStringWithFormat:@"%ldpx",(long)selectedRatio] forState:UIControlStateNormal];
            weakSelf.scrollContainerView.imageView.deviceScale = weakSelf.lineFrameView.deviceScale = weakSelf.freeRulerView.deviceScale = selectedRatio;
        }]];
    }
    
    // @2px option
    if (currentRatio != 2)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%dpx",2] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger selectedRatio = 2;

            [Answers logCustomEventWithName:@"Change Scale Multiplier" customAttributes:@{@"value":@"2"}];

            [weakSelf.ratioButton setTitle:[NSString localizedStringWithFormat:@"%ldpx",(long)selectedRatio] forState:UIControlStateNormal];
            weakSelf.scrollContainerView.imageView.deviceScale = weakSelf.lineFrameView.deviceScale = weakSelf.freeRulerView.deviceScale = selectedRatio;
        }]];
    }
    
    // @3px option
    if (currentRatio != 3)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString localizedStringWithFormat:@"%dpx",3] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Answers logCustomEventWithName:@"Change Scale Multiplier" customAttributes:@{@"value":@"3"}];

            NSInteger selectedRatio = 3;
            [weakSelf.ratioButton setTitle:[NSString localizedStringWithFormat:@"%ldpx",(long)selectedRatio] forState:UIControlStateNormal];
            weakSelf.scrollContainerView.imageView.deviceScale = weakSelf.lineFrameView.deviceScale = weakSelf.freeRulerView.deviceScale = selectedRatio;
        }]];
    }
    
    if (currentRatio != 38)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"1cm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Answers logCustomEventWithName:@"Change Scale Multiplier" customAttributes:@{@"value":@"38"}];

            NSInteger selectedRatio = 38; // 1CM ≈ 38px (96 DPI)
            [weakSelf.ratioButton setTitle:[NSString localizedStringWithFormat:@"1cm",(long)selectedRatio] forState:UIControlStateNormal];
            weakSelf.freeRulerView.deviceScale = selectedRatio;
            weakSelf.lineFrameView.deviceScale = weakSelf.freeRulerView.deviceScale;
            weakSelf.scrollContainerView.imageView.deviceScale = weakSelf.lineFrameView.deviceScale;
        }]];
    }

    if (currentRatio != 96)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"1Inch" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Answers logCustomEventWithName:@"Change Scale Multiplier" customAttributes:@{@"value":@"96"}];

            NSInteger selectedRatio = 96; // 1 Inch ≈ 96 Pixels (96 DPI)

            [weakSelf.ratioButton setTitle:[NSString localizedStringWithFormat:@"1Inch",(long)selectedRatio] forState:UIControlStateNormal];
            weakSelf.scrollContainerView.imageView.deviceScale = weakSelf.lineFrameView.deviceScale = weakSelf.freeRulerView.deviceScale = selectedRatio;
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    alertController.popoverPresentationController.barButtonItem = self.rationBarButon;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Vertical Ruler

-(IBAction)verticalRulerAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.lineFrameView.hideRuler = !weakSelf.lineFrameView.hideRuler;
        [[NSUserDefaults standardUserDefaults] setBool:!weakSelf.lineFrameView.hideRuler forKey:@"SideRulerShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    if (button.selected)
    {
        [[AdManager sharedManager] loadInterstitialAd];
        [[AdManager sharedManager] showAd:self];
    }
}

#pragma mark - Free Ruler

// MARK: SliderButtonAction
- (IBAction)sliderButtonAction:(id)sender {
    
    CGFloat newAlpha = _opacitySlider.value;
    
    if (self.freeRulerView.alpha != 0) {
        self.freeRulerView.alpha = newAlpha;
    }
    
    if (self.freeProtractorView.alpha != 0) {
        self.freeProtractorView.alpha = newAlpha;
    }
}

//MARK: rulerPanAction
-(void)rulerPanAction:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateFailed ||
        recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGPoint centerPoint = IQRectGetCenter(self.freeRulerView.bounds);
        
        rulerCenterInImage = [self.freeRulerView convertPoint:centerPoint toView:self.scrollContainerView.imageView];
    }
}

// MARK: Hide and show slider
- (void)hideSlider:(UITapGestureRecognizer *)gesture {
    self.sliderView.hidden = YES;
}

- (void)showSlider:(UITapGestureRecognizer *)gesture {
    self.sliderView.hidden = NO;
}

-(void)updateRulerPosition
{
//    CGPoint rulerCenterPoint = [self.scrollContainerView.imageView convertPoint:rulerCenterInImage toView:self.freeRulerView];
//    
//    CGAffineTransform transform = self.freeRulerView.transform;
//    transform.tx += rulerCenterPoint.x - self.freeRulerView.bounds.size.width/2;
//    transform.ty += rulerCenterPoint.y - self.freeRulerView.bounds.size.height/2;
//    self.freeRulerView.transform = transform;
}

-(IBAction)freeRulerAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        [[AdManager sharedManager] loadInterstitialAd];
        [[AdManager sharedManager] showAd:self];

        self.freeRulerView.hidden = NO;
        self.sliderView.hidden = NO;
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint centerPoint = IQRectGetCenter(weakSelf.freeRulerView.frame);
        if(button.selected == YES && CGRectContainsPoint(weakSelf.freeRulerView.superview.bounds, centerPoint) == false)
        {
            CGAffineTransform transform = weakSelf.freeRulerView.transform;
            transform.tx = 0;
            transform.ty = 0;
            weakSelf.freeRulerView.transform = transform;
        }
        
        weakSelf.freeRulerView.alpha = button.selected ? 1.0 : 0.0;
        weakSelf.sliderView.alpha = (weakSelf.freeRulerView.alpha == 1.0 || weakSelf.freeProtractorView.alpha == 1.0) ? 1.0 : 0.0;
        
    } completion:^(BOOL finished) {
        if (!button.selected) {
            weakSelf.freeRulerView.hidden = YES;

            if (weakSelf.freeProtractorView.hidden) {
                weakSelf.sliderView.hidden = YES;
            }
        }
    }];
}

-(void)protractorPanAction:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateFailed ||
        recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGPoint centerPoint = IQRectGetCenter(self.freeProtractorView.bounds);

        protractorCenterInImage = [self.freeProtractorView convertPoint:centerPoint toView:self.scrollContainerView.imageView];
    }
}

-(void)updateProtractorPosition
{
    CGPoint protractorCenterPoint = [self.scrollContainerView.imageView convertPoint:protractorCenterInImage toView:self.freeProtractorView];
    
    CGAffineTransform transform = self.freeProtractorView.transform;
    transform.tx += protractorCenterPoint.x - self.freeProtractorView.bounds.size.width/2;
    transform.ty += protractorCenterPoint.y - self.freeProtractorView.bounds.size.height/2;
    self.freeProtractorView.transform = transform;
    [self.freeProtractorView setNeedsLayout];
}

-(IBAction)protractorAction:(UIButton*)button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        [[AdManager sharedManager] loadInterstitialAd];
        [[AdManager sharedManager] showAd:self];

        self.freeProtractorView.hidden = NO;
        self.sliderView.hidden = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint centerPoint = IQRectGetCenter(weakSelf.freeProtractorView.frame);
        if(button.selected == YES && CGRectContainsPoint(weakSelf.freeProtractorView.superview.bounds, centerPoint) == false)
        {
            CGAffineTransform transform = weakSelf.freeProtractorView.transform;
            transform.tx = 0;
            transform.ty = 0;
            weakSelf.freeProtractorView.transform = transform;
        }
        
        weakSelf.freeProtractorView.alpha = button.selected ? 1.0 : 0.0;
        weakSelf.sliderView.alpha = (weakSelf.freeRulerView.alpha == 1.0 || weakSelf.freeProtractorView.alpha == 1.0) ? 1.0 : 0.0;
        
        [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:@"FreeProtractorShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } completion:^(BOOL finished) {
        
        if (!button.selected) {
            weakSelf.freeProtractorView.hidden = YES;

            if (weakSelf.freeRulerView.hidden) {
                weakSelf.sliderView.hidden = YES;
            }
        }
    }];
}

#pragma mark - Straighten

-(IBAction)straightenFrameAction:(UIButton*)button
{
    button.selected = !button.selected;

    if (button.selected)
    {
        [[AdManager sharedManager] loadInterstitialAd];
        [[AdManager sharedManager] showAd:self];
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.scrollContainerView.imageView.hideLine = !weakSelf.scrollContainerView.imageView.hideLine;
        [[NSUserDefaults standardUserDefaults] setBool:!weakSelf.scrollContainerView.imageView.hideLine forKey:@"LineFrameShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma mark - Gesture Recognizers

-(void)showRGBAtLocation:(CGPoint)location
{
    CGPoint originalLocation = location;
    
    location.x = ceilf(location.x);
    location.y = ceilf(location.y);
    
    __weak typeof(self) weakSelf = self;

    if (self.magnifyingGlass.window == nil)
    {
        self.magnifyingGlass.touchPoint = originalLocation;
        self.topColorView.frame = CGRectMake(0, 0, self.navigationController.view.bounds.size.width, self.navigationController.navigationBar.bounds.size.height);
        [self.navigationController.view insertSubview:self.topColorView aboveSubview:self.navigationController.navigationBar];
        [self.view insertSubview:self.magnifyingGlass aboveSubview:self.lineFrameView];
        [self.magnifyingGlass show];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            weakSelf.topColorView.alpha = 1.0;
        } completion:NULL];
    }
    else
    {
        self.topColorView.frame = CGRectMake(0, 0, self.navigationController.view.bounds.size.width, self.navigationController.navigationBar.bounds.size.height);

        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            weakSelf.magnifyingGlass.touchPoint = originalLocation;
        } completion:NULL];
    }
    
    UIImage *image = self.scrollContainerView.image;

    void(^drawColorInfo)(UIColor* color) = ^(UIColor* color){

        weakSelf.magnifyingGlass.color = color;

        NSInteger red = [color red]*255.0;
        NSInteger green = [color green]*255.0;
        NSInteger blue = [color blue]*255.0;
        
        weakSelf.labelRed.text      = [NSString localizedStringWithFormat:@"%ld",(long)red];
        weakSelf.labelGreen.text    = [NSString localizedStringWithFormat:@"%ld",(long)green];
        weakSelf.labelBlue.text     = [NSString localizedStringWithFormat:@"%ld",(long)blue];
        
        if (location.x <= 0 || location.y <= 0 || location.x > image.size.width || location.y > image.size.height)
        {
            weakSelf.labelColorLocation.text = NSLocalizedString(@"X: NA, Y: NA", nil);
        }
        else
        {
            weakSelf.labelColorLocation.text = [NSString localizedStringWithFormat:@"X: %.0f, Y: %.0f",location.x,location.y];
        }
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            if (color)
            {
                weakSelf.topColorView.backgroundColor = color;
            }
            else
            {
                weakSelf.topColorView.backgroundColor = [UIColor originalThemeColor];
            }
            
            if ([color isDarkColor])
            {
                weakSelf.labelRed.textColor             = [UIColor blackColor];
                weakSelf.labelGreen.textColor           = [UIColor blackColor];
                weakSelf.labelBlue.textColor            = [UIColor blackColor];
                weakSelf.labelColorLocation.textColor   = [UIColor blackColor];
                weakSelf.viewColorLabelContainer.backgroundColor =  [UIColor colorWithWhite:1 alpha:0.9];
            }
            else
            {
                weakSelf.labelRed.textColor             = [UIColor whiteColor];
                weakSelf.labelGreen.textColor           = [UIColor whiteColor];
                weakSelf.labelBlue.textColor            = [UIColor whiteColor];
                weakSelf.labelColorLocation.textColor   = [UIColor whiteColor];
                weakSelf.viewColorLabelContainer.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.7];
            }
            
        } completion:NULL];
    };
    
    
    if ([self.loadingColorDataIndicator isAnimating] == NO)
    {
        [image colorAtPoint:location preparingBlock:^{
            [weakSelf.loadingColorDataIndicator startAnimating];
        } completion:^(UIColor *colorAtPoint) {
            
            if ([weakSelf.loadingColorDataIndicator isAnimating])
            {
                [weakSelf.loadingColorDataIndicator stopAnimating];

                [image colorAtPoint:weakSelf.magnifyingGlass.touchPoint preparingBlock:NULL completion:^(UIColor *colorAtPoint) {
                    drawColorInfo(colorAtPoint);
                }];
            }
            else
            {
                drawColorInfo(colorAtPoint);
            }
        }];
    }
    
    if ([self.loadingColorDataIndicator isAnimating])
    {
        self.labelRed.text      = @" ";
        self.labelGreen.text    = @" ";
        self.labelBlue.text     = @" ";
        self.labelColorLocation.text = @" ";
    }
}

-(void)hideRGB
{
    if (self.magnifyingGlass.window)
    {
        __weak typeof(self) weakSelf = self;

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            weakSelf.topColorView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [weakSelf.topColorView removeFromSuperview];
        }];
        [self.magnifyingGlass hide];
    }
}

-(void)longPressRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self.scrollContainerView.imageView];
        
        if(recognizer.state == UIGestureRecognizerStateBegan)
        {
            [Answers logCustomEventWithName:@"Show RGB" customAttributes:nil];
        }

        [self showRGBAtLocation:location];
    }
    else
    {
        [self hideRGB];
    }
}

#pragma mark - Line Frame View Delegates

-(void)lineFrameDidChangeStartingScalePoint:(IQLineFrameView *)lineView
{
    self.scrollContainerView.imageView.startingScalePoint = lineView.startingScalePoint;
}

#pragma mark - ScrollView Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        if (_freeRulerView.hidden == NO && _freeRulerView.alpha != 0.0)
        {
            _freeRulerView.zoomScale = scrollView.zoomScale;
        }
        
        if (_lineFrameView.hidden == NO && _lineFrameView.alpha != 0.0)
        {
            BOOL animated = !(scrollView.isTracking || scrollView.isDecelerating || scrollView.isDragging);
            [_lineFrameView setZoomScale:scrollView.zoomScale animated:animated];
        }
        
        [self updateProtractorPosition];
        [self updateRulerPosition];
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        _freeRulerView.zoomScale = scrollView.zoomScale;
        _lineFrameView.zoomScale = scrollView.zoomScale;
        
        [self updateProtractorPosition];
        [self updateRulerPosition];
    }
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollContainerView.scrollView)
    {
        if (_freeRulerView.hidden == NO && _freeRulerView.alpha != 0.0)
        {
            _freeRulerView.zoomScale = scrollView.zoomScale;
        }
        
        if (_lineFrameView.hidden == NO && _lineFrameView.alpha != 0.0)
        {
            BOOL animated = !(scrollView.isTracking || scrollView.isDecelerating || scrollView.isDragging);

            [_lineFrameView setZoomScale:scrollView.zoomScale animated:animated];
        }

        [self updateProtractorPosition];
        [self updateRulerPosition];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    [self loadInterstitial];
//    [self showAd];
    if ([segue.destinationViewController isKindOfClass:[SREditOptionViewController class]])
    {
        SREditOptionViewController *controller = (SREditOptionViewController*)segue.destinationViewController;
        controller.delegate = self;
        controller.image = self.scrollContainerView.image;
        controller.zoomScale = self.scrollContainerView.zoomScale;
        controller.contentOffset = self.scrollContainerView.contentOffset;
    }
    else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navControler = segue.destinationViewController;
        
        navControler.modalPresentationStyle = UIModalPresentationPopover;
        navControler.popoverPresentationController.barButtonItem = self.settingsMenuBarButton;
        navControler.popoverPresentationController.delegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            navControler.preferredContentSize = CGSizeMake(375, 667);
        }
        else
        {
            CGSize size = self.view.bounds.size;
            navControler.preferredContentSize = size;
        }
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

-(void)controller:(UIViewController*)controller finishWithImage:(UIImage*)image zoomScale:(CGFloat)zoomScale contentOffset:(CGPoint)contentOffset
{
    self.scrollContainerView.image = image;
    self.scrollContainerView.zoomScale = zoomScale;
    self.scrollContainerView.contentOffset = contentOffset;
}

#pragma mark - Orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) weakSelf = self;

    CGAffineTransform rulerTransform = _freeRulerView.transform;
    __block CGAffineTransform protractorTransform = _freeProtractorView.transform;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.freeRulerView.transform = CGAffineTransformIdentity;
        weakSelf.freeProtractorView.transform = CGAffineTransformIdentity;
        [weakSelf.freeProtractorView setNeedsLayout];
    }];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [weakSelf.lineFrameView updateUIAnimated:YES];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [weakSelf.lineFrameView updateUIAnimated:YES];
        
        {
            weakSelf.freeProtractorView.transform = protractorTransform;
            CGPoint protractorCenterPoint = [self.scrollContainerView.imageView convertPoint:protractorCenterInImage toView:self.freeProtractorView];
            
            protractorTransform.tx += protractorCenterPoint.x - self.freeProtractorView.bounds.size.width/2;
            protractorTransform.ty += protractorCenterPoint.y - self.freeProtractorView.bounds.size.height/2;
            self.freeProtractorView.transform = protractorTransform;
            [self.freeProtractorView setNeedsLayout];
        }

        weakSelf.freeRulerView.transform = rulerTransform;
    }];
}

- (BOOL)shouldAutorotate
{
    return isLockedOrientation == NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (isLockedOrientation)
    {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            return UIInterfaceOrientationMaskPortrait;
        }
        else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.interfaceOrientation == UIInterfaceOrientationUnknown)
    {
        return UIInterfaceOrientationPortrait;
    }
    else
    {
        return self.interfaceOrientation;
    }
//    NSLog(@"%d",self.interfaceOrientation);
}

-(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]] == NO)
    {
        return self.presentedViewController.interfaceOrientation;
    }
    else
    {
        return [super interfaceOrientation];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *snapshotView = [_scrollContainerView snapshotViewAfterScreenUpdates:false];
    snapshotView.frame = _scrollContainerView.frame;
    [self.view insertSubview:snapshotView aboveSubview:_scrollContainerView];
    [UIView animateWithDuration:duration animations:^
     {
         snapshotView.alpha = 1.2;
     } completion:^(__unused BOOL finished)
     {
         [snapshotView removeFromSuperview];
     }];
    

    [_scrollContainerView layoutSubviews];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
