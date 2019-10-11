//
//  ParentTabViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ParentTabViewController.h"
#import "HistoryScanTVController.h"
@interface ParentTabViewController () <UITabBarControllerDelegate>

@end

@implementation ParentTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)viewController;
        
        if ([nav.topViewController isKindOfClass:[HistoryScanTVController class]]) {
            [self.delegateToChanged changeStartScroll:YES];
        } else {
            [self.delegateToChanged changeStartScroll:NO];
        }
        
    } else {
        [self.delegateToChanged changeStartScroll:NO];        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
