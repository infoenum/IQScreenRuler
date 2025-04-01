//
//  SRLineView.h
//  Screen Ruler
//
//  Created by IEMacBook02 on 06/11/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

//// Define MeasureUnit enum here
//typedef NS_ENUM(NSInteger, MeasureUnit) {
//    measureUnitPx,      // Pixel
//    measureUnitCm,      // Centimeter
//    measureUnitInches   // Inches
//};


@interface SRLineImageView : UIImageView

//@property (nonatomic, assign) MeasureUnit currentUnit;
//
//- (void)setCurrentUnit:(MeasureUnit)currentUnit;

@property(nonatomic,assign) CGPoint startingScalePoint;
@property(nonatomic,assign) CGSize scaleMargin;

@property(nonatomic,assign) CGFloat deviceScale;

@property(nonatomic,assign) CGFloat zoomScale;

@property(nonatomic, strong) UIColor *lineColor;

@property(nonatomic, assign) BOOL hideLine;

@end


