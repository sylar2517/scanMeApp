//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

#import "WebViewController.h"
#import "PopUpForScan.h"
#import "ResultViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#import "ScrollViewController.h"
#import "CameraFocusSquare.h"

#import "ResultTextVC.h"
#import "HistoryPost+CoreDataClass.h"
#import "DataManager.h"

#import <PDFKit/PDFKit.h>


@import Firebase;
@import ZXingObjC;

typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};

static NSString* kSettingsTouchID                     = @"touchID";
static NSString* kSettingsVibro                     = @"password";
static NSString* kSettingsAudio                     = @"audio";
static NSString* kSettingsResult                    = @"result";
static NSString* kSettingsFirstRun                  = @"FirstRun";

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, ScrollViewControllerDelegate, AVCapturePhotoCaptureDelegate>

@property(strong, nonatomic)UIView* qrView;
@property(strong, nonatomic)UILabel* qrLabel;


@property(strong, nonatomic)UIView* barcodeViewTop;
@property(strong, nonatomic)UIView* barcodeViewBottom;

@property(strong, nonatomic) NSArray* request;
@property(assign, nonatomic) BOOL haveResult;


@property(assign, nonatomic) BOOL isStartScanText;

@property(assign, nonatomic) NSInteger buttonPressed;
@property(strong, nonatomic) NSMutableArray* tempForPhoto;


@property(strong, nonatomic) AVCaptureSession* session;
@property(assign, nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;
@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
@property(strong, nonatomic)AVCaptureDevice* device;
@property(strong, nonatomic)AVCaptureMetadataOutput *output;
@property(strong, nonatomic)AVCaptureVideoDataOutput *outputText;
@property(strong, nonatomic)AVCapturePhotoOutput *outputPhoto;
@property(assign, nonatomic)BOOL isScaningText;
@property(assign, nonatomic)BOOL isBarcode;

@property(strong, nonatomic)CameraFocusSquare* focusSquare;

@property(strong, nonatomic) CIContext* context;
@property(strong, nonatomic) FIRVision *vision;
@property(strong, nonatomic) FIRVisionTextRecognizer *textRecognizer;

@property(strong, nonatomic)NSString* tempStr;
@property(strong, nonatomic)NSString* tempStrBarcode;
@property(strong, nonatomic)UIActivityIndicatorView* indicator;
@end

@implementation QRViewController

#pragma mark - Lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonPressed = 0;
    self.tempForPhoto = [NSMutableArray array];
    
    self.session = [[AVCaptureSession alloc] init];
    [[DataManager sharedManager] setCurrentSession:self.session];

    [self initSessionForQR:YES];
    
    //custom view editing
    self.toolBarView.layer.cornerRadius = 10;
    self.toolBarView.layer.masksToBounds = YES;
    
    self.textScanButton.layer.cornerRadius = 10;
    self.textScanButton.layer.masksToBounds = YES;
    
    self.saveLabel.layer.cornerRadius = 10;
    self.saveLabel.layer.masksToBounds = YES;
    
    self.conterView.layer.cornerRadius = 0.5 * self.conterView.bounds.size.width;;
    self.conterView.layer.masksToBounds = YES;
    
    self.snapButtonView.layer.cornerRadius = 0.5 * self.snapButtonView.bounds.size.width;;
    self.snapButtonView.layer.masksToBounds = YES;
    
    self.snapButton.layer.cornerRadius = 0.5 * self.snapButton.bounds.size.width;;
    self.snapButton.layer.masksToBounds = YES;
    
    //go to Scan
    
    [self actionScanQR:self.QRScanButton];
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appMovedToForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appMovedToBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.parent.delegate = self;
    self.haveResult = YES;
    
    self.qrView = [[UIView alloc] init];
    self.qrLabel = [[UILabel alloc] init];
    
    
    self.isStartScanText = NO;
    
    self.context = [CIContext context];
    self.vision = [FIRVision vision];
    self.textRecognizer = [self.vision onDeviceTextRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    
    [self.view addGestureRecognizer:pinchRecognizer];
    
    for (UIButton*bat in self.buttons) {
        bat.layer.cornerRadius = 10;
        bat.layer.masksToBounds = YES;
    }
    
    self.tempStr = @"";
    self.tempStrBarcode = @"";
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Start scan

    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess:
            {
                [self.session startRunning];
            }
                break;
            default:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAllert];
                });
               // [self showAllert];
                break;
        }
    });
    
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
    
    self.conterButton.hidden = YES;
    self.conterView.hidden = YES;
    
    
    [self.qrView removeFromSuperview];
    self.qrView.frame = CGRectZero;
    self.qrLabel.text = nil;
    
    
    self.haveResult = YES;
    [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.haveResult = NO;
}

