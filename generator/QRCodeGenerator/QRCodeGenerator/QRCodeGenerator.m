//
//  QRCodeGenerator.m
//  QRCodeGenerator
//
//  Created by LeeVic on 8/19/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "QRCodeGenerator.h"

@implementation QRCodeGenerator

+ (UIImage *)createQRImageForString:(NSString *)string size:(CGSize)size
{
    // 设置滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    // 设置保存滤镜生成图像的CIImage
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *image = [filter valueForKey:@"outputImage"];
    
    // 计算生成图像的大小和方法传入目标大小的比例
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width / CGRectGetWidth(extent), size.height / CGRectGetHeight(extent));
    
    // 生成位图画布
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    // 将bitmapImage绘到画布上
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 生成包含二维码结果的位图
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    // 释放
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

@end
