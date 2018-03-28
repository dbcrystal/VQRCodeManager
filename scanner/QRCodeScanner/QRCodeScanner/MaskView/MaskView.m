//
//  maskView.m
//  test_for_CAShapeLayer
//
//  Created by LeeVic on 8/21/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "MaskView.h"

#define MASK_VIEW_SCAN_VIEW_GROW_SPEED 10
#define MASK_VIEW_CORNER_BORDER_LENGTH 15

#define MASK_VIEW_SCANNER_LINE_HEIGHT 53
#define MASK_VIEW_SCANNER_LINE_SCAN_INTERVAL 3.f

@interface MaskView ()

@property (nonatomic, strong) UIView *rectView;

@property (nonatomic, assign) CGRect finalRect;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIImageView *imgViewScannerLine;
@property (nonatomic, strong) NSTimer *scannerLineTimer;

@property (nonatomic, strong) UILabel *lblNotice;

@end

@implementation MaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self setNeedsDisplay];
    self.backgroundColor = [UIColor clearColor];
    
    // init
    self.rectView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x-20, self.center.y-20, 40, 40)];
    self.rectView.backgroundColor = [UIColor clearColor];
    self.rectView.clipsToBounds = YES;
    [self addSubview:self.rectView];
    
    // init scanner line
    self.imgViewScannerLine = [[UIImageView alloc] init];
    self.imgViewScannerLine.image = [UIImage imageNamed:@"QRCode_Scanner_Line.png"];
    self.imgViewScannerLine.backgroundColor = [UIColor clearColor];
    self.imgViewScannerLine.hidden = YES;
    [self.rectView addSubview:self.imgViewScannerLine];
    
    // init notice
    self.lblNotice = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    self.lblNotice.backgroundColor = [UIColor clearColor];
    self.lblNotice.text = @"Align QR code within frame to scan";
    self.lblNotice.textColor = [UIColor whiteColor];
    self.lblNotice.textAlignment = NSTextAlignmentCenter;
    self.lblNotice.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.lblNotice.hidden = YES;
    [self addSubview:self.lblNotice];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - draw mask