- (void)dealloc
{
    self.imageView = nil;
    [self.session stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
}

- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    if (self.imageView.layer.sublayers.count > 1) {
        for (CALayer *layer in [self.imageView.layer.sublayers copy]) {
            if (![layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
    }
//    [self.qrView removeFromSuperview];
//    self.qrView.frame = CGRectZero;
//    self.qrLabel.text = nil;
//    if (self.qrView && self.buttonPressed != 0) {
//        [self.qrView removeFromSuperview];
//        self.qrView.frame = CGRectZero;
//        self.qrLabel.text = nil;
//    }
   
//    NSLog(@"2 - %@", self.imageView.layer.sublayers);
}


#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    
    [self focusOnPoint:pointOnMainView];
    
    if (!self.focusSquare) {
        self.focusSquare = [[CameraFocusSquare alloc] initWithTouchPoint:pointOnMainView];
        [self.view addSubview:self.focusSquare];
        [self.focusSquare setNeedsDisplay];
    } else {
        [self.view bringSubviewToFront:self.focusSquare];
        [self.focusSquare updatePoint:pointOnMainView];
    }
    
    [self.focusSquare animateFocusingAction];
    
}


-(void)focusOnPoint:(CGPoint)pointOnView{
    
    
    CGRect rect1 = CGRectMake(0, CGRectGetMinY(self.toolBarView.frame) - 50, CGRectGetWidth(self.view.frame), 400);
    CGRect rect2 = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.toolBarView.frame) + 50);

    if (CGRectContainsPoint(rect1, pointOnView) | CGRectContainsPoint(rect2, pointOnView)) {
        return;
    }
    
    NSError *error = nil;
    
    double focus_x = pointOnView.x/self.video.frame.size.width;
    double focus_y = pointOnView.y/self.video.frame.size.height;
    
    CGPoint focusPoint = CGPointMake(focus_x, focus_y);
    
    if ([self.device lockForConfiguration:&error]) {
        if ([self.device isFocusPointOfInterestSupported]) {
            [self.device setFocusPointOfInterest:CGPointMake(focusPoint.x, focusPoint.y)];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
            
        } else{
            NSLog(@"isFocusPointOfInterestSupported");
        }
        
        if ([self.device isExposurePointOfInterestSupported]) {
            [self.device setExposurePointOfInterest:CGPointMake(focusPoint.x, focusPoint.y)];
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            
        }
        else{
            NSLog(@"isExposurePointOfInterestSupported");
        }
        [self.device unlockForConfiguration];
        
    } else {
        if (error) {
            NSLog(@"error - %@", error);
        }
    }
}
- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer{
    
    CGFloat scale = pinchRecognizer.scale;
    NSLog(@"%f", scale);
    //    const CGFloat pinchVelocityDividerFactor = 25.0f;
    CGFloat pinchVelocityDividerFactor;
    if (scale < 1.0f) {
        pinchVelocityDividerFactor = 25.0f;
    } else {
        pinchVelocityDividerFactor = 100.f;
    }
    
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        NSError *error = nil;
        if ([self.device lockForConfiguration:&error]) {
            CGFloat desiredZoomFactor = self.device.videoZoomFactor + atan2f(pinchRecognizer.velocity, pinchVelocityDividerFactor);
            // Check if desiredZoomFactor fits required range from 1.0 to activeFormat.videoMaxZoomFactor
            self.device.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, self.device.activeFormat.videoMaxZoomFactor));
            [self.device unlockForConfiguration];
        } else {
            NSLog(@"error: %@", error);
        }
    }
}
#pragma mark - ScrollViewControllerDelegate

- (void) changeScreen:(BOOL)stopSession{
    
    if (stopSession) {
        
        if (![self.session isRunning]) {

        } else {
            [self.session stopRunning];
        }
        self.haveResult = NO;
    } else {
        [self.session startRunning];
        
        [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
        
        
        self.haveResult = YES;
        if (self.qrLabel.text){
            [self.qrView removeFromSuperview];
            self.qrView.frame = CGRectZero;
            self.qrLabel.text = nil;
        }
    }
}

#pragma mark - SessionSettings

-(void)highlightBordersQR{
    
    self.qrView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.qrView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
    self.qrView.layer.borderWidth = 2;
    self.qrView.layer.cornerRadius = 10;
    self.qrView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.qrView];
    [self.view bringSubviewToFront:self.qrView];
    
    self.qrLabel.frame = self.qrView.frame;
   
    self.qrLabel.numberOfLines = 10;
    self.qrLabel.adjustsFontSizeToFitWidth = YES;
    self.qrLabel.lineBreakMode = NSLineBreakByClipping;
    self.qrLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.qrLabel setTextColor:[UIColor whiteColor]];
    [self.qrLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.qrLabel];
    [self.view bringSubviewToFront:self.qrLabel];
}

-(void)initSessionForQR:(BOOL) boolVal{
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    
    if (boolVal) {
        AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        layer.frame = self.view.bounds;
        [self.view.layer addSublayer:layer];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.video = layer;
    }
    

    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:{
            break;
        }
        case AVAuthorizationStatusNotDetermined:{
            
                dispatch_suspend(self.sessionQueue);
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (!granted) {
                        self.setupResult = AVCamSetupResultNotAutorized;
                    }
                    dispatch_resume(self.sessionQueue);
                }];

            break;
        }
        default:
            self.setupResult = AVCamSetupResultNotAutorized;
            break;
    }

    dispatch_async(self.sessionQueue, ^{
        [self addImputForQR:boolVal];
    });
}

