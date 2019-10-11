//
//  ResultTextVC.h
//  QRApp
//
//  Created by Сергей Семин on 10/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResultTextVC : UIViewController

@property(assign, nonatomic)BOOL fromCamera;
@property(strong, nonatomic)NSString* text;


@property (weak, nonatomic) IBOutlet UIButton *rollUpButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextImageView;
@property (weak, nonatomic) IBOutlet UIButton *copingButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;

- (IBAction)actionBack:(UIButton *)sender;

- (IBAction)actionCopy:(UIButton *)sender ;
- (IBAction)actionExport:(UIButton *)sender ;

@end

NS_ASSUME_NONNULL_END
