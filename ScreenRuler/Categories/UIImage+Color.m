//
//  UIImage+Color.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "UIImage+Color.h"

#import <objc/runtime.h>

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    if (color)
    {
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContextWithOptions(rect.size, CGColorGetAlpha(color.CGColor) == 1.0?YES:NO, [[UIScreen mainScreen] scale]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    else
    {
        return nil;
    }
}

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);

    BOOL hasAlpha = (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);

    UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

static char kPixelData;

-(void)dealloc
{
    CFDataRef pixelData = (__bridge CFDataRef)(objc_getAssociatedObject(self, &kPixelData));

    if (pixelData)
    {
        CFRelease(pixelData);
    }
}

+(UIImage *)createMultiColorImageForAlphaInfo:(CGImageAlphaInfo)alphaInfo {

    // Image size
    CGFloat width = 200;
    CGFloat height = 200;

    // Create a color space (Device RGB)
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a CGContext with the selected alphaInfo
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8, // Bits per component
                                                 4 * width, // Bytes per row
                                                 colorSpace,
                                                 alphaInfo);
    if (context == NULL) {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }

    // Create a gradient with multiple colors (Red, Green, Blue, Yellow)
    NSArray *colors = @[
        (id)[UIColor redColor].CGColor,
        (id)[UIColor greenColor].CGColor,
        (id)[UIColor blueColor].CGColor,
        (id)[UIColor yellowColor].CGColor
    ];
    CGFloat locations[] = { 0.0, 0.33, 0.66, 1.0 };

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);

    // Draw the gradient
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(0, 0), CGPointMake(width, height),
                                0);  // Draws from top-left to bottom-right

    // Create CGImage from the context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);

    // Clean up
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);

    // Return UIImage
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return image;
}

-(void)colorAtPoint:(CGPoint)point preparingBlock:(void (^)(void))preparingBlock completion:(void (^)(UIColor*))colorCompletion
{
    if (point.x <= 0 || point.y <= 0 || point.x > self.size.width || point.y > self.size.height)
    {
        if (colorCompletion)
        {
            colorCompletion(nil);
        }
    }
    //Method1 but having a huge performance hit with CGDataProviderCopyData method
    else
    {
        __weak typeof(self) weakSelf = self;

        void(^getColorBlock)(const UInt8* data) = ^(const UInt8* data){
            CGImageRef imageRef = weakSelf.CGImage;
            int bytesPerComponent = (int)CGImageGetBitsPerComponent(imageRef)/8;
            size_t bytesPerPixel = CGImageGetBitsPerPixel(imageRef)/8;
            CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);

            NSInteger columnIndex = ceilf(point.x)-1;
            NSInteger rowIndex = ceilf(point.y)-1;
            
            float width = weakSelf.size.width;
            int pixelInfo = ((width * rowIndex) + columnIndex) * bytesPerPixel;

            int redIndex = -1;
            int greenIndex = -1;
            int blueIndex = -1;
            int alphaIndex = -1;

            int indexShift = bytesPerComponent - 1;
            switch (alphaInfo)
            {
                case kCGImageAlphaNone:
                case kCGImageAlphaNoneSkipLast:
                    redIndex = 0 * bytesPerComponent + indexShift;
                    greenIndex = 1 * bytesPerComponent + indexShift;
                    blueIndex = 2 * bytesPerComponent + indexShift;
                    break;
                case kCGImageAlphaPremultipliedLast:
                case kCGImageAlphaLast:
                    redIndex = 0 * bytesPerComponent + indexShift;
                    greenIndex = 1 * bytesPerComponent + indexShift;
                    blueIndex = 2 * bytesPerComponent + indexShift;
                    alphaIndex = 3 * bytesPerComponent + indexShift;
                    break;
                case kCGImageAlphaPremultipliedFirst:
                case kCGImageAlphaFirst:
                    alphaIndex = 0 * bytesPerComponent + indexShift;
                    redIndex = 1 * bytesPerComponent + indexShift;
                    greenIndex = 2 * bytesPerComponent + indexShift;
                    blueIndex = 3 * bytesPerComponent + indexShift;
                    break;
                case kCGImageAlphaNoneSkipFirst:
                    redIndex = 1 * bytesPerComponent + indexShift;
                    greenIndex = 2 * bytesPerComponent + indexShift;
                    blueIndex = 3 * bytesPerComponent + indexShift;
                    break;
                case kCGImageAlphaOnly:
                    alphaIndex = 0 * bytesPerComponent + indexShift;
                    break;
                default:
                    break;
            }

            CGFloat red = 0;
            CGFloat green = 0;
            CGFloat blue = 0;
            CGFloat alpha = 1.0;

            if (redIndex >= 0) {
                int color = data[pixelInfo + redIndex];
                CGFloat floatValue = color / 255.0;
                red = floatValue;
            }
            if (greenIndex >= 0) {
                int color = data[pixelInfo + greenIndex];
                CGFloat floatValue = color / 255.0;
                green = floatValue;
            }
            if (blueIndex >= 0) {
                int color = data[pixelInfo + blueIndex];
                CGFloat floatValue = color / 255.0;
                blue = floatValue;
            }
            if (alphaIndex >= 0) {
                int color = data[pixelInfo + alphaIndex];
                CGFloat floatValue = color / 255.0;
                alpha = floatValue;
            }

            // RGBA values range from 0 to 255
            UIColor *color = [UIColor colorWithRed:red
                                   green:green
                                    blue:blue
                                   alpha:alpha];
            
            if (colorCompletion)
            {
                colorCompletion(color);
            }
        };
        
        CFDataRef pixelData = (__bridge CFDataRef)(objc_getAssociatedObject(self, &kPixelData));

        if (pixelData)
        {
            getColorBlock(CFDataGetBytePtr(pixelData));
        }
        else
        {
            if (preparingBlock)
            {
                preparingBlock();
            }
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.qualityOfService = NSQualityOfServiceUserInteractive;
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                CGDataProviderRef provider = CGImageGetDataProvider(weakSelf.CGImage);
                CFDataRef pixelData = CGDataProviderCopyData(provider);
                
                objc_setAssociatedObject(weakSelf, &kPixelData, (__bridge NSData*)(pixelData), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    getColorBlock(CFDataGetBytePtr(pixelData));
                }];
            }];
            
            operation.qualityOfService = NSQualityOfServiceUserInteractive;
            [queue addOperation:operation];
        }
    }
}

@end
