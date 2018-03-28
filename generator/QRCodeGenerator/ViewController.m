//
//  ViewController.m
//  QRCodeGenerator
//
//  Created by LeeVic on 8/19/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeGenerator.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *image = [QRCodeGenerator createQRImageForString:@"http://www.poketec.com/" size:CGSizeMake(300, 300)];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.center = self.view.center;
    
    [self.view addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
