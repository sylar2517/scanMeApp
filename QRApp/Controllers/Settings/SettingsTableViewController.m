//
//  SettingsTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 17/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "DataManager.h"
@interface SettingsTableViewController ()

@end

//static NSString* kSettingsTouchID                     = @"touchID";
static NSString* kSettingsVibro                     = @"password";
static NSString* kSettingsAudio                     = @"audio";
static NSString* kSettingsResult                    = @"result";
static NSString* kSettingsFirstRun                  = @"FirstRun";


@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self isFirstTime]) {
        [self loadSettings];
    }
//    [self.tabBarItem setImageInsets:UIEdgeInsetsMake(50, 0, 50, 0)];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
#pragma mark - Save and Load
-(BOOL)isFirstTime{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
    return first > 0 ? NO : YES;
}
-(void) saveSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:1337 forKey:kSettingsFirstRun];
    //[userDefaults setBool:self.touchIDSwitch.isOn forKey:kSettingsTouchID];
    [userDefaults setBool:self.vibroSwitch.isOn forKey:kSettingsVibro];
    [userDefaults setBool:self.audioSwitch.isOn forKey:kSettingsAudio];
    [userDefaults setBool:self.resultSwitch.isOn forKey:kSettingsResult];

    [userDefaults synchronize];
}

-(void)loadSettings {
    
    //загружаем натсройки
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
   // self.touchIDSwitch.on = [userDefaults boolForKey:kSettingsTouchID];
    self.vibroSwitch.on = [userDefaults boolForKey:kSettingsVibro];
    self.audioSwitch.on = [userDefaults boolForKey:kSettingsAudio];
    self.resultSwitch.on = [userDefaults boolForKey:kSettingsResult];
    
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 3 ? YES : NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self allertForDelete];
    } else {
        NSLog(@"Not here");
    }
}
-(void)allertForDelete{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Отчистить все?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager] deleteAll];
    }];
    
    
    [ac2 addAction:aa];
    [ac2 addAction:clear];
    
    [self presentViewController:ac2 animated:YES completion:nil];
}


- (IBAction)actionValueChanged:(UISwitch *)sender {
    [self saveSettings];
}
@end
