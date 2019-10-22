//
//  ZoomViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ZoomViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ZoomViewController ()

@end

@implementation ZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.QRImageView.backgroundColor = [UIColor blackColor];
    
    if (self.transferedImage) {
        self.exitButton.layer.cornerRadius = 15;
        self.exitButton.layer.masksToBounds = YES;
        //self.QRImageView.layer.magnificationFilter = kCAFilterNearest;
        self.QRImageView.image = self.transferedImage;
        self.QRImageView.clipsToBounds = YES;
        self.QRImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    if (self.isContact) {
        self.exportButton.layer.cornerRadius = 15;
        self.exportButton.layer.masksToBounds = YES;
        self.exportButton.hidden = NO;
        
        self.saveButton.layer.cornerRadius = 15;
        self.saveButton.layer.masksToBounds = YES;
        self.saveButton.hidden = NO;
    }
    
    //
    self.QRImageView.backgroundColor = [UIColor clearColor];
}

-(void)addBannerForSave{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
       view.backgroundColor = [UIColor darkGrayColor];
       view.center = self.view.center;
       view.layer.cornerRadius = 15;
       view.layer.masksToBounds = YES;
       view.alpha = 0;
       [self.view addSubview:view];
       [UIView animateWithDuration:0.25 animations:^{
           view.alpha = 1;
       }];
    
       UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];

       label.backgroundColor = [UIColor clearColor];
       label.textAlignment = NSTextAlignmentCenter;
       label.textColor = [UIColor whiteColor];
       label.numberOfLines = 0;
       label.font = [UIFont boldSystemFontOfSize:24];
       label.text = @"Сохранено";
       [view addSubview:label];

       CAShapeLayer* shapelayer = [[CAShapeLayer alloc] init];
       __block UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(100, 100) radius:75 startAngle:-M_PI/2 endAngle:2*M_PI clockwise:YES];

       shapelayer.path = path.CGPath;
       shapelayer.strokeColor = [UIColor greenColor].CGColor;
       shapelayer.lineCap = kCALineCapRound;
       shapelayer.fillColor = [UIColor clearColor].CGColor;
       shapelayer.lineWidth = 5;

       [view.layer addSublayer:shapelayer];

        CAShapeLayer* tracklayer = [[CAShapeLayer alloc] init];

        tracklayer.path = path.CGPath;
        tracklayer.strokeColor = [UIColor grayColor].CGColor;
        tracklayer.lineCap = kCALineCapRound;
        tracklayer.fillColor = [UIColor clearColor].CGColor;
        tracklayer.lineWidth = 5;

        [view.layer addSublayer:shapelayer];

       shapelayer.strokeEnd = 0;
       CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
       animation.toValue = [NSNumber numberWithInt:1];
       animation.duration = 0.5;
       animation.fillMode = kCAFillModeForwards;
       [animation setRemovedOnCompletion:NO];
       [shapelayer addAnimation:animation forKey:@"urSoBasic"];
       
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [view removeFromSuperview];
           path = nil;
       });
}

- (IBAction)actionExtit:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(UIButton *)sender {
    UIImage* image = self.QRImageView.image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    [self addBannerForSave];
}

- (IBAction)actionExport:(UIButton *)sender {
    
    UIImage* image = self.QRImageView.image;
    
    NSArray* array = @[image];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
    
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
