//
//  CreateBarcodeViewController.m
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CreateBarcodeViewController.h"
#import "ResultBarcodeViewController.h"
@import ZXingObjC;

@interface CreateBarcodeViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSArray* sourseArray;
@property (assign, nonatomic) NSInteger seletedRow;
@end

@implementation CreateBarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickerView.layer.cornerRadius = 10;
    self.pickerView.layer.masksToBounds = YES;
    
    self.textView.layer.cornerRadius = 10;
    self.textView.layer.masksToBounds = YES;
    
    self.doneButton.layer.cornerRadius = 15;
    self.doneButton.layer.masksToBounds = YES;
    self.doneButton.hidden = YES;
    self.doneButton.alpha = 0.0;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationItem setLargeTitleDisplayMode:(UINavigationItemLargeTitleDisplayModeNever)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.textView.delegate = self;
    
//    self.sourseArray = @[@"Codabar",   //---- 0
//                        @"Code39",//+++       1
//                        @"Code93",//+++       2
//                        @"Code128",//+++      3
//                        @"Ean8",//+++         4
//                        @"Ean13",//+++        5
//                        @"ITF",//----         6
//                        @"RSS14",//----       7
//                        @"RSSExpanded",//---- 8
//                        @"UPCA",//+++         9
//                        @"UPCE"];//+++        10
    
    self.sourseArray = @[@"Code39",
                         @"Code93",
                         @"Code128",
                         @"Ean8",
                         @"Ean13",
                         @"UPCA",
                         @"UPCE"];
    
    [self.pickerView selectRow:2 inComponent:0 animated:YES];

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
 
    self.seletedRow = 2517;
    self.textView.keyboardType = UIKeyboardTypeASCIICapable;
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



#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.sourseArray count];
}
#pragma mark UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return (NSString*)[self.sourseArray objectAtIndex:row];
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.sourseArray objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.seletedRow = row;
//    NSLog(@"%ld", (long)row);
    self.textView.text = @"";
    if (row == 3 || row == 4 || row == 5 || row == 6){
        self.textView.keyboardType = UIKeyboardTypeNumberPad;
    } else if (row <= 3) {
        self.textView.keyboardType = UIKeyboardTypeASCIICapable;
    }
}
#pragma mark UITextViewwDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Введите текст"]) {
        self.textView.text = @"";
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if (![textView.text isEqualToString:@"Введите текст"] && textView.text.length > 0) {
            [self genetatedBarcode];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    

    NSString* str = [[textView text] stringByReplacingCharactersInRange:range withString:text];
    //NSLog(@"%@", str);
    if (str.length > 0) {
        self.doneButton.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.doneButton.alpha = 1;
            [self.view layoutIfNeeded];
        }];

    } else {
        self.doneButton.hidden = YES;
        self.doneButton.alpha = 0;
    }
    
    if (self.seletedRow == 2517 || self.seletedRow <= 2) {
        
        if ([[str componentsSeparatedByString:@"'"] count] > 1){
            return NO;
        }
        NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@"‘€£абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ₽•\""];
    
        return [self checkString:str inCharacterSet:set andMaxStrLenght:80];
        
    } else if (self.seletedRow == 3) {
     
        NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return [self checkString:str inCharacterSet:set andMaxStrLenght:7];
        
    } else if (self.seletedRow == 4) {
        
        NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return [self checkString:str inCharacterSet:set andMaxStrLenght:12];
        
    }   else if (self.seletedRow == 5) {
        
        NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return [self checkString:str inCharacterSet:set andMaxStrLenght:11];
        
    } else if (self.seletedRow == 6) {
        
//        NSString* newStr = [str substringToIndex:1];
//        if (newStr.length != 0) {
//            if (![str isEqualToString:@"2"] || ![str isEqualToString:@"0"]) {
//                return NO;
//            }
//        }
        
        
        NSCharacterSet* set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return [self checkString:str inCharacterSet:set andMaxStrLenght:7];
        
    }
    
    return YES;
}


