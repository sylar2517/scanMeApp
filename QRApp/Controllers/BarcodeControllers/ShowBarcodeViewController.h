//
//  ShowBarcodeViewController.h
//  QRApp
//
//  Created by Сергей Семин on 26/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BarcodePost;
@interface ShowBarcodeViewController : UIViewController

@property(strong, nonatomic)BarcodePost* post;

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthDecriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthDecriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthDecriptionCopyButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthAllImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthSaveAllButton;


@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *textCopy;
@property (weak, nonatomic) IBOutlet UIImageView *allImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveAll;
@property (weak, nonatomic) IBOutlet UIButton *exportAll;


- (IBAction)actionSaveOnlyBarcode:(UIButton *)sender;
- (IBAction)actionExportOnlyBarcode:(UIButton *)sender;
- (IBAction)actionCopyText:(UIButton *)sender;
- (IBAction)actionSaveAll:(UIButton *)sender;
- (IBAction)actionExportAll:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
