//
//  GalleryViewController.m
//  QRApp
//
//  Created by Сергей Семин on 25/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "GalleryViewController.h"
#import "DataManager.h"
#import "HistoryPost+CoreDataClass.h"
#import <CoreData/CoreData.h>

#import <AudioToolbox/AudioToolbox.h>

@import ZXingObjC;

static NSString* kSettingsTouchID                     = @"touchID";
static NSString* kSettingsVibro                     = @"password";
static NSString* kSettingsAudio                     = @"audio";
static NSString* kSettingsResult                    = @"result";
static NSString* kSettingsFirstRun                  = @"FirstRun";

@interface GalleryViewController ()

@property(strong, nonatomic)UIImage* QRCode;
@property(assign, nonatomic)BOOL isHaveResult;
@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.selectedImage) {
        self.selectedImageView.image = self.selectedImage;
    }
    //self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];

    
    [self.view bringSubviewToFront:self.textView];

    for (UIButton* but in self.buttonsOutletCollection) {
        but.layer.cornerRadius = 10;
        but.layer.masksToBounds = YES;
    }
    self.panelView.layer.cornerRadius = 10;
    self.panelView.layer.masksToBounds = YES;

}
- (void)dealloc
{
    //NSLog(@"AAA - Gallery delloc");
}


#pragma mark - Actions
- (IBAction)actionCopy:(UIButton *)sender {
    NSString* textViewText = self.textView.text;
    if ([textViewText isEqualToString:@"Начните сканирование"] || [textViewText isEqualToString:@"Ничего не обнаруженно"]) {
        return;
    } else {
        [UIPasteboard generalPasteboard].string = textViewText;
    }
}

- (IBAction)actionScan:(UIButton *)sender {
    [self scan];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
}

- (IBAction)actionBack:(UIButton *)sender {
    [self.textView resignFirstResponder];
    if (self.isHaveResult && self.isQRCode) {
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.type = @"QR";
        post.value = self.textView.text;
        if (self.qrCodeImageView.image) {
            UIImage* image = self.qrCodeImageView.image;
            
            UIGraphicsBeginImageContext(CGSizeMake(400, 400));
            [image drawInRect:CGRectMake(0, 0, 400, 400)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *imageData = UIImagePNGRepresentation(newImage);
            post.picture = imageData;
        }
        
        [[DataManager sharedManager] saveContext];
    } else if (self.isHaveResult && !self.isQRCode){
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = self.textView.text;
        post.type = @"Штрихкод";
        
        UIImage* image = self.qrCodeImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(500, 300));
        [image drawInRect:CGRectMake(0, 0, 500, 300)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.picture = imageData;
        
        [[DataManager sharedManager] saveContext];
    }
    
    __weak GalleryViewController* weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf.delegate exitCamera];
    }];
