//
//  CreateBarcodeViewController.h
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateBarcodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

- (IBAction)actionDone:(UIButton *)sender;
- (IBAction)actionGetInfo:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
