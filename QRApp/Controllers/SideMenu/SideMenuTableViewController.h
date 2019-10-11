//
//  SideMenuTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 17/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SideMenuTableViewController;
@protocol SideMenuTableViewControllerDelegate
- (void)setEditing;
//- (void)dissMissSideMenuTVC;
- (void)clearHistory;
- (void)showAll;
- (void)showQR;
- (void)showPDF;
-(void)showBarcode;
-(void)showText;
@end

@interface SideMenuTableViewController : UITableViewController

@property (nonatomic, weak) id <SideMenuTableViewControllerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIView *textView;


@end

NS_ASSUME_NONNULL_END
