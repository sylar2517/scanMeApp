//
//  PopUpForCameraOrGallery.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "PopUpForScan.h"
#import "GalleryViewController.h"
#import "QRViewController.h"
#import "HistoryScanTVController.h"

@interface PopUpForScan () <UINavigationControllerDelegate ,UIImagePickerControllerDelegate, GalleryViewControllerDelegate>

@property(strong, nonatomic)UIImagePickerController* imagePickerController;
@property(strong, nonatomic)UIImage* selectedImage;
@property(assign, nonatomic)BOOL isQRCode;
@end

@implementation PopUpForScan

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.popUpView.layer.cornerRadius = 10;
    self.popUpView.layer.masksToBounds = YES;
    
    self.cancelButton.layer.cornerRadius = 10;
    self.cancelButton.layer.masksToBounds = YES;
    
    self.qrView.layer.cornerRadius = self.barcodeView.layer.cornerRadius =
    self.qrImageView.layer.cornerRadius = self.barcodeImageView.layer.cornerRadius = 10;
    
    self.qrView.layer.masksToBounds = self.barcodeView.layer.masksToBounds =
    self.qrImageView.layer.masksToBounds = self.barcodeImageView.layer.masksToBounds = YES;

    [self.view bringSubviewToFront:self.popUpView];
    [self.backgroundView setHidden:NO];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.backgroundView setHidden:NO];
//        [self.view layoutSubviews];
//    }];
}

#pragma mark - Action

- (IBAction)actionCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionChooseGallery:(UIButton*)sender {
    //NSLog(@"ASdSADASDSADASDASDASDA");
    if (sender.tag == 0) {
        self.isQRCode = YES;
    } else {
        self.isQRCode = NO;
    }
    
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    self.imagePickerController =vc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:^{
        //        [weakIndicator stopAnimating];
        //        weakIndicator.hidden = YES;
        }];
    });
//    [self presentViewController:vc animated:YES completion:^{
////        [weakIndicator stopAnimating];
////        weakIndicator.hidden = YES;
//    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    
    if (!CGRectContainsPoint(self.popUpView.frame, pointOnMainView)) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGFloat test = self.view.frame.size.width + self.view.frame.size.width/3;
    
    
    if (image.size.height < test) {
        image = info[UIImagePickerControllerOriginalImage];
        if (image) {
            self.selectedImage = image;
            [picker dismissViewControllerAnimated:YES completion:^{
                GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
                gvc.selectedImage = self.selectedImage;
                gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                gvc.isQRCode = self.isQRCode;
                gvc.delegate = self;
                
                [self presentViewController:gvc animated:YES completion:^{
                    
                }];
            }];
        }
    } else {
        image = info[UIImagePickerControllerEditedImage];
        self.selectedImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
            gvc.selectedImage = self.selectedImage;
            gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            gvc.isQRCode = self.isQRCode;
            gvc.delegate = self;
            [self presentViewController:gvc animated:YES completion:^{
                
            }];
        }];

    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    __weak PopUpForScan* weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
   //[self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
   
}
#pragma mark - Navigation
- (void) exitCamera{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)dealloc
{
   // NSLog(@"AAA - Pop delloc");
}
@end
