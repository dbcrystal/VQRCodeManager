//
//  QRCodeGenerator.h
//  QRCodeGenerator
//
//  Created by LeeVic on 8/19/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeGenerator : UIView

/**
 *  按照传入尺寸大小绘制固定尺寸的二维码并返回
 *
 *  @param size 二维码尺寸
 */
+ (UIImage *)createQRImageForString:(NSString *)string size:(CGSize)size;

@end
