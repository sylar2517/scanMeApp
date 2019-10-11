//
//  SideBarViewController.h
//  QRApp
//
//  Created by Сергей Семин on 24/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HistoryScanTVController;
@interface SideBarViewController : UIViewController

@property(strong, nonatomic)HistoryScanTVController* historyVC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;


- (IBAction)actionExit:(id)sender;



@end

NS_ASSUME_NONNULL_END
