//
//  MakeSimpleQRViewController.h
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//@class MakeSimpleQRViewController;
//@protocol MakeSimpleQRViewControllerDelegate
//- (void)qrCodeIsCreated:(MakeSimpleQRViewController*)controller;
//@end


@interface MakeSimpleQRViewController : UIViewController

//@property (nonatomic, weak) id <MakeSimpleQRViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOutletCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *levelConstrain;

- (IBAction)actionExport:(UIButton *)sender;
- (IBAction)actionSaveImage:(UIButton *)sender;


@end

NS_ASSUME_NONNULL_END
