//
//  UIImage+Utility.h
//  ZizaiBeaconMgr
//
//  Created by YANG HONGBO on 2014-4-1.
//  Copyright (c) 2014年 Nutspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)
- (UIImage *)imageInSize:(CGSize)maxSize screenScale:(CGFloat)scale;
- (UIImage *)imageInRect:(CGRect)rect imageScale:(CGFloat)imageScale screenScale:(CGFloat)screenScale;
@end
