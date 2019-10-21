//
//  SideMenuTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 17/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const UserCommitSettingsDidChangeNotificftion;


@interface SideMenuTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIView *textView;


@end

NS_ASSUME_NONNULL_END
