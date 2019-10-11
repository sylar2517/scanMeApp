//
//  ResultBarcodeViewController.h
//  QRApp
//
//  Created by Сергей Семин on 25/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResultBarcodeViewController : UIViewController

@property (strong, nonatomic) UIImage* transferImage;
@property (strong, nonatomic) NSString* transferText;


@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (IBAction)actionDeletePhoto:(UIButton *)sender;
- (IBAction)actionAddPhoto:(UIButton *)sender;
- (IBAction)actionHiddenPopover:(UIButton *)sender;
- (IBAction)actionChooseGallery:(UIButton*)sender;
@end

NS_ASSUME_NONNULL_END
