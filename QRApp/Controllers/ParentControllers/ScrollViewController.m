//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 26/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ScrollViewController.h"
#import "QRViewController.h"
#import "ResultViewController.h"
#import "ParentTabViewController.h"
#import "DataManager.h"


@interface ScrollViewController () <UIScrollViewDelegate, QRViewControllerDelegate, ParentTabViewControllerDelegate>

@property(assign, nonatomic)BOOL firstTime;
@property(assign, nonatomic)BOOL isHaveShadow;
@property(strong, nonatomic) UIButton* sideMenuExitButton;

@end

static const NSInteger sizeSideMenu = 230;

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // NSLog(@"%f", self.widthConstrain.constant);
    self.widthConstrain.constant = CGRectGetWidth(self.view.bounds);
    [self.view layoutIfNeeded];

    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
    self.firstTime = YES;
    
    self.lockedView.hidden = YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.scrollView.contentOffset.x == CGRectGetWidth(self.view.frame)) {
        [self.delegate changeScreen:YES];
    }

     [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sideMenuShow: )
                                                     name:@"UserAddSideMenuNotificftion"
                                                   object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(sideMenuHide: )
                                                  name:@"UserHideSideMenuNotificftion"
                                                object:nil];


}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self stopScrolling:scrollView.contentOffset.x];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self stopScrolling:scrollView.contentOffset.x];
    
    if (scrollView.contentOffset.x == CGRectGetWidth(self.view.bounds) + sizeSideMenu) {
        [self showLockedView];
    } else if (scrollView.contentOffset.x == CGRectGetWidth(self.view.bounds)) {
        self.lockedView.hidden = YES;
        self.sideMenuView.layer.shadowOffset = CGSizeMake(0, 0);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"AAA = %f", scrollView.contentOffset.x);
    if ((scrollView.contentOffset.x < CGRectGetWidth(self.view.bounds) + sizeSideMenu) && self.isHaveShadow == YES) {
        self.lockedView.hidden = YES;
        self.sideMenuView.layer.shadowOffset = CGSizeMake(0, 0);
    }
}

#pragma mark - NSNotification
-(void)sideMenuShow:(NSNotification*)note{
    if ([[note.userInfo valueForKey:@"resultForHistory"] intValue] == 2) {
        CGPoint bottomOffset = CGPointMake(self.scrollView.contentOffset.x + sizeSideMenu, 0);
//        [self.scrollView setContentOffset:bottomOffset animated:YES];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = bottomOffset;
        } completion:^(BOOL finished) {
            self.isHaveShadow = YES;
        }];
        
        
        [self showLockedView];
        self.isHaveShadow = NO;
    }
}

-(void)sideMenuHide:(NSNotification*)note{
    if ([[note.userInfo valueForKey:@"resultForHistory"] intValue] == 3) {
        CGPoint bottomOffset = CGPointMake(self.scrollView.contentOffset.x - sizeSideMenu, 0);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        self.lockedView.hidden = YES;
        self.sideMenuView.layer.shadowOffset = CGSizeMake(0, 0);
    }
}

-(void)stopScrolling:(NSInteger)interVal{
    if (interVal > 1) {
        [self.delegate changeScreen:YES];
    } else {
        [self.delegate changeScreen:NO];
    }
}


-(void)showLockedView{
    self.lockedView.hidden = NO;
    self.sideMenuView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sideMenuView.layer.shadowOpacity = 0.25;
    self.sideMenuView.layer.shadowOffset = CGSizeMake(-10, 5);
    self.sideMenuView.layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.sideMenuView];
}

#pragma mark - Action

- (IBAction)actionCloseSideMenu:(id)sender {
    CGPoint bottomOffset = CGPointMake(self.scrollView.contentOffset.x - sizeSideMenu, 0);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    self.lockedView.hidden = YES;


    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
              }
          });
}



#pragma mark - QRVCDelegate

- (void)pushResultVC:(NSString*)string{
    ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    vc.result = string;
    vc.fromCamera = YES;
    vc.isBarcode = NO;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:^{

    }];
}

- (void)changeStartScroll:(BOOL)startScroll{
    if (startScroll) {
        [self.scrollView setScrollEnabled:YES];
    } else {
        [self.scrollView setScrollEnabled:NO];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"camSegue"]) {
        QRViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        vc.parent = self;
    }
    else if ([segue.identifier isEqualToString:@"tabBarControllerParent"]){
        ParentTabViewController* vc = segue.destinationViewController;
        vc.delegateToChanged = self;
    }
    

}



@end
