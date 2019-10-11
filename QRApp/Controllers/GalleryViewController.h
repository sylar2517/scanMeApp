//
//  GalleryViewController.h
//  QRApp
//
//  Created by Сергей Семин on 25/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GalleryViewControllerDelegate
- (void) exitCamera;
@end

@interface GalleryViewController : UIViewController
@property(strong, nonatomic)UIImage* selectedImage;
@property(assign, nonatomic)BOOL isQRCode;
@property (nonatomic, weak) id <GalleryViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOutletCollection;

- (IBAction)actionCopy:(UIButton *)sender;
- (IBAction)actionScan:(UIButton *)sender;
- (IBAction)actionBack:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