-(void)addImputForQR:(BOOL)boolVal{
    if (self.setupResult !=AVCamSetupResultSuccess) {
        return;
    }
    NSError* error = nil;
    
    [self.session beginConfiguration];
    
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = device;
    
    if(!device){
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if (!device) {
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    self.imput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!self.imput) {
        NSLog(@"Imput errror - %@", [error localizedDescription]);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    } else if ([self.session canAddInput:self.imput]){
        [self.session addInput:self.imput];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            self.video.connection.videoOrientation = initialVideoOrientation;
        });
        
    } else {
        NSLog(@"No imput");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    if (boolVal) {
        [self addOutPutForQR:self];
    } else {
        [self addOutPutForText:self];
    }
}

-(void)addOutPutForQR:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
    self.output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        [self.output setMetadataObjectsDelegate:objectsDelegate queue:dispatch_get_main_queue()];
        if (self.isBarcode) {
             self.output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code ,AVMetadataObjectTypeEAN13Code , AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code ,AVMetadataObjectTypePDF417Code ,AVMetadataObjectTypeInterleaved2of5Code ,AVMetadataObjectTypeITF14Code];
            self.isBarcode = NO;
        } else {
            self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
        }
//        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}

-(void)addOutPutForText:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate{
    
    self.outputText = [[AVCaptureVideoDataOutput alloc] init];
   
    
    if (self.isScaningText) {
        
        if ([self.session canAddOutput:self.outputText]) {
            [self.session addOutput:self.outputText];
            
            self.outputText.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                                                        forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
            self.outputText.alwaysDiscardsLateVideoFrames = YES;
            [self.outputText setSampleBufferDelegate:sampleBufferDelegate queue:dispatch_get_main_queue()];
        } else {
            NSLog(@"No output");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }

    } else {
        
        self.outputPhoto = [[AVCapturePhotoOutput alloc]init];
        if ([self.session canAddOutput:self.outputPhoto]) {
            [self.session addOutput:self.outputPhoto];
            self.outputPhoto.highResolutionCaptureEnabled = YES;

        } else {
            NSLog(@"No output");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }
    }
    
    [self.session commitConfiguration];
    
}
-(void)reloadSession{
    [self.session beginConfiguration];
    [self.session removeInput:self.imput];
    [self.session removeOutput:self.output];
    [self.session removeOutput:self.outputText];
    [self.session removeOutput:self.outputPhoto];
    [self.session commitConfiguration];
}
#pragma mark - Actions
- (IBAction)actionFlashOnCliked:(UIButton *)sender {
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive]) {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
                sender.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
            } else {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
                sender.backgroundColor = [UIColor whiteColor];
            }
            [flashLight unlockForConfiguration];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
    });
}


- (IBAction)actionScanQR:(UIButton *)sender {
    
    [self checkPDF:^(BOOL test) {
        if (test) {
            return;
        } else {
            
            [self buttonCliked:sender];
            
            if (sender.tag == self.buttonPressed) {
                return;
            }
            
            [self ignoringInteractionEvents];
            
            [self reloadSession];
            [self initSessionForQR:YES];
            
            [self buttonCliked:sender];
            
            self.buttonPressed = sender.tag;
            [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
            [[DataManager sharedManager] setCurrentSession:self.session];
        }
    }];

}

- (IBAction)actionScanPDF:(UIButton *)sender {

    self.saveLabel.hidden = YES;
    if (sender.tag == self.buttonPressed) {
        return;
    }
    
    [self ignoringInteractionEvents];
    self.isScaningText = NO;
    
    [self reloadSession];
    [self initSessionForQR:NO];
  
    [self.session beginConfiguration];
    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    layer.frame = self.view.bounds;
    [self.view.layer addSublayer:layer];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.video = layer;
    [self.session commitConfiguration];
    
    
    [self buttonCliked:sender];
    self.buttonPressed = sender.tag;
    [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
    [[DataManager sharedManager] setCurrentSession:self.session];
}

- (IBAction)actionBarcode:(UIButton *)sender{

    
    [self checkPDF:^(BOOL test) {
        if (test) {
            return;
        } else {
            
           
            
            if (sender.tag == self.buttonPressed) {
                return;
            }
            
            [self buttonCliked:sender];
            
            [self ignoringInteractionEvents];
            
            [self reloadSession];
            self.isBarcode = YES;
            [self initSessionForQR:YES];
            
            UIView* view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     CGRectGetHeight(self.view.bounds)/2 - 100)];
            view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            self.barcodeViewTop = view1;
            [self.view addSubview:self.barcodeViewTop];
            
            UIView* view2 = [[UIView alloc] initWithFrame:CGRectMake(0,  CGRectGetHeight(self.view.bounds)/2 + 100,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     CGRectGetHeight(self.view.bounds)/2 - 100)];
            view2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            
            self.barcodeViewBottom = view2;
            [self.view addSubview:self.barcodeViewBottom];
            [self.view bringSubviewToFront:self.toolBarView];
            //    [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
            self.buttonPressed = sender.tag;
            [[DataManager sharedManager] setCurrentSession:self.session];
            [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
        }
    }];

}

- (IBAction)scanText:(UIButton *)sender {
    
    [self checkPDF:^(BOOL test) {
        if (test) {
            return;
        } else {
            
            [self buttonCliked:sender];
            
            if (sender.tag == self.buttonPressed) {
                return;
            }
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
                return;
            }
            self.isScaningText = YES;
            
            [self ignoringInteractionEvents];
            
            [self reloadSession];
            
            [self detectText];
            [self initSessionForQR:NO];
            
            
            [self.session beginConfiguration];
            AVCaptureVideoPreviewLayer *imageLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
            imageLayer.videoGravity = AVLayerVideoGravityResize;
            imageLayer.frame = self.imageView.bounds;
            [self.imageView.layer addSublayer:imageLayer];
            self.video = imageLayer;
            
            [self.session commitConfiguration];
            [self.view layoutIfNeeded];
            
            self.buttonPressed = sender.tag;
            
            if (self.qrView) {
                [self.qrView removeFromSuperview];
                self.qrView.frame = CGRectZero;
                self.qrLabel.text = nil;
            }
        }
    }];
    
}





