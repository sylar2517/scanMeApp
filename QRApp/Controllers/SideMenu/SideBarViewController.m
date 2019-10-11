//
//  SideBarViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "SideBarViewController.h"
#import "SideMenuTableViewController.h"
#import "HistoryScanTVController.h"

@interface SideBarViewController () <SideMenuTableViewControllerDelegate>
//@property(assign, nonatomic)NSInteger startCoordX;
@end

@implementation SideBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.blurView.alpha = 0;
  
    UISwipeGestureRecognizer *gestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerRight:)];
   [gestureRecognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
   [self.view addGestureRecognizer:gestureRecognizerRight];

    
}

-(void)swipeHandlerRight:(id)sender
{
   [self exitFromController];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
//    self.blurView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.rightConstraint.constant = 0;
//        self.blurView.alpha = 0.9;
        [self.view layoutIfNeeded];
    }];
   
}


- (IBAction)actionExit:(id)sender {
    [self exitFromController];
}

-(void)exitFromController{
    self.blurView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.rightConstraint.constant = 250;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSideController"]) {
        SideMenuTableViewController* vc = segue.destinationViewController;
        vc.delegate = self;
    }
}
#pragma mark - SideMenuTableViewControllerDelegate

- (void)setEditing{
    [self.historyVC setEditingHistory];
    //[self.historyVC.navigationItem setTitle:@""];
    [self exitFromController];
}
- (void)clearHistory{
//    [self.historyVC clearHistory];
//    [self exitFromController];
    [UIView animateWithDuration:0.25 animations:^{
        self.rightConstraint.constant = 250;
        self.blurView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.historyVC clearHistory];
        }];
    }];
}
- (void)showAll{
    [self.historyVC showAll];
    [self.historyVC.navigationItem setTitle:@"История"];
    [self exitFromController];
}
-(void)showQR{
    [self.historyVC showQR];
    [self.historyVC.navigationItem setTitle:@"История (QR)"];
    [self exitFromController];
}
-(void)showPDF{
    [self.historyVC showPDF];
    [self.historyVC.navigationItem setTitle:@"История (PDF)"];
    [self exitFromController];
}
-(void)showBarcode{
    [self.historyVC showBarcode];
    [self.historyVC.navigationItem setTitle:@"История (Штрихкоды)"];
    [self exitFromController];
}
-(void)showText{
    [self.historyVC showText];
    [self.historyVC.navigationItem setTitle:@"История (Тексты)"];
    [self exitFromController];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
//
//    UITouch* touch = [touches anyObject];
//    CGPoint pointOnMainView = [touch locationInView:self.view];
//    self.startCoordX = pointOnMainView.x;
//
////    if (self.startCoordY < 50) {
////        [self dismissViewControllerAnimated:YES completion:nil];
////    }
//
//}
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//   UITouch* touch = [touches anyObject];
//    CGPoint pointOnMainView = [touch locationInView:self.view];
//    NSInteger delta = -(self.startCoordX - pointOnMainView.x);
//
//    NSLog(@"%ld", (long)delta);
//    if (delta > 0) {
//        self.rightConstraint.constant = delta;
//    }
//
//    //self.topLayoutConstraint.constant = 50-delta;
//
//
//}
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
////    if (!self.fromCamera) {
////        if (!self.fromZOOM) {
////             UITouch* touch = [touches anyObject];
////                   CGPoint pointOnMainView = [touch locationInView:self.view];
////
////                   NSInteger delta = self.startCoordY - pointOnMainView.y;
////                   if (delta < -100) {
////                       [self dismissViewControllerAnimated:YES completion:nil];
////                   } else {
////                       self.topLayoutConstraint.constant = 50;
////
////                   }
////        } else {
////            self.topLayoutConstraint.constant = 50;
////            self.fromZOOM = NO;
////        }
////
////    }
//}
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
////    UITouch* touch = [touches anyObject];
////    CGPoint pointOnMainView = [touch locationInView:self.view];
////
////    NSInteger delta = self.startCoordY - pointOnMainView.y;
////    if (delta < -100) {
////        [self dismissViewControllerAnimated:YES completion:nil];
////    } else {
////        self.topLayoutConstraint.constant = 50;
////
////    }
//}
@end