- (void)drawRect:(CGRect)rectView
{
    [super drawRect:rectView];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Coordinates are:
    //
    // A-------------B     A(0,0), B(screenWidth,0), C(screenWidth,screenHeight), D(0,screenHeight)
    // |  E-------F  |     E(50,50), F(150,50), G(150,190)
    // |  |       |  |     H(50,190), I(100,190)
    // |  |       |  |     J(screenWidth/2,screenHeight)
    // |  |       |  |
    // |  H---I---G  |
    // |      |      |
    // D------J------C
    
    // draw mask view
    CGPoint outerTopLeft = CGPointMake(0, 0);
    CGPoint outerTopRight = CGPointMake(self.frame.size.width, 0);
    CGPoint outerBottomLeft = CGPointMake(0, self.frame.size.height);
    CGPoint outerBottomMiddle = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    CGPoint outerBottomRight = CGPointMake(self.frame.size.width, self.frame.size.height);
    
    CGPoint innerTopLeft = CGPointMake(self.rectView.frame.origin.x, self.rectView.frame.origin.y);
    CGPoint innerTopRight = CGPointMake(self.rectView.frame.origin.x+self.rectView.frame.size.width, self.rectView.frame.origin.y);
    CGPoint innerBottomLeft = CGPointMake(self.rectView.frame.origin.x, self.rectView.frame.origin.y+self.rectView.frame.size.height);
    CGPoint innerBottomMiddle = CGPointMake(self.rectView.frame.origin.x+self.rectView.frame.size.width/2, self.rectView.frame.origin.y+self.rectView.frame.size.height);
    CGPoint innerBottomRight = CGPointMake(self.rectView.frame.origin.x+self.rectView.frame.size.width, self.rectView.frame.origin.y+self.rectView.frame.size.height);

    CGContextMoveToPoint(context, outerTopLeft.x, outerTopLeft.y);
    CGContextAddLineToPoint(context, outerTopRight.x, outerTopRight.y);
    CGContextAddLineToPoint(context, outerBottomRight.x, outerBottomRight.y);
    CGContextAddLineToPoint(context, outerBottomMiddle.x, outerBottomMiddle.y);
    CGContextAddLineToPoint(context, innerBottomMiddle.x, innerBottomMiddle.y);
    CGContextAddLineToPoint(context, innerBottomRight.x, innerBottomRight.y);
    CGContextAddLineToPoint(context, innerTopRight.x, innerTopRight.y);
    CGContextAddLineToPoint(context, innerTopLeft.x, innerTopLeft.y);
    CGContextAddLineToPoint(context, innerBottomLeft.x, innerBottomLeft.y);
    CGContextAddLineToPoint(context, innerBottomMiddle.x, innerBottomMiddle.y);
    CGContextAddLineToPoint(context, outerBottomMiddle.x, outerBottomMiddle.y);
    CGContextAddLineToPoint(context, outerBottomLeft.x, outerBottomLeft.y);
    CGContextAddLineToPoint(context, outerTopLeft.x, outerTopLeft.y);
    CGContextSetRGBFillColor(context, 0, 0, 0, .5f);
    CGContextFillPath(context);
    
    // draw inner rect border
    [[UIColor whiteColor] set];
    CGContextMoveToPoint(context, innerTopLeft.x, innerTopLeft.y);
    CGContextAddLineToPoint(context, innerTopRight.x, innerTopRight.y);
    CGContextAddLineToPoint(context, innerBottomRight.x, innerBottomRight.y);
    CGContextAddLineToPoint(context, innerBottomLeft.x, innerBottomLeft.y);
    CGContextAddLineToPoint(context, innerTopLeft.x, innerTopLeft.y);
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokePath(context);
    
    // draw inner rect border
    [[UIColor colorWithRed:1.f/255.f green:205.f/255.f blue:249.f/255.f alpha:1.f] set];
    CGContextMoveToPoint(context, innerTopLeft.x+0.5f, innerTopLeft.y+MASK_VIEW_CORNER_BORDER_LENGTH);
    CGContextAddLineToPoint(context, innerTopLeft.x+0.5f, innerTopLeft.y+0.5f);
    CGContextAddLineToPoint(context, innerTopLeft.x+MASK_VIEW_CORNER_BORDER_LENGTH+0.5f, innerTopLeft.y+0.5f);
    CGContextSetLineWidth(context, 2.0f);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, innerTopRight.x-0.5f, innerTopRight.y+MASK_VIEW_CORNER_BORDER_LENGTH);
    CGContextAddLineToPoint(context, innerTopRight.x-0.5f, innerTopRight.y+0.5f);
    CGContextAddLineToPoint(context, innerTopRight.x-MASK_VIEW_CORNER_BORDER_LENGTH+0.5f, innerTopRight.y+0.5f);
    CGContextSetLineWidth(context, 2.0f);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, innerBottomLeft.x+0.5f, innerBottomLeft.y-MASK_VIEW_CORNER_BORDER_LENGTH);
    CGContextAddLineToPoint(context, innerBottomLeft.x+0.5f, innerBottomLeft.y-0.5f);
    CGContextAddLineToPoint(context, innerBottomLeft.x+MASK_VIEW_CORNER_BORDER_LENGTH+0.5f, innerBottomLeft.y-0.5f);
    CGContextSetLineWidth(context, 2.0f);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, innerBottomRight.x-0.5f, innerBottomRight.y-MASK_VIEW_CORNER_BORDER_LENGTH);
    CGContextAddLineToPoint(context, innerBottomRight.x-0.5f, innerBottomRight.y-0.5f);
    CGContextAddLineToPoint(context, innerBottomRight.x-MASK_VIEW_CORNER_BORDER_LENGTH-0.5f, innerBottomRight.y-0.5f);
    CGContextSetLineWidth(context, 2.0f);
    CGContextStrokePath(context);
}

#pragma mark - animation
/**
 *  设置并开始扫描框非遮黑部分扩大的动画
 *
 *  @param finalRect 扫描框非遮黑部分最终位置及尺寸
 */
- (void)startScanningWithScanRect:(CGRect)finalRect
{
    // add application did enter background&foreground notify
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    // setup rectView final rect
    self.finalRect = finalRect;
    
    // setup display link
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(redrawMaskBorder)];
    self.displayLink.frameInterval = 1;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
}

