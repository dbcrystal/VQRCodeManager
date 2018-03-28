//
//  ViewController.m
//  QRCodeScanner
//
//  Created by LeeVic on 8/24/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeScannerViewController.h"

@interface ViewController () <QRCodeScannerDelegate>

@property (nonatomic, strong) UIImageView *backgroudImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *lable;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, assign) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrCodePreviewLayer;

@end

@implementation ViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backgroudImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.backgroudImageView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, (self.view.frame.size.height-300)/2, 300, 300)];
    
    self.lable = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, self.view.frame.size.width-40, 40)];
    self.lable.text = @"Tap scan to START!";
    self.lable.numberOfLines = 0;
    self.lable.textColor = [UIColor blackColor];
    [self.view addSubview:self.lable];
    
    UIButton *buttonScan = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.lable.frame) + 100.f, self.view.frame.size.width-40, 40)];
    buttonScan.backgroundColor = [UIColor blueColor];
    [buttonScan setTitle:@"START SCAN"
                forState:UIControlStateNormal];
    [buttonScan addTarget:self
                   action:@selector(scan)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonScan];
}

- (void)scan
{
    QRCodeScannerViewController *qrCodeScannerViewController = [[QRCodeScannerViewController alloc] init];
    [self.navigationController pushViewController:qrCodeScannerViewController animated:YES];
    
    qrCodeScannerViewController.delegate = self;
}

#pragma mark - QRCodeScannerDelegate
- (void)qrCodeScannerDidCaptureQRCodeWithContent:(NSString *)content
{
    self.lable.text = content;
    [self.lable sizeToFit];
}

- (void)qrCodeScannerDidRunIntoError:(NSError *)error
{
    UIAlertView *alert;
    if ([error.domain isEqual:@"AVFoundationErrorDomain"] && error.code == -11814) {
        alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机"
                                           message:@"当前设备不支持后置摄像头，请更换设备重试"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    } else if ([error.domain isEqual:@"AVFoundationErrorDomain"] && error.code == -11852) {
        alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机"
                                           message:@"请在iPhone的“设置－隐私－相机”中允许访问"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    }
    [alert show];
}

@end
