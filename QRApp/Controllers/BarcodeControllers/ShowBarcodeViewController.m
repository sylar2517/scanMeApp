//
//  ShowBarcodeViewController.m
//  QRApp
//
//  Created by Сергей Семин on 26/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ShowBarcodeViewController.h"
#import "DataManager.h"
#import "BarcodePost+CoreDataClass.h"
@interface ShowBarcodeViewController ()

@end

@implementation ShowBarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (self.post) {
        self.barcodeLabel.text = [NSString stringWithFormat:@"Штрихкод: %@", self.post.value];
        self.barcodeImageView.image = [UIImage imageWithData:self.post.barcode];
        self.barcodeImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        
        if (self.post.note) {
            self.textView.text = self.post.note;
            self.descriptionLabel.hidden = self.textCopy.hidden = self.textView.hidden = NO;
        } else {
            self.descriptionLabel.hidden = self.textCopy.hidden = self.textView.hidden = YES;
            self.widthDecriptionLabel.constant = self.widthDecriptionTextView.constant = self.widthDecriptionCopyButton.constant = 0;
        }
        
        if (self.post.picture) {
            self.allImageView.image = [UIImage imageWithData:self.post.picture];
            self.allImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self addBarcodeToImage:[UIImage imageWithData:self.post.barcode] andFromImageView:self.allImageView];
        } else {
            self.allImageView.hidden = self.saveAll.hidden = self.exportAll.hidden = YES;
            self.widthAllImageView.constant = self.widthSaveAllButton.constant = 0;
        }
        
        
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


-(void)addBarcodeToImage:(UIImage*)image andFromImageView:(UIImageView*)imageView{
    UIImageView* test = [[UIImageView alloc] initWithImage:image];
    //NSLog(@"AAA%@ %@", NSStringFromCGRect(imageView.frame), NSStringFromCGRect(imageView.bounds));
    
    CGFloat coordX = (CGRectGetWidth(imageView.frame) - CGRectGetWidth(imageView.frame)/2) - 15;
    CGFloat coordY = (CGRectGetHeight(imageView.frame) - CGRectGetHeight(imageView.frame)/2) - 10;
    
    [test setFrame:CGRectMake(coordX,
                              coordY,
                              CGRectGetWidth(imageView.frame)/2,
                              CGRectGetHeight(imageView.frame)/2)];
    
    [imageView addSubview:test];
}

#pragma mark - Actions
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
- (IBAction)actionSaveOnlyBarcode:(UIButton *)sender {
    
    [self addBannerForSave];
    
    UIImage* image = self.barcodeImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
   
    
}

- (IBAction)actionExportOnlyBarcode:(UIButton *)sender {
    UIImage* image = self.barcodeImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray* array = @[imageData];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
}

- (IBAction)actionCopyText:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.textView.text;
}

- (IBAction)actionSaveAll:(UIButton *)sender {
    
    UIImage* image = [self imageByCombiningImage:self.allImageView.image withImage:self.barcodeImageView.image];
    
    [self addBannerForSave];
    
    UIGraphicsBeginImageContext(self.allImageView.bounds.size);
    [image drawInRect:self.allImageView.bounds];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    
}

- (IBAction)actionExportAll:(UIButton *)sender {
   
    UIImage* image = [self imageByCombiningImage:self.allImageView.image withImage:self.barcodeImageView.image];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSArray* array = @[imageData];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize size = self.allImageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    
    CGFloat coordX = (size.width - size.width/2) - 15;
    CGFloat coordY = (size.height - size.height/2) - 10;
    
    CGRect rect2 = CGRectMake(coordX,
                              coordY,
                              size.width/2,
                              size.height/2);
    
    [secondImage drawInRect:rect2];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