/**
 *  显示扫描页半遮黑效果
 */
- (void)redrawMaskBorder
{
    CGRect newRect = CGRectMake(self.rectView.frame.origin.x-MASK_VIEW_SCAN_VIEW_GROW_SPEED, self.rectView.frame.origin.y-MASK_VIEW_SCAN_VIEW_GROW_SPEED, self.rectView.frame.size.width+MASK_VIEW_SCAN_VIEW_GROW_SPEED*2, self.rectView.frame.size.height+MASK_VIEW_SCAN_VIEW_GROW_SPEED*2);
    
    if (newRect.size.width < self.finalRect.size.width) {               // if new rect is still not reach final rect
        self.rectView.frame = newRect;
        [self setNeedsDisplay];
    } else {                                                            // reached final rect
        // adjust rect view to the final rect, stop display link
        self.rectView.frame = self.finalRect;
        [self setNeedsDisplay];
        [self stopDisplayLink];
        
        [self maskBorderAnimationDidFinished];
    }
}

/**
 *  当扫描页遮黑框动画完成后，初始化提示用label和扫描线，并启动扫描线动画
 */
- (void)maskBorderAnimationDidFinished
{
    self.lblNotice.center = CGPointMake(self.center.x, self.center.y+self.finalRect.size.height/2+20);
    self.lblNotice.hidden = NO;
    
    // start scanner line animarion
    [self setupScannerLineAnimationTimer];
    [self scannerLineAnimationStart];
}

/**
 *  停止 display link
 */
- (void)stopDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

/**
 *  初始化扫描线动画重复计时
 */
- (void)setupScannerLineAnimationTimer
{
    if (self.scannerLineTimer && [self.scannerLineTimer isValid]) {
        [self.scannerLineTimer invalidate];
        self.scannerLineTimer = nil;
    }
    
    self.scannerLineTimer = [NSTimer scheduledTimerWithTimeInterval:MASK_VIEW_SCANNER_LINE_SCAN_INTERVAL
                                                             target:self
                                                           selector:@selector(scannerLineAnimationStart)
                                                           userInfo:nil
                                                            repeats:YES];
}

/**
 *  停止扫描线动画重复计时
 */
- (void)stopScannerLineAnimationTimer
{
    if (self.scannerLineTimer && [self.scannerLineTimer isValid]) {
        [self.scannerLineTimer invalidate];
        self.scannerLineTimer = nil;
    }
}

/**
 *  扫描线从上到下移动的扫描过程
 */
- (void)scannerLineAnimationStart
{
    [self setScannerLineToInitPositionWithHidden:NO];
    [UIView animateWithDuration:MASK_VIEW_SCANNER_LINE_SCAN_INTERVAL
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.imgViewScannerLine.frame = CGRectMake(0, self.rectView.frame.size.height+MASK_VIEW_SCANNER_LINE_HEIGHT-40, self.rectView.frame.size.width, MASK_VIEW_SCANNER_LINE_HEIGHT);
                     } completion:^(BOOL finished) {
                     }];
}

/**
 *  将扫描线重置回初始位置
 *
 *  @param scannerLineHidden 设置scannerLine的hidden值
 */
- (void)setScannerLineToInitPositionWithHidden:(BOOL)scannerLineHidden
{
    self.imgViewScannerLine.frame = CGRectMake(0, -MASK_VIEW_SCANNER_LINE_HEIGHT, self.finalRect.size.width, MASK_VIEW_SCANNER_LINE_HEIGHT);
    self.imgViewScannerLine.hidden = scannerLineHidden;
}

/**
 *  重置扫描线位置
 *
 *  停止扫描线动画计时器
 *
 *  移除notify
 */
- (void)reset
{
    [self setScannerLineToInitPositionWithHidden:YES];
    [self stopScannerLineAnimationTimer];
    self.lblNotice.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - UIApplicationDidEnterBackgroundNotification
- (void)applicationEnterBackground
{
    [self setScannerLineToInitPositionWithHidden:YES];
    [self stopScannerLineAnimationTimer];
}

#pragma  mark - UIApplicationWillEnterForegroundNotification
- (void)applicationEnterForeground
{
    [self setupScannerLineAnimationTimer];
    [self scannerLineAnimationStart];
}

@end