//    [self.delegate exitCamera];
//    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Methods
-(void)scan{
    UIImage* line = [UIImage imageNamed:@"line.png"];
    UIImageView* lineView = [[UIImageView alloc] initWithImage:line];
    lineView.backgroundColor = [UIColor clearColor];
    lineView.frame = CGRectMake(CGRectGetMinX(self.selectedImageView.frame),
                                CGRectGetMinY(self.selectedImageView.frame),
                                CGRectGetWidth(self.selectedImageView.bounds)+10,
                                5);
    
    [UIView animateWithDuration:1
                          delay:0
                        options:(UIViewAnimationOptionCurveLinear)
                     animations:^{
                         [self.view addSubview:lineView];
                         lineView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.selectedImageView.bounds));
                         
                     } completion:^(BOOL finished) {
                         [lineView removeFromSuperview];
                         if (self.isQRCode) {
                             [self getQRCode];
                         } else {
                             [self getBarcode];
                         }
                         
                     }];
    
}
-(void)getBarcode{
    @autoreleasepool {
        CGImageRef imageToDecode = self.selectedImage.CGImage;
        
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        if (result) {
            
            if (result.barcodeFormat != kBarcodeFormatQRCode) {
                self.textView.text = result.text;
                self.isHaveResult = YES;
                ZXBarcodeFormat format = result.barcodeFormat;
                NSString* testStr =result.text;
                [self createBarcodeWithFormat:format andEncode:testStr];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
                
                if (first > 0) {
                    if ([userDefaults boolForKey:kSettingsVibro]) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    if ([userDefaults boolForKey:kSettingsAudio]) {
                        AudioServicesPlayAlertSound (1117);
                    }
                } else {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
                    
                    if (first > 0) {
                        if ([userDefaults boolForKey:kSettingsVibro]) {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        }
                        if ([userDefaults boolForKey:kSettingsAudio]) {
                            AudioServicesPlayAlertSound (1117);
                        }
                    } else {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        AudioServicesPlayAlertSound (1117);
                    }
                }
              
            }
            
        } else {
            self.textView.text =@"Ничего не обнаруженно";
            self.isHaveResult = NO;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
            
            if (first > 0) {
                if ([userDefaults boolForKey:kSettingsVibro]) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                if ([userDefaults boolForKey:kSettingsAudio]) {
                    AudioServicesPlayAlertSound (1117);
                }
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);
            }
        }
    }
    
}
-(void)createBarcodeWithFormat:(ZXBarcodeFormat) format andEncode:(NSString*)encode{
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:encode
                                  format:format
                                   width:500
                                  height:300
                                   error:&error];
    if (result) {
        CGImageRef image = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);
        CGImageRelease(image);
        self.qrCodeImageView.image = [UIImage imageWithCGImage:image];
    }
//    else {
////        NSString *errorMessage = [error localizedDescription];
////        NSLog(@"AAA %@", errorMessage);
//    }
}
-(void)getQRCode{
    @autoreleasepool {
        
        NSData* imageData = UIImagePNGRepresentation(self.selectedImage);
        CIImage* ciImage = [CIImage imageWithData:imageData];
        CIContext* context = [CIContext context];
        NSDictionary* options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        if (features != nil && features.count > 0) {
            for (CIQRCodeFeature* qrFeature in features) {
                self.textView.text =qrFeature.messageString;
                [self makeQRFromText:qrFeature.messageString];
                self.isHaveResult = YES;
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
                
                if (first > 0) {
                    if ([userDefaults boolForKey:kSettingsVibro]) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    if ([userDefaults boolForKey:kSettingsAudio]) {
                        AudioServicesPlayAlertSound (1117);
                    }
                } else {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlayAlertSound (1117);
                }
            }
        } else {
            self.textView.text =@"Ничего не обнаруженно";
            self.isHaveResult = NO;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
            
            if (first > 0) {
                if ([userDefaults boolForKey:kSettingsVibro]) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                if ([userDefaults boolForKey:kSettingsAudio]) {
                    AudioServicesPlayAlertSound (1117);
                }
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);
            }
        }
        
    }

}

-(void)makeQRFromText:(NSString*)text{

    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.qrCodeImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.qrCodeImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    self.qrCodeImageView.image = [UIImage imageWithCIImage:qrImage
                                                     scale:[UIScreen mainScreen].scale
                                               orientation:UIImageOrientationUp];
    self.QRCode =[UIImage imageWithCIImage:qrImage
                                     scale:[UIScreen mainScreen].scale
                               orientation:UIImageOrientationUp];

}
#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return orientation == UIInterfaceOrientationPortrait ? NO : YES;
}

//#pragma mark - Touces
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.textView resignFirstResponder];
//}


//- (CIImage *)createQRForString:(NSString *)qrString {
//    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
//
//    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    [qrFilter setValue:stringData forKey:@"inputMessage"];
//
//
//    return qrFilter.outputImage;
//}

//#pragma mark - UITextViewDelegate
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    NSLog(@"AAA- %@", textView.text);
//    [self makeQRFromText:textView.text];
//}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
