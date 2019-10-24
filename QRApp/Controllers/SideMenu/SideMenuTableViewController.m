//
//  SideMenuTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 17/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "SideMenuTableViewController.h"


NSString* const UserCommitSettingsDidChangeNotificftion = @"UserCommitSettingsDidChangeNotificftion";
NSString* const UserHideSideMenuNotificftion = @"UserHideSideMenuNotificftion";
typedef enum {
    Editing,
    ShowAll,
    ShowQR,
    ShowPDF,
    ShowBarcode,
    ShowText,
    ClearHistory
} UserCommitSettings;

@interface SideMenuTableViewController ()
@property(assign, nonatomic) UserCommitSettings settings;
@end

@implementation SideMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(indexPath.row == 0){
        
        self.settings = Editing;
        
    } else if (indexPath.row == 2){
        
        self.settings = ShowAll;
        
    } else if (indexPath.row == 4){

        self.settings = ShowQR;
        
    }  else if (indexPath.row == 6){
        
        self.settings = ShowPDF;
        
    }  else if (indexPath.row == 8){
        
        self.settings = ShowBarcode;
        
    } else if (indexPath.row == 10){
        
        self.settings = ShowText;
        
    }
    else if (indexPath.row == 12){
        
        self.settings = ClearHistory;
        
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:@(self.settings) forKey:@"resultForHistory"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserCommitSettingsDidChangeNotificftion
                                                        object:nil
                                                      userInfo:dict];

    NSDictionary* dict2 = [NSDictionary dictionaryWithObject:@(3) forKey:@"resultForHistory"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserHideSideMenuNotificftion
                                                           object:nil
                                                         userInfo:dict2];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
    return NO;

}

@end
