//
//  MakeSimpleQRViewController.m
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "MakeSimpleQRViewController.h"
#import "QRPost+CoreDataClass.h"
#import "DataManager.h"

@interface MakeSimpleQRViewController ()

@end

@implementation MakeSimpleQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    for (UIButton* but in self.buttonsOutletCollection) {
        but.layer.cornerRadius = 10;
        but.layer.masksToBounds = YES;
    }
    self.menuView.layer.cornerRadius = 10;
    self.menuView.layer.masksToBounds = YES;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (CGRectGetWidth(screenBounds) == 320) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotificationCenter
-(void)keyboardWillAppear:(NSNotification*)notification{

    if (self.view.frame.origin.y == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.levelConstrain.constant = -85;
            [self.view layoutIfNeeded];
        }];
    }
}
-(void)keyboardWillDisappear:(NSNotification*)notification{
    [UIView animateWithDuration:0.25 animations:^{
        self.levelConstrain.constant = 10;
        [self.view layoutIfNeeded];
    }];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    if (self.textField.text.length > 0) {
//
//    }

}
#pragma mark - Actions

- (IBAction)actionExport:(UIButton *)sender {
    UIImage* image = self.resultImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(50, 50));
    [image drawInRect:CGRectMake(0, 0, 50, 50)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray* array = @[imageData];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
}

- (IBAction)actionSaveImage:(UIButton *)sender {

    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    
    
    UIImage* image = self.resultImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
//    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Сохранено" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
//    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
//    [ac addAction:aa];
//    [self presentViewController:ac animated:YES completion:nil];
    [self addBannerForSave];
    
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}

#pragma matk -  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.textField.text isEqual:nil] && self.textField.text.length > 0) {
        return YES;
    }
    [self makeQRFromString:self.textField.text];
    [self.textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString* str = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if (str.length > 0) {
        self.resultImageView.hidden = NO;
        UIBarButtonItem* save = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionSave:)];
        self.navigationItem.rightBarButtonItem = save;
        
        [self makeQRFromString:str];
    } else {
        self.resultImageView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return YES;
}

-(void)actionSave:(UIBarButtonItem*)sender{
    if (self.textField.text) {
        QRPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"QRPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.type = @"Простой";
        post.value = self.textField.text;
        
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.data = imageData;
        
        [[DataManager sharedManager] saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma matk - private Methods
-(void)makeQRFromString:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    self.resultImageView.image = [UIImage imageWithCIImage:qrImage
                                                     scale:[UIScreen mainScreen].scale
                                               orientation:UIImageOrientationUp];
}
-(UIImage*)makeQRForSaveOrExport{
    NSData *stringData = [self.textField.text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return  [UIImage imageWithCIImage:qrImage
                             scale:[UIScreen mainScreen].scale
                       orientation:UIImageOrientationUp];
}


@end
