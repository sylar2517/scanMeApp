//
//  ResultTextVC.m
//  QRApp
//
//  Created by Сергей Семин on 10/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ResultTextVC.h"
#import "DataManager.h"
#import "HistoryPost+CoreDataClass.h"
#import <CoreData/CoreData.h>

@interface ResultTextVC ()
@property(assign, nonatomic)NSInteger startCoordY;
@end

@implementation ResultTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (self.text && self.fromCamera) {
        self.resultTextImageView.text = self.text;
        
        self.rollUpButton.hidden = YES;
        [self save];
        
    } else if (self.text && !self.fromCamera){
        self.resultTextImageView.text = self.text;
        self.rollUpButton.hidden = NO;
        
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.mainView.layer.cornerRadius = 20;
    self.mainView.layer.masksToBounds = YES;
    
    self.settingsView.layer.cornerRadius = 10;
    self.settingsView.layer.masksToBounds = YES;
    
    self.resultTextImageView.layer.cornerRadius = 10;
    self.resultTextImageView.layer.masksToBounds = YES;
    
    self.copingButton.layer.cornerRadius = 10;
    self.copingButton.layer.masksToBounds = YES;
    
    self.backButton.layer.cornerRadius = 10;
    self.backButton.layer.masksToBounds = YES;
    
    self.exportButton.layer.cornerRadius = 10;
    self.exportButton.layer.masksToBounds = YES;
}
#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        self.startCoordY = pointOnMainView.y;
        
        if (self.startCoordY < 50) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        NSInteger delta = self.startCoordY - pointOnMainView.y;
        
        self.topLayoutConstraint.constant = 50-delta;
    }
    
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        
        NSInteger delta = self.startCoordY - pointOnMainView.y;
        if (delta < -100) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            self.topLayoutConstraint.constant = 50;
            
        }
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    
    NSInteger delta = self.startCoordY - pointOnMainView.y;
    if (delta < -100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        self.topLayoutConstraint.constant = 50;
        
    }
}
#pragma mark - Methods
-(void)save{
    if (self.text && self.fromCamera) {
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = self.text;
        post.type = @"Text";
        
        [[DataManager sharedManager] saveContext];
    }
}

#pragma mark - Actions
- (IBAction)actionBack:(UIButton *)sender {
    [self.resultTextImageView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCopy:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.resultTextImageView.text;
}
- (IBAction)actionExport:(UIButton *)sender {
    
    
    
    NSString* text = self.resultTextImageView.text;
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //Exclude whichever aren't relevant
    [self presentViewController:activityVC animated:YES completion:nil];

    
}
@end
