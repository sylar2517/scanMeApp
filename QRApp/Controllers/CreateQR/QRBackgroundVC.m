//
//  QRBackgroundVC.m
//  QRApp
//
//  Created by Сергей Семин on 29/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRBackgroundVC.h"
#import "QRFromImageTVC.h"
#import "QRPost+CoreDataClass.h"
#import "DataManager.h"

@interface QRBackgroundVC () <UITextFieldDelegate, QRFromImageTVCDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(strong, nonatomic)UIColor* color;
@property(strong, nonatomic)UIImagePickerController* imagePickerController;
@property(strong, nonatomic)UIImage* selectedImage;
@end

@implementation QRBackgroundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textLabel.hidden = YES;
    self.textField.hidden = YES;
    self.imageView.image = self.transferImage;
    self.navigationController.navigationBar.topItem.title = @"Назад";
    self.changeColor.hidden = YES;
    self.photoLabel.hidden = YES;
    self.photoButton.hidden = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
       {
           CGSize result = [[UIScreen mainScreen] bounds].size;
           if(result.height == 667)
           {
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
           }
           if(result.height == 568)
           {
               self.topConstraint.constant = 0;
               self.buttonConstraint.constant = 40;
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
           }
       }
    
    self.textField.delegate = self;
    
    UIBarButtonItem* rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = rigthItem;
    
    
    self.popoverView.layer.cornerRadius = 15;
    self.popoverView.layer.masksToBounds = YES;
    self.popoverView.hidden = YES;
    self.popoverView.alpha = 0;
}

-(void)hiddenPopover{
    [UIView animateWithDuration:0.25 animations:^{
          self.popoverView.alpha = 0;
      } completion:^(BOOL finished) {
          if (finished) {
              self.popoverView.hidden = YES;
          }
      }];
}

#pragma mark - QRFromImageTVC
- (void)getBackgroundColor:(UIColor*)color{
    self.imageView.backgroundColor = color;
    self.color = color;
    self.navigationItem.title = @"";
    self.imageView.image = [self imageByCombiningImageForBackground:self.transferImage];
}
#pragma mark - ACTIONS
- (IBAction)actionAddPhoto:(UIButton *)sender{
    self.popoverView.hidden = NO;
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.popoverView.alpha = 1;
    }];
}