- (IBAction)actionMakePhoto:(UIButton *)sender {
    
    //self.takePhoto = YES;
    
    self.conterView.backgroundColor = [UIColor blackColor];
    __block UIView* snap = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            CGRectGetWidth(self.view.bounds),
                                                            CGRectGetHeight(self.view.bounds))];
    self.conterButton.hidden = NO;
    self.conterView.hidden = NO;
    [self.view bringSubviewToFront:self.conterButton];
    [self.view bringSubviewToFront:self.conterView];
    

    if (!self.indicator) {
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        indicator.color = [UIColor whiteColor];
        indicator.hidesWhenStopped = YES;
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [self.view bringSubviewToFront:indicator];
        [indicator startAnimating];
        self.indicator = indicator;
    } else {
        [self.indicator startAnimating];
    }
   
    AVCapturePhotoSettings* settings = [AVCapturePhotoSettings photoSettings];
    
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ) {
       settings.flashMode = AVCaptureFlashModeAuto;
    } else {
        settings.flashMode = AVCaptureFlashModeOff;
    }

    [self.outputPhoto capturePhotoWithSettings:settings delegate:self];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:0.25 animations:^{
        snap.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:snap];
       
    } completion:^(BOOL finished) {
        [snap removeFromSuperview];
        snap = nil;
    }];
    
}

- (IBAction)actionWatchPDF:(UIButton *)sender {
   
    if (self.tempForPhoto && self.tempForPhoto.count > 0) {
        
        [self.session stopRunning];

        WebViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
        vc.photoArray = self.tempForPhoto;
        //[self.tempForPhoto removeAllObjects];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)actionScanTextButton:(UIButton *)sender {
        self.isStartScanText = YES;
}



#pragma mark - Methods
- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciimg = [CIImage imageWithCVPixelBuffer:pb];
    
    // show result
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:ciimg fromRect:ciimg.extent];
    UIImage *image = [UIImage imageWithCGImage:ref scale:1.0 orientation:(UIImageOrientationUp)];
    
    CFRelease(ref);
    
    return image;
}
-(void)showSaveLabel{
    [self.view bringSubviewToFront:self.saveLabel];
    self.saveLabel.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.saveLabel.hidden = YES;
    });
}
-(void)showAllert{
    NSString* messege = @"Чтобы использовать эту функцию приложения, вам необходимо разрешить приложению использовать камеру. Пожалуйста перейдтите в Настройки -> ScanMe -> Конфиденциальность и пожалуйста предоставьте разрешение на использование камеры";
    UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Ошибка" message:messege preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        self.haveResult = YES;
    }];
    [ac addAction:aa];
    
    [self presentViewController:ac animated:YES completion:nil];
    
}
-(void)makeBarcodeWithType:(ZXBarcodeFormat)type andString:(NSString*)str{
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:str
                                  format:type
                                   width:500
                                  height:300
                                   error:&error];
    if (result) {
        CGImageRef image = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);
        CGImageRelease(image);
        UIImage* imageBarcode = [UIImage imageWithCGImage:image];
        
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = str;
        post.type = @"Штрихкод";
        UIGraphicsBeginImageContext(CGSizeMake(500, 300));
        [imageBarcode drawInRect:CGRectMake(0, 0, 500, 300)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.picture = imageData;
        
        [[DataManager sharedManager] saveContext];
        
        
        
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }
    
}
-(void)defaultSettingsForMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects{
    if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
        
        if (object.type == AVMetadataObjectTypeQRCode && self.haveResult) {
            
            AVMetadataObject * obj = [self.video transformedMetadataObjectForMetadataObject:object];
            
            self.qrView.frame = obj.bounds;
            
            
            if (![self.qrLabel.text isEqualToString:object.stringValue]) {
                self.qrLabel.text = object.stringValue;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);
                [self.session stopRunning];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.delegate pushResultVC:object.stringValue];
                });
                
            }
            
            
            self.qrLabel.text = object.stringValue;
            
        }
        else if ((object.type == AVMetadataObjectTypeAztecCode || object.type == AVMetadataObjectTypeDataMatrixCode) && self.haveResult) {
            
            self.haveResult = NO;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound (1117);
            
            
            if (!object.stringValue) {
                UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                    self.haveResult = YES;
                }];
                [ac addAction:aa];
                
                [self presentViewController:ac animated:YES completion:nil];
            } else {
                UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:[NSString stringWithFormat:@"%@", object.stringValue] preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                    self.haveResult = YES;
                }];
                
                UIAlertAction* copy = [UIAlertAction actionWithTitle:@"Скопировать" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    self.haveResult = YES;
                    [UIPasteboard generalPasteboard].string = object.stringValue;
                }];
                
                [ac addAction:aa];
                [ac addAction:copy];
                
                [self presentViewController:ac animated:YES completion:nil];
            }
            
        }
        else if ((object.type == AVMetadataObjectTypeUPCECode ||
                  object.type == AVMetadataObjectTypeCode93Code ||
                  object.type == AVMetadataObjectTypeCode39Code ||
                  object.type == AVMetadataObjectTypeCode39Mod43Code ||
                  object.type == AVMetadataObjectTypeEAN13Code ||
                  object.type == AVMetadataObjectTypeEAN8Code ||
                  object.type == AVMetadataObjectTypeCode128Code || //
                  object.type == AVMetadataObjectTypePDF417Code)
                 && self.haveResult) {
            
            //self.haveResult = NO;
            
            [self.session stopRunning];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound (1117);
            ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
            vc.result = object.stringValue;
            vc.fromCamera = YES;
            vc.isBarcode = YES;
            vc.AVMetadataObjectType = object.type;
            CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version <= 12.9) {
                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            }
            [self presentViewController:vc animated:YES completion:nil];
            
            
        }
    }
}

