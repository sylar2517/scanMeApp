//
//  CreationViewController.h
//  QRApp
//
//  Created by Сергей Семин on 01/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet UIView *simpleQRView;
@property (weak, nonatomic) IBOutlet UIView *customQRView;
@property (weak, nonatomic) IBOutlet UIImageView *simpleQRImageView;
@property (weak, nonatomic) IBOutlet UIImageView *customQRImageView;
@property (weak, nonatomic) IBOutlet UIButton *simpleQR;
@property (weak, nonatomic) IBOutlet UIButton *customQR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsConstraint;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;




@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//- (IBAction)test:(id)sender;

- (IBAction)actionDeleteAllQR:(UIButton *)sender;


@end

NS_ASSUME_NONNULL_END
