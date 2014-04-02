//
//  UIImage+Utility.m
//  ZizaiBeaconMgr
//
//  Created by YANG HONGBO on 2014-4-1.
//  Copyright (c) 2014年 Nutspace. All rights reserved.
//

#import "UIImage+Utility.h"

inline CGSize scaleSizeLimitWidth(CGSize originalSize, CGSize limitSize);
inline CGSize scaleSizeLimitHeight(CGSize originalSize, CGSize limitSize);

CGSize scaleSizeLimitWidth(CGSize originalSize, CGSize limitSize)
{
    CGSize newSize;
    newSize.width = limitSize.width;
    newSize.height = originalSize.height * limitSize.width / originalSize.width;
    return newSize;
}

CGSize scaleSizeLimitHeight(CGSize originalSize, CGSize limitSize)
{
    CGSize newSize;
    newSize.height = limitSize.height;
    newSize.width = originalSize.width * limitSize.height / originalSize.height;
    return newSize;
}

@implementation UIImage (Utility)

- (UIImage *)imageInSize:(CGSize)maxSize screenScale:(CGFloat)scale
{
    CGFloat screenScale = scale;
    if (screenScale < 0.9f) {
        screenScale = [[UIScreen mainScreen] scale];
    }
    // 都转换为像素计算
    CGSize limitSize;
    limitSize.width = maxSize.width * screenScale;
    limitSize.height = maxSize.height * screenScale;
    
    CGSize selfSize;
    selfSize.width = self.size.width * self.scale;
    selfSize.height = self.size.height * self.scale;
    
    if (selfSize.height <= limitSize.width
        && selfSize.width <= limitSize.height) {
        return self; // 应该考虑 ARC 与 Non-ARC
    }
    
    CGRect imageRect = CGRectZero;
    if (selfSize.width > selfSize.height) { // 先对最大边限制
        imageRect.size = scaleSizeLimitWidth(selfSize, limitSize);
    }
    else {
        imageRect.size = scaleSizeLimitHeight(selfSize, limitSize);
    }
    
    // 如果按比例缩小之后，仍然有一边过大，则按最大边继续缩小
    if (imageRect.size.width > limitSize.width) {
        imageRect.size = scaleSizeLimitWidth(selfSize, limitSize);
    }
    
    if (imageRect.size.height > limitSize.height) {
        imageRect.size = scaleSizeLimitHeight(selfSize, limitSize);
    }
    
    screenScale = 1.0f / [UIScreen mainScreen].scale;
    imageRect.size.width *= screenScale;
    imageRect.size.height *= screenScale;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES, [UIScreen mainScreen].scale);
    [self drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// screenScale 参数用于确定 rect 参数用的是什么比例
- (UIImage *)imageInRect:(CGRect)rect imageScale:(CGFloat)imageScale screenScale:(CGFloat)scale
{
    CGFloat screenScale = scale;
    if (screenScale < 0.9f) {
        screenScale = [[UIScreen mainScreen] scale];
    }
    //统一 scale
    CGFloat conversionScale = screenScale / self.scale;
    CGSize selfSize;
    selfSize.width = self.size.width * conversionScale;
    selfSize.height = self.size.height * conversionScale;
    
    CGRect cropRect = CGRectZero;
    cropRect.origin.x = rect.origin.x * imageScale;
    cropRect.origin.y = rect.origin.y * imageScale;
    cropRect.size.width = rect.size.width * imageScale;
    cropRect.size.height = rect.size.height * imageScale;
    
    //-[UIImage size]已经经过imageOrientation调整过的
    // 并由scale调整了logical size
    CGRect canvasRect = CGRectZero;
    canvasRect.size.width = selfSize.width * imageScale;
    canvasRect.size.height = selfSize.height * imageScale;
    CGRect imageRect = canvasRect;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            imageRect.size.width = canvasRect.size.height;
            imageRect.size.height = canvasRect.size.width;
            imageRect.origin.y = - cropRect.origin.x;
            imageRect.origin.x = - cropRect.origin.y;
            break;
        default:
            imageRect.origin.x = - cropRect.origin.x;
            imageRect.origin.y = - cropRect.origin.y;
            break;
    }

    UIGraphicsBeginImageContextWithOptions(cropRect.size, YES, screenScale);
#if 0
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //翻转坐标系，修正UIKit与CoreGraphics的坐标不对应的问题
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextTranslateCTM(ctx, 0.0f, -canvasRect.size.height);
    
    switch (self.imageOrientation) { //upper-left corner coordination
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            CGContextRotateCTM(ctx, -M_PI);
            CGContextTranslateCTM(ctx, -imageRect.size.width, -imageRect.size.height);
            break;
            //Portraits Upside down
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            CGContextRotateCTM(ctx, M_PI_2);
            CGContextTranslateCTM(ctx, 0, -imageRect.size.height);
            break;
            //Portraits
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextRotateCTM(ctx, -M_PI_2);
            CGContextTranslateCTM(ctx, -imageRect.size.width, 0);
            break;
        case UIImageOrientationUp:
        default:
            break;
    }
    
    switch (self.imageOrientation) { // 还未测试过是否正确
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            CGContextScaleCTM(ctx, -1.0f, 1.0f);
            CGContextTranslateCTM(ctx, imageRect.size.width, 0);
            break;
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeftMirrored:
            CGContextScaleCTM(ctx, 1.0f, -1.0f);
            CGContextTranslateCTM(ctx, 0, imageRect.size.width);
            break;
            
        default:
            break;
    }
    
    CGContextDrawImage(ctx, imageRect, self.CGImage); //或者使用 [UIImage drawInRect:] 减少矩阵变换的工作量
#else
    canvasRect.origin = imageRect.origin;
    [self drawInRect:canvasRect];
#endif
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