#pragma mark - Actions
- (IBAction)actionDone:(UIButton *)sender {
    [self genetatedBarcode];
}

- (IBAction)actionGetInfo:(UIButton *)sender{
    NSString* str = @"https://www.tec-it.com/en/support/knowbase/barcode-overview/linear/Default.aspx";
    NSURL* URL = [NSURL URLWithString:str];
    [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
}

#pragma mark - Methods
-(void)genetatedBarcode{
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    
    ZXBarcodeFormat format;
    if (self.seletedRow == 2517 || self.seletedRow == 2) {
        format = kBarcodeFormatCode128;
    }
    
    else if (self.seletedRow == 0) {
        format = kBarcodeFormatCode39;
    }
    else if (self.seletedRow == 1) {
        format = kBarcodeFormatCode93;
    }
    
    else if (self.seletedRow == 3) {
        format = kBarcodeFormatEan8;
        if (self.textView.text.length < 7) {
            NSString* messege = @"Допустимая длинна - 7 цифр";
            [self showAllertWithMessege:messege];
            return;
        }
    }
    
    else if (self.seletedRow == 4) {
        format = kBarcodeFormatEan13;
        
        if (self.textView.text.length < 12) {
            NSString* messege = @"Допустимая длинна - 12 цифр";
            [self showAllertWithMessege:messege];
            return;
        }
    }
    
    else if (self.seletedRow == 5) {
        format = kBarcodeFormatUPCA;
        if (self.textView.text.length < 11) {
            NSString* messege = @"Допустимая длинна - 11 цифр";
            [self showAllertWithMessege:messege];
            return;
        }
    }
    else if (self.seletedRow == 6) {
        format = kBarcodeFormatUPCE;
        if (self.textView.text.length < 7) {
            NSString* messege = @"Допустимая длинна - 7 цифр";
            [self showAllertWithMessege:messege];
            return;
        }
    }
    else {
        format = kBarcodeFormatCode128;
    }
    
    ZXBitMatrix* result = [writer encode:self.textView.text
                                  format:format
                                   width:500
                                  height:300
                                   error:&error];
    if (result) {
        CGImageRef image = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);
        CGImageRelease(image);
        
        self.imageView.image = [UIImage imageWithCGImage:image];
        self.pickerView.hidden = YES;
        self.imageView.hidden = NO;
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }
        self.titleLabel.text = @"Штрихкод:";
        
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionCancel:)];
        cancel.tintColor = [UIColor redColor];
        UIBarButtonItem* move = [[UIBarButtonItem alloc] initWithTitle:@"Далее" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionGo:)];
        self.navigationItem.rightBarButtonItems = @[move, cancel];

    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"AAAA %@", errorMessage);
    }
}

-(BOOL)checkString:(NSString*)str inCharacterSet:(NSCharacterSet* )set andMaxStrLenght:(NSInteger)lenght{
    if (str.length > lenght) {
        NSString* messege = @"Превышенна максимально допустимая длинна";
        [self showAllertWithMessege:messege];
        return NO;
    }
    if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
        NSString* messege = @"Текст не должен содержит недопустимые символы";
        [self showAllertWithMessege:messege];
        return NO;
    }
    return YES;
}

-(void)showAllertWithMessege:(NSString*)messege{
    UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Ошибка" message:messege preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        //        self.textView.text = @"";
    }];
    [ac addAction:aa];
    
    [self presentViewController:ac animated:YES completion:nil];
}
#pragma mark UIBarButtonItem

-(void)actionCancel:(UIBarButtonItem*)sender{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    self.pickerView.hidden = NO;
    self.imageView.hidden = YES;
    self.navigationItem.rightBarButtonItems = nil;
    self.titleLabel.text = @"Выберете тип:";
    self.textView.text = @"";
}

-(void)actionGo:(UIBarButtonItem*)sender{
 
    if (self.imageView.image) {
        
        ResultBarcodeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultBarcodeViewController"];
        vc.transferImage = self.imageView.image;
        vc.transferText = self.textView.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
@end
