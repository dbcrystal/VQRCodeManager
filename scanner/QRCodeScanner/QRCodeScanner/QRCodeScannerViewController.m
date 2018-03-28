//
//  QRCodeScannerViewController.m
//  QRCode
//
//  Created by LeeVic on 8/17/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "QRCodeScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MaskView.h"

@interface QRCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) MaskView *maskView;

@end

@implementation QRCodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    // 显示相机图像
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.imageView];
    
    // 扫描框
    self.scanRect = CGRectMake(self.view.frame.size.width/6, (self.view.frame.size.height-self.view.frame.size.width*2/3)/2, self.view.frame.size.width*2/3, self.view.frame.size.width*2/3);
    
    self.captureSession = nil;
    
    [self startReading];
}

/**
 *  初始化captureSession、input流及output流，设置MetadataOutput的有效扫描区域
 */
- (BOOL)startReading
{
    [self addLoadingView];
    
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    // 若无法开启相机
    if (!input) {
        [self dealAVFoundationErrorTypeWithError:error];
        [self popBack];
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self setMetadataOutput:captureMetadataOutput scanRectTo:self.scanRect];
    [self.captureSession addOutput:captureMetadataOutput];
    
    // 为captureMetadataOutput创建新的线程
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 添加摄像头图像显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer setFrame:self.imageView.layer.bounds];
    [self.imageView.layer addSublayer:self.previewLayer];
    
    // 开始捕获图像
    [self.captureSession startRunning];

    // 停止LoadingView
    [self removeLoadingView];
    
    // 添加遮黑窗体
    if (!self.maskView) {
        self.maskView = [[MaskView alloc] initWithFrame:self.view.frame];
    }
    [self.maskView startScanningWithScanRect:self.scanRect];
    [self.view addSubview:self.maskView];
    
    return YES;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReadingWithResult:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

/**
 *  将captureOutput获取的二维码信息通过delegate进行返回
 *
 *  @param result 二维码信息
 */
-(void)stopReadingWithResult:(NSString *)result
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    if ([self.delegate respondsToSelector:@selector(qrCodeScannerDidCaptureQRCodeWithContent:)]) {
        [self.delegate qrCodeScannerDidCaptureQRCodeWithContent:result];
    }
    
    [self popBack];
}

/**
 *  当startReading方法未成功开启摄像头，向delegate返回错误提示
 *
 *  @param error AVCaptureDeviceInput返回失败信息
 */
- (void)dealAVFoundationErrorTypeWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(qrCodeScannerDidRunIntoError:)]) {
        [self.delegate qrCodeScannerDidRunIntoError:error];
    }
    [self popBack];
}


/**
 *  弹出QRCodeScannerViewController
 */
- (void)popBack
{
    [self reset];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  为MetadataOutput设置有效扫描区域
 *
 *  @param captureMetadataOutput 需要设置扫描区域的MetadataOutput
 *  @param rect                  有效区域位置及大小
 */
- (void)setMetadataOutput:(AVCaptureMetadataOutput *)captureMetadataOutput scanRectTo:(CGRect)rect
{
    CGSize captureOutputSize = self.view.frame.size;
    CGRect cropRect = rect;
    CGFloat rectScale = captureOutputSize.height/captureOutputSize.width;
    CGFloat captureOutputScale = 1920.f/1080.f;
    // 修复因1080p图像输出导致的偏差
    if (rectScale < captureOutputScale) {
        CGFloat fixHeight = cropRect.size.width * captureOutputScale;
        CGFloat fixPadding = (fixHeight - captureOutputSize.height)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                          cropRect.origin.x/captureOutputSize.width,
                                                          cropRect.size.height/fixHeight,
                                                          cropRect.size.width/captureOutputSize.width);
    } else {
        CGFloat fixWidth = cropRect.size.height / captureOutputScale;
        CGFloat fixPadding = (fixWidth - captureOutputSize.width)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/captureOutputSize.height,
                                                          (cropRect.origin.x + fixPadding)/fixWidth,
                                                          cropRect.size.height/captureOutputSize.height,
                                                          cropRect.size.width/fixWidth);
    }
}

/**
 *  添加LoadingView
 */
- (void)addLoadingView
{
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.7f;
    [self.view addSubview:self.loadingView];
    
    // 添加 activity indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center = self.view.center;
    [self.loadingView addSubview:self.indicator];
    [self.indicator startAnimating];
    
    // 添加 loading label
    UILabel *lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    lblLoading.center = CGPointMake(self.view.center.x, self.view.center.y+40);
    lblLoading.text = @"Loading...";
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:@"Helvetica" size:14];
    lblLoading.backgroundColor = [UIColor clearColor];
    [self.loadingView addSubview:lblLoading];
}

/**
 *  去除LoadingView
 */
- (void)removeLoadingView
{
    if (self.indicator && [self.indicator isAnimating]) {
        [self.indicator stopAnimating];
    }
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
}

/**
 *  重置
 */
- (void)reset
{
    [self.maskView reset];
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

@end