-(void)makeQRFromText:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = 400 / qrImage.extent.size.width;
    float scaleY = 400 / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    UIImage* image = [UIImage imageWithCIImage:qrImage
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];
    
    HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    NSDate* now = [NSDate date];
    post.dateOfCreation = now;
    post.value = string;
    post.type = @"QR";
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    post.picture = imageData;
    
    [[DataManager sharedManager] saveContext];
    
}
-(void)ignoringInteractionEvents{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
}


-(void)buttonCliked:(UIButton*)sender{
    for (UIButton* but in self.buttons) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            if (but.tag == 2 || but.tag == 4) {
                but.backgroundColor = [UIColor clearColor];
                [but setImage:nil forState:UIControlStateNormal];
//                but.hidden = YES;
            } else {
                if ([but isEqual:sender]) {
                    [UIView animateWithDuration:0.25 animations:^{
                        but.backgroundColor = [UIColor whiteColor];
                    }];
                } else {
                    but.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
                }
            }
            
        } else {
            if ([but isEqual:sender]) {
                [UIView animateWithDuration:0.25 animations:^{
                    but.backgroundColor = [UIColor whiteColor];
                }];
            } else {
                but.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
            }
        }
       
    }
    
    void (^noQR)(void) = ^{
        [self.session beginConfiguration];
        self.output.metadataObjectTypes = nil;
        [self.session commitConfiguration];
    };
    
    if (sender.tag == 0) {
        
        
        [self allHidden];

        [UIView animateWithDuration:0.5 animations:^{
            self.imageViewQR.hidden = NO;
//            self.toolBarView.alpha = 1;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 1){
        noQR();
        [self allHidden];
        self.snapButton.hidden = self.snapButtonView.hidden = NO; //self.conterView.hidden
        
        [UIView animateWithDuration:0.5 animations:^{
            self.snapButton.hidden = self.snapButtonView.hidden = NO;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 2){
        noQR();
        [self allHidden];

        //CGFloat width = CGRectGetHeight(self.view.bounds);
//        self.bottomConstrain.constant = (width - CGRectGetHeight(self.toolBarView.bounds) - 50);
        self.bottomConstrain.constant =  self.bottomConstrain.constant+ CGRectGetHeight(self.textScanButton.bounds) + 10;

        [UIView animateWithDuration:0.5 animations:^{
            self.textScanButton.hidden = NO;
            self.toolBarView.alpha = 0.3;
            //self.exitButton.hidden = NO;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 3) {
        noQR();
        [self allHidden];
        [UIView animateWithDuration:0.5 animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)checkPDF:(void (^)(BOOL test))blockName{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
    __block BOOL PDF = NO;
    
    
    void (^block)(void) = ^{
        if (self.tempForPhoto.count > 0) {
            UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Удалить PDF" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            
            UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                PDF = YES;
                blockName(PDF);
            }];
            
            UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Удалить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self.tempForPhoto removeAllObjects];
                PDF = NO;
                blockName(PDF);
            }];
            
            [ac addAction:aa];
            [ac addAction:delete];
            
            [self presentViewController:ac animated:YES completion:nil];
        } else {
            blockName(PDF);
        }
    };
    
    if (first > 0) {
        if ([userDefaults boolForKey:kSettingsResult]) {
            block();
        } else {
            blockName(NO);
        }
    } else {
        block();
    }
    
}

-(void)allHidden{
    [self.view layoutIfNeeded];
    self.imageViewQR.hidden = YES;
    self.snapButton.hidden = self.snapButtonView.hidden =self.conterView.hidden = YES;
    self.snapButton.hidden = self.snapButtonView.hidden = YES;
    self.textScanButton.hidden =  YES; //self.exitButton.hidden =
    self.toolBarView.alpha = 1;
    self.conterButton.hidden = YES;
    self.bottomConstrain.constant = 20;
    self.saveLabel.hidden = YES;
    [self.view bringSubviewToFront:self.toolBarView];
    [self.view bringSubviewToFront:self.imageViewQR];
    [self.view bringSubviewToFront:self.snapButton];
    [self.view bringSubviewToFront:self.snapButtonView];
    [self.view bringSubviewToFront:self.conterButton];
   // [self.view bringSubviewToFront:self.zoomSlider];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];

    if (first > 0) {
        if (self.tempForPhoto.count > 0) {
            if (![userDefaults boolForKey:kSettingsResult]) {
               
                self.saveLabel.text = @"PDF сохранено";
                PDFDocument* pdfDoc = [[PDFDocument alloc] init];
                for (int i = 0; i < self.tempForPhoto.count; i++) {
                    PDFPage* pdfPage = [[PDFPage alloc] initWithImage:[self.tempForPhoto objectAtIndex:i]];
                    [pdfDoc insertPage:pdfPage atIndex:i];
                }
                
                NSData* pdfData = pdfDoc.dataRepresentation;
                
                NSDate* now = [NSDate date];
                NSDateFormatter* df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"dd-MM-yyyy HH:mm"];
                
                NSString* name = [[df stringFromDate:now] stringByAppendingString:@".pdf"];
                NSURL* url2 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:name]];
                [pdfData writeToURL:url2 atomically:NO];
                
                HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
                post.dateOfCreation = now;
                post.value = [NSString stringWithFormat:@"%lu страниц(ы)", (unsigned long)self.tempForPhoto.count];
                post.type = @"PDF";
                post.picture = pdfData;
                [[DataManager sharedManager] saveContext];
                [self.view bringSubviewToFront:self.saveLabel];
                
                if (self.tempForPhoto.count > 0) {
                    [self.tempForPhoto removeAllObjects];
                }
                
                self.saveLabel.hidden = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.saveLabel.hidden = YES;
                    self.saveLabel.text = @"Cохранено";
                });
            }
        }
    }

    
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
    

    
    
    if (self.barcodeViewTop && self.barcodeViewBottom) {
        [self.barcodeViewTop removeFromSuperview];
        [self.barcodeViewBottom removeFromSuperview];
    }
    
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects == nil || metadataObjects.count == 0) {
        [self.qrView removeFromSuperview];
        self.qrView.frame = CGRectZero;
        self.qrLabel.text = nil;
    }
 
    if (metadataObjects != nil && metadataObjects.count != 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];

        if (first > 0) {
            
            if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
                
                if (object.type == AVMetadataObjectTypeQRCode && self.haveResult) {
                    
                        AVMetadataObject * obj = [self.video transformedMetadataObjectForMetadataObject:object];
                        
                        self.qrView.frame = obj.bounds;
                        
                        if (![self.qrLabel.text isEqualToString:object.stringValue]) {
                            
                            self.qrLabel.text = object.stringValue;
                            
                            if ([userDefaults boolForKey:kSettingsResult]) {
                                [self.session stopRunning];
                                
                                if ([userDefaults boolForKey:kSettingsVibro]) {
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                }
                                if ([userDefaults boolForKey:kSettingsAudio]) {
                                    AudioServicesPlayAlertSound (1117);
                                }
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self.delegate pushResultVC:object.stringValue];
                                });
                            } else {
                                [self highlightBordersQR];
                                if (![self.tempStr isEqualToString:object.stringValue]) {
                                    if ([userDefaults boolForKey:kSettingsVibro]) {
                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                    }
                                    if ([userDefaults boolForKey:kSettingsAudio]) {
                                        AudioServicesPlayAlertSound (1117);
                                    }
                                    self.tempStr = object.stringValue;
                                    [self makeQRFromText:object.stringValue];
                                    
                                    [self showSaveLabel];
                                    
                                }
                            }
                    }
                    self.qrLabel.text = object.stringValue;
                    
                    
                }  else if ((object.type == AVMetadataObjectTypeAztecCode || object.type == AVMetadataObjectTypeDataMatrixCode) && self.haveResult) {
                    
                    self.haveResult = NO;

                    if ([userDefaults boolForKey:kSettingsVibro]) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    if ([userDefaults boolForKey:kSettingsAudio]) {
                        AudioServicesPlayAlertSound (1117);
                    }
                    
                    
                    if (!object.stringValue) {
                        UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                            self.haveResult = YES;
                        }];
                        [ac addAction:aa];
                        
                        [self presentViewController:ac animated:YES completion:nil];
                    } else {
                        UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:[NSString stringWithFormat:@"%@", object.stringValue] preferredStyle:(UIAlertControllerStyleAlert)];
                        
                        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                            self.haveResult = YES;
                        }];
                        
                        UIAlertAction* copy = [UIAlertAction actionWithTitle:@"Скопировать" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                            self.haveResult = YES;
                            [UIPasteboard generalPasteboard].string = object.stringValue;
                        }];
                        
                        [ac addAction:aa];
                        [ac addAction:copy];
                        
                        [self presentViewController:ac animated:YES completion:nil];
                    }
                    
                }  else if ((object.type == AVMetadataObjectTypeUPCECode ||
                             object.type == AVMetadataObjectTypeCode93Code ||
                             object.type == AVMetadataObjectTypeCode39Code ||
                             object.type == AVMetadataObjectTypeCode39Mod43Code ||
                             object.type == AVMetadataObjectTypeEAN13Code ||
                             object.type == AVMetadataObjectTypeEAN8Code ||
                             object.type == AVMetadataObjectTypeCode128Code || //
                             object.type == AVMetadataObjectTypePDF417Code)
                            && self.haveResult) {
                    
                
                    if ([userDefaults boolForKey:kSettingsResult]) {

                        [self.session stopRunning];
                        if ([userDefaults boolForKey:kSettingsVibro]) {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        }
                        if ([userDefaults boolForKey:kSettingsAudio]) {
                            AudioServicesPlayAlertSound (1117);
                        }
                        
                        ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
                        vc.result = object.stringValue;
                        vc.fromCamera = YES;
                        vc.isBarcode = YES;
                        vc.AVMetadataObjectType = object.type;
                        CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
                        if (version <= 12.9) {
                            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        }
                        [self presentViewController:vc animated:YES completion:nil];

                    } else {

                        if (![self.tempStrBarcode isEqualToString:object.stringValue]) {
                            if ([userDefaults boolForKey:kSettingsVibro]) {
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            }
                            if ([userDefaults boolForKey:kSettingsAudio]) {
                                AudioServicesPlayAlertSound (1117);
                            }
                            self.tempStrBarcode = object.stringValue;

                            if (object.type == AVMetadataObjectTypeUPCECode) {
                                [self makeBarcodeWithType:kBarcodeFormatUPCE andString:object.stringValue];
                            } else if (object.type == AVMetadataObjectTypeCode39Code || object.type == AVMetadataObjectTypeCode39Mod43Code) {
                                [self makeBarcodeWithType:kBarcodeFormatCode39  andString:object.stringValue];
                            }
                            else if (object.type == AVMetadataObjectTypeEAN13Code) {
                                [self makeBarcodeWithType:kBarcodeFormatEan13  andString:object.stringValue];
                            }
                            else if (object.type == AVMetadataObjectTypeEAN8Code) {
                                [self makeBarcodeWithType:kBarcodeFormatEan8  andString:object.stringValue];
                            }
                            else if (object.type == AVMetadataObjectTypeCode93Code) {
                                [self makeBarcodeWithType:kBarcodeFormatCode93  andString:object.stringValue];
                            }
                            else if (object.type == AVMetadataObjectTypeCode128Code) {
                                [self makeBarcodeWithType:kBarcodeFormatCode128  andString:object.stringValue];
                            }
                            else if (object.type == AVMetadataObjectTypePDF417Code) {
                                [self makeBarcodeWithType:kBarcodeFormatPDF417  andString:object.stringValue];
                            }
                            
                            [self showSaveLabel];
                        }

                    }
                    
                }
            }
            
            
            
        } else {
            [self defaultSettingsForMetadataObjects:metadataObjects];
        }
        
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error{
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
    }

    NSData *photoData = [photo fileDataRepresentation];
    UIImage* image = [UIImage imageWithData:photoData];
    [self.tempForPhoto addObject:image];
    [self.conterButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.tempForPhoto.count] forState:(UIControlStateNormal)];

    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self.indicator stopAnimating];
    }
}
- (void)captureOutput:(AVCapturePhotoOutput *)output willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
    
    if (first > 0) {
        if (![userDefaults boolForKey:kSettingsAudio]) {
            AudioServicesDisposeSystemSoundID(1108);
        }
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (self.isScaningText) {
        if (!CMSampleBufferGetImageBuffer(sampleBuffer)) {
            return;
        }
        
        id dict = nil;
        
        CFTypeRef ref = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil);
        if (ref) {
            dict = VNImageOptionCameraIntrinsics;
        }
        VNImageRequestHandler* requestHadler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer) orientation:6 options:dict];
        
        @try {
            
            [requestHadler performRequests:self.request error:nil];
            
        }
        @catch (NSException *exception) {
            NSLog(@"AAA - %@", exception.reason);
        }
    }
    
  
    
    if (self.isStartScanText) {

        self.isStartScanText = NO;
        UIImage* image = [self imageFromSampleBuffer:sampleBuffer];
        image = [self rotateUIImage:image clockwise:YES];

        FIRVisionImage* imageVision = [[FIRVisionImage alloc] initWithImage:image];
        [self.textRecognizer processImage:imageVision
                               completion:^(FIRVisionText *_Nullable result,
                                            NSError *_Nullable error) {
                                   if (error != nil || result == nil) {
                                       return;
                                   }


                                   
                                   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                   NSInteger first = [userDefaults integerForKey:kSettingsFirstRun];
                                   
                                   if (first > 0) {
                                       if ([userDefaults boolForKey:kSettingsVibro]) {
                                           AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                       }
                                       if ([userDefaults boolForKey:kSettingsAudio]) {
                                           AudioServicesPlayAlertSound (1117);
                                       }
                                       if (![userDefaults boolForKey:kSettingsResult]) {
                                           HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
                                           NSDate* now = [NSDate date];
                                           post.dateOfCreation = now;
                                           post.value = result.text;
                                           post.type = @"Text";
                                           
                                           [[DataManager sharedManager] saveContext];
                                           [self showSaveLabel];
                                       } else {
                                           
                                           ResultTextVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVCText"];
                                           vc.text = result.text;
                                           vc.fromCamera = YES;
                                           CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
                                           if (version <= 12.9) {
                                               vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                           }
                                           
                                           [self presentViewController:vc animated:YES completion:nil];
                                           
                                       }
                                      
         
                                       
                                   } else {
                                       AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                       AudioServicesPlayAlertSound (1117);
                                       
                                       ResultTextVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVCText"];
                                       vc.text = result.text;
                                       vc.fromCamera = YES;
                                       CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
                                       if (version <= 12.9) {
                                           vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                       }
                                       [self presentViewController:vc animated:YES completion:nil];

                                   }
                                   
                                   
                               }];
       

        

    }
    
    
}

