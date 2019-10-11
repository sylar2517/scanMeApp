//
//  EnterTextViewController.h
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class EnterTextViewController;
@protocol EnterTextViewControllerDelegate
- (void) textTransfer:(NSString*)string forType:(NSString*)type;
@end

@interface EnterTextViewController : UIViewController

@property(strong, nonatomic)NSString* startString;
@property(strong, nonatomic)NSString* type;
@property (nonatomic, weak) id <EnterTextViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainForSE;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainForTel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;


@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)actionDone:(UIButton *)sender;
- (IBAction)actionBack:(UIButton *)sender;
- (IBAction)actionAddContact:(UIButton *)sender;


@end

NS_ASSUME_NONNULL_END
