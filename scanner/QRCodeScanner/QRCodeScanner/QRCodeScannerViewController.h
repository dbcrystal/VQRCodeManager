//
//  QRCodeScannerViewController.h
//  QRCode
//
//  Created by LeeVic on 8/17/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRCodeScannerDelegate <NSObject>

/** Scan action succeed with result */
- (void)qrCodeScannerDidCaptureQRCodeWithContent:(NSString *)content;

/** Scan action failed with error */
- (void)qrCodeScannerDidRunIntoError:(NSError *)error;

@end

@interface QRCodeScannerViewController : UIViewController

@property (nonatomic, weak) id<QRCodeScannerDelegate> delegate;

- (void)reset;

@end