#pragma mark - detectig text

-(void)detectText{
    VNDetectTextRectanglesRequest* request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
   
        if ([request.results isEqual:nil]) {
            return;
        }
        if (error) {
            NSLog(@"error %@", [error localizedDescription]);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            for (CALayer *layer in [self.imageView.layer.sublayers copy]) {
                if (![layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                    [layer removeFromSuperlayer];
                }
            }

            for (VNTextObservation* region in request.results) {
                if ([region isEqual:nil]) {
                    continue;
                }


                [self higthlightWord:region];

                NSArray* boxes = region.characterBoxes;
                if (boxes) {
                    for (VNRectangleObservation* characterBox in boxes) {
                        [self higthlightLetters:characterBox];
                    }
                }
            }
        });
        
    }];
    
    request.reportCharacterBoxes = YES;
    self.request = @[request];
    
    
//    if (@available(iOS 13.0, *)) {
//        VNRecognizeTextRequest* req = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
//
//            if ([request.results isEqual:nil]) {
//                return;
//            }
//            if (error) {
//                NSLog(@"error %@", [error localizedDescription]);
//                return;
//            }
//
//
//                __block NSString* result = @"";
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                             for (VNRecognizedTextObservation* observations in request.results) {
//                                                       if ([observations isEqual:nil]) {
//                                                           continue;
//                                                       }
//
//                                                       VNRecognizedText* test = [[observations topCandidates:1] firstObject];
//
//                            //                           for (NSString* str in test) {
//                            //                               if (str) {
//                            //                                   result = [result stringByAppendingString:[NSString stringWithFormat:@"%@\n", str]];
//                            //                               }
//                            //                           }
//                                                       result = [result stringByAppendingString:[NSString stringWithFormat:@"%@\n", test.string]];
//                                                       //
//
//                                                   }
//                            NSLog(@"%@",result);
//                           });
//
//
//
//
//
//
//        }];
//        req.recognitionLevel =  VNRequestTextRecognitionLevelFast;
//        req.recognitionLanguages = @[@"rus", @"en"];
//        self.request = @[request, req];
//    } else {
//        // Fallback on earlier versions
//        self.request = @[request];
//    }
}