-(void)actionSave:(id)sender{
    
    if (self.segmentControl.selectedSegmentIndex == 1) {
       UIBezierPath *maskPath = [UIBezierPath
             bezierPathWithRoundedRect:self.textLabel.bounds
             byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
             cornerRadii:CGSizeMake(0, 0)
         ];

        CAShapeLayer *maskLayer = [CAShapeLayer layer];

        maskLayer.path = maskPath.CGPath;

        self.textLabel.layer.mask = maskLayer;
        self.imageView.image = [self imageByCombiningImageForBackground:self.transferImage];
    }
    
    QRPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"QRPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    NSDate* now = [NSDate date];
    post.dateOfCreation = now;
    post.type = self.typeQR;
    post.value = self.titleText;

    UIImage* image = self.imageView.image;

   NSData *imageData = UIImagePNGRepresentation(image);
   post.data = imageData;

   [[DataManager sharedManager] saveContext];

   [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionAddBackgroundColor:(UIButton *)sender{
    QRFromImageTVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateQRfromImage"];
    vc.forGetBacgroundColor = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)actionChangeSegmentControl:(UISegmentedControl *)sender {
    
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    self.photoLabel.text = @"Нажмите, чтобы добавить фото";
    
    if (sender.selectedSegmentIndex == 0) {
        self.heightConstraint.constant = 240;
        self.textLabel.hidden = YES;
        self.textField.hidden = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = self.transferImage;
        self.changeColor.hidden = YES;
        self.photoLabel.hidden = YES;
        self.photoButton.hidden = YES;
        
    } else if (sender.selectedSegmentIndex == 1){
        self.heightConstraint.constant = 300;
        self.textLabel.hidden = NO;
        self.textField.hidden = NO;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.image = [self addImageOnCenter:self.transferImage];
        self.changeColor.hidden = NO;
        self.photoLabel.hidden = YES;
        self.photoButton.hidden = YES;
        if (self.color) {
            self.imageView.backgroundColor = self.color;
        } else {
            self.imageView.backgroundColor = [UIColor whiteColor];
        }
        
        UIBezierPath *maskPath = [UIBezierPath
            bezierPathWithRoundedRect:self.textLabel.bounds
            byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
            cornerRadii:CGSizeMake(14, 14)
        ];

        CAShapeLayer *maskLayer = [CAShapeLayer layer];

        maskLayer.path = maskPath.CGPath;

        self.textLabel.layer.mask = maskLayer;
        
    } else {
        self.photoLabel.hidden = NO;
        self.photoButton.hidden = NO;
        self.heightConstraint.constant = 400;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.textLabel.hidden = YES;
        self.textField.hidden = YES;
        self.changeColor.hidden = YES;
        self.imageView.backgroundColor = [UIColor grayColor];
        
        self.imageView.image = [self addImageOnCenter:self.transferImage];
        
    }
     
    
}

- (UIImage*)addImageOnCenter:(UIImage*)image{
    
   
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0,
                                 0,
                                 size.width,
                                 size.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - NSNotificationCenter
-(void)keyboardWillAppear:(NSNotification*)notification{
    
    if (self.view.frame.origin.y == 0) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 667)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.topConstraint.constant = -35;
                    [self.view layoutIfNeeded];
                }];
            }
            if(result.height == 568)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.topConstraint.constant = -135;
                    [self.view layoutIfNeeded];
                }];
            }
        }
        
        
    }
}
-(void)keyboardWillDisappear:(NSNotification*)notification{
    [UIView animateWithDuration:0.25 animations:^{
       
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
       
            if(result.height == 568)
            {
                self.topConstraint.constant = 0;
                [self.view layoutIfNeeded];
            } else {
                self.topConstraint.constant = 12;
                [self.view layoutIfNeeded];
            }
        }
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}
#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString* str = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    self.textLabel.text = str;
    
    return YES;
}
- (IBAction)actionHiddenPopover:(UIButton *)sender{
    [self hiddenPopover];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    self.imageView.image = [self imageByCombiningImage:image withImage:self.transferImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.photoLabel.text = @"Нажмите, чтобы изменить фото";
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
 
    [picker dismissViewControllerAnimated:YES completion:^{
        self.photoLabel.text = @"Нажмите, чтобы добавить фото";
    }];
   
}

- (IBAction)actionChooseGallery:(UIButton*)sender {
    //NSLog(@"ASdSADASDSADASDASDASDA");

    [self hiddenPopover];
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    //vc.allowsEditing = YES;
    if (sender.tag == 1) {
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    self.imagePickerController =vc;

    [self presentViewController:vc animated:YES completion:^{

    }];
}
- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize size = self.imageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    

    CGRect rect2 = CGRectMake(CGRectGetWidth(self.imageView.frame)/2 - 100,
                              CGRectGetHeight(self.imageView.frame)/2 - 100,
                              200,
                              200);
    
    [secondImage drawInRect:rect2];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)imageByCombiningImageForBackground:(UIImage*)firstImage{
    UIImage *image = nil;
    
    CGSize size = self.imageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIView* view = [[UIView alloc] initWithFrame:self.imageView.frame];
    if (self.color) {
       view.backgroundColor = self.color;
   } else {
       view.backgroundColor = [UIColor whiteColor];
   }
    UIImage* test = [self imageWithView:view];
    [test drawInRect:CGRectMake(0,0,size.width, size.height)];
    

    
    

    CGRect rect2 = CGRectMake(CGRectGetWidth(self.imageView.frame)/2 - 100,
                              CGRectGetHeight(self.imageView.frame)/2 - 100,
                              200,
                              200);
    
    [firstImage drawInRect:rect2];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage* label = [self grabImage];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0,0,size.width, size.height)];
    
    [label drawInRect:CGRectMake(0,
                                 size.height - self.textLabel.frame.size.height,
                                 self.textLabel.frame.size.width,
                                 self.textLabel.frame.size.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *)grabImage {
    // Create a "canvas" (image context) to draw in.
    UIGraphicsBeginImageContextWithOptions(self.textLabel.bounds.size, false, 0.0);  // high res
    // Make the CALayer to draw in our "canvas".
    [self.textLabel.layer renderInContext: UIGraphicsGetCurrentContext()];

    // Fetch an UIImage of our "canvas".
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    // Stop the "canvas" from accepting any input.
    UIGraphicsEndImageContext();

    // Return the image.
    return image;
}
- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}
@end
