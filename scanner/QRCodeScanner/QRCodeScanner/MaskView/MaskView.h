//
//  maskView.h
//  test_for_CAShapeLayer
//
//  Created by LeeVic on 8/21/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskView : UIView

/**
 *  绘出制定大小的阴影框并显示动画
 *
 *  @param finalRect 最终需要的扫描框大小
 */
- (void)startScanningWithScanRect:(CGRect)finalRect;

/**
 *  重置MaskView
 */
- (void)reset;

@end