-(void)higthlightLetters:(VNRectangleObservation*)box{
    const NSInteger xCord = box.topLeft.x * self.imageView.frame.size.width;
    const NSInteger yCord = (1 - box.topLeft.y) * self.imageView.frame.size.height;
    const NSInteger width = (box.topRight.x - box.bottomLeft.x) * self.imageView.frame.size.width;
    const NSInteger height = (box.topLeft.y - box.bottomLeft.y) * self.imageView.frame.size.height;
    
    CALayer* outline = [[CALayer alloc] init];
    outline.frame = CGRectMake(xCord, yCord, width, height);
    outline.borderWidth = 1.0f;
    outline.borderColor = [UIColor lightGrayColor].CGColor;
    [self.imageView.layer addSublayer:outline];
}

-(void)higthlightWord:(VNTextObservation*)box{
    if ([box.characterBoxes isEqual:nil]) {
        return;
    }
    
    CGFloat maxX = 999999.0;
    CGFloat minX = 0.0;
    CGFloat maxY = 999999.0;
    CGFloat minY = 0;
    
    for (VNRectangleObservation* cha in box.characterBoxes) {
        
        if (cha.bottomLeft.x < maxX) {
            maxX = cha.bottomLeft.x;
        }
        if (cha.bottomRight.x > minX) {
            minX = cha.bottomRight.x;
        }
        if (cha.bottomRight.y < maxY) {
            maxY = cha.bottomRight.y;
        }
        if (cha.topRight.y > minY) {
            minY = cha.topRight.y;
        }
        
    }
    
    
    const NSInteger xCord = maxX * CGRectGetWidth(self.video.frame);
    const NSInteger yCord = (1 - minY) * CGRectGetHeight(self.video.frame);
    const NSInteger width = (minX - maxX) * CGRectGetWidth(self.video.frame);
    const NSInteger height = (minY - maxY) * CGRectGetHeight(self.video.frame);
    
    CALayer* outline = [[CALayer alloc] init];
    outline.frame = CGRectMake(xCord, yCord, width, height);
    outline.borderWidth = 2.0f;
    outline.borderColor = [UIColor darkGrayColor].CGColor;
    [self.imageView.layer addSublayer:outline];
}
#pragma mark - NSNotification
-(void)appMovedToForeground:(NSNotification*)notification{
    [self.session startRunning];
    [self focusOnPoint:CGPointMake(self.view.center.x, self.view.center.y)];
}
-(void)appMovedToBackground:(NSNotification*)notification{
    [self.session stopRunning];
}

@end
