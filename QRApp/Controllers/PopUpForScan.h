//
//  PopUpForCameraOrGallery.h
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PopUpForScan;
@protocol PopUpForCameraOrGalleryDelegate
- (void) presentCamera;
@end

@interface PopUpForScan : UIViewController

@property (nonatomic, weak) id <PopUpForCameraOrGalleryDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *qrView;
@property (weak, nonatomic) IBOutlet UIView *barcodeView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;
- (IBAction)actionCancel:(UIButton *)sender;
- (IBAction)actionChooseGallery:(UIButton*)sender;






@end

NS_ASSUME_NONNULL_END
