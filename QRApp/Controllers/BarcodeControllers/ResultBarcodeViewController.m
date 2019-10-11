//
//  ResultBarcodeViewController.m
//  QRApp
//
//  Created by Сергей Семин on 25/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ResultBarcodeViewController.h"
#import "DataManager.h"
#import "BarcodePost+CoreDataClass.h"

@interface ResultBarcodeViewController () <UITextViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(strong, nonatomic)UIImagePickerController* imagePickerController;
@property(strong, nonatomic)UIImage* selectedImage;
@end

@implementation ResultBarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.deleteButton.hidden = YES;
    self.navigationController.navigationBar.topItem.title = @"Назад";
    self.imageView.layer.cornerRadius = 20;
    self.imageView.layer.masksToBounds = YES;
    
    self.textView.layer.cornerRadius = 15;
    self.textView.layer.masksToBounds = YES;
    
    self.popoverView.layer.cornerRadius = 15;
    self.popoverView.layer.masksToBounds = YES;
    self.popoverView.hidden = YES;
    self.popoverView.alpha = 0;
    
    self.textView.delegate = self;
    
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
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
           }
       }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    UIImageView* test = [[UIImageView alloc] initWithImage:self.transferImage];
    
//    NSLog(@"%@ %@", NSStringFromCGRect(self.imageView.frame), NSStringFromCGRect(self.imageView.bounds));
    
    CGFloat coordX = (CGRectGetWidth(self.imageView.frame) - CGRectGetWidth(self.imageView.frame)/2) - 15;
    CGFloat coordY = (CGRectGetHeight(self.imageView.frame) - CGRectGetHeight(self.imageView.frame)/2) - 10;
    
    
    [test setFrame:CGRectMake(coordX,
                              coordY,
                              CGRectGetWidth(self.imageView.frame)/2,
                              CGRectGetHeight(self.imageView.frame)/2)];
    [self.imageView addSubview:test];

    
    UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionSave:)];

    self.navigationItem.rightBarButtonItem = done;
}
#pragma mark UITextViewwDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Введите текст"]) {
        self.textView.text = @"";
    }
    return YES;
}

//- (void)textViewDidEndEditing:(UITextView *)textView{
//
//    if (![textView.text isEqualToString:@"Введите текст"] && textView.text.length > 0) {
//
//    }
//}
#pragma mark - NSNotificationCenter
-(void)keyboardWillAppear:(NSNotification*)notification{
    
    if (self.view.frame.origin.y == 0) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 667)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.topConstraint.constant = -80;
                    [self.view layoutIfNeeded];
                }];
            }
            if(result.height == 568)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.topConstraint.constant = -170;
                    [self.view layoutIfNeeded];
                }];
            }
        }
        
        
    }
}
-(void)keyboardWillDisappear:(NSNotification*)notification{
    [UIView animateWithDuration:0.25 animations:^{
        self.topConstraint.constant = 8;
        [self.view layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}

-(void)hiddenPopover{
    [UIView animateWithDuration:0.25 animations:^{
          self.popoverView.alpha = 0;
          self.textView.alpha = 1;
          self.descriptionLabel.alpha = 1;
      } completion:^(BOOL finished) {
          if (finished) {
              self.popoverView.hidden = YES;
          }
      }];
}

#pragma Mark - Actions
- (IBAction)actionHiddenPopover:(UIButton *)sender{
    [self hiddenPopover];
}
- (IBAction)actionDeletePhoto:(UIButton *)sender{
    self.imageView.image = nil;
    self.deleteButton.hidden = YES;
    self.textLabel.hidden = NO;
}
- (IBAction)actionAddPhoto:(UIButton *)sender{
    self.popoverView.hidden = NO;
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.popoverView.alpha = 1;
        self.textView.alpha = 0;
        self.descriptionLabel.alpha = 0;
    }];
}
-(void)actionSave:(UIBarButtonItem*)item{
    BarcodePost* post = [NSEntityDescription insertNewObjectForEntityForName:@"BarcodePost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    NSDate* now = [NSDate date];
    post.dateOfCreation = now;
    post.value = self.transferText;

     if (![self.textView.text isEqualToString:@"Введите текст"] && self.textView.text.length > 0) {
         post.note = self.textView.text;
     }
    
    if (self.transferImage) {
        UIImage* image = self.transferImage;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.barcode = imageData;
    }
    
    if (self.imageView.image) {
        NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
        post.picture = imageData;
    }
    
    [[DataManager sharedManager] saveContext];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionChooseGallery:(UIButton*)sender {
    //NSLog(@"ASdSADASDSADASDASDASDA");

    [self hiddenPopover];
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.allowsEditing = YES;
    if (sender.tag == 1) {
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    self.imagePickerController =vc;

    [self presentViewController:vc animated:YES completion:^{

    }];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
   // NSLog(@"%@", info);
    if (image) {
        self.imageView.image = image;
    }
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        self.deleteButton.hidden = NO;
        self.textLabel.hidden = YES;
    }];

    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
 
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
   
}
@end
