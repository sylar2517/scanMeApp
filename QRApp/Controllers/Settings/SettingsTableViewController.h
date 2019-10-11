//
//  SettingsTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 17/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewController : UITableViewController


//@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibroSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *resultSwitch;

- (IBAction)actionValueChanged:(UISwitch *)sender;

@end

NS_ASSUME_NONNULL_END
