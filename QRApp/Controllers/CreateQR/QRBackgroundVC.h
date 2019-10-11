//
//  QRBackgroundVC.h
//  QRApp
//
//  Created by Сергей Семин on 29/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRBackgroundVC : UIViewController

@property(strong, nonatomic)UIImage* transferImage;
@property(strong, nonatomic)NSString*titleText;
@property(strong, nonatomic)NSString*typeQR;


@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *changeColor;


- (IBAction)actionChangeSegmentControl:(UISegmentedControl *)sender;
- (IBAction)actionAddBackgroundColor:(UIButton *)sender;
- (IBAction)actionAddPhoto:(UIButton *)sender;
- (IBAction)actionChooseGallery:(UIButton*)sender;
- (IBAction)actionHiddenPopover:(UIButton *)sender;
@end

NS_ASSUME_NONNULL_END
