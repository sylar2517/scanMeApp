//
//  CreationViewController.m
//  QRApp
//
//  Created by Сергей Семин on 01/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CreationViewController.h"
#import "QRCollectionViewCell.h"
#import "DataManager.h"
#import <CoreData/CoreData.h>

#import "QRPost+CoreDataClass.h"
#import "ResultViewController.h"
#import "ContactTableViewController.h"
#import "MakeSimpleQRViewController.h"


@interface CreationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, QRCollectionViewCellDelegate>

@property(strong, nonatomic)NSArray* history;
@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    
    NSArray* array = [[NSArray alloc] initWithObjects:self.simpleQR, self.customQR, nil];
    for (UIButton* object in array) {
        object.layer.cornerRadius = 10;
        object.layer.masksToBounds = YES;
    }
    self.createView.layer.cornerRadius = 10;
    self.createView.layer.masksToBounds = YES;
    
    self.collectionView.layer.cornerRadius = 20;
    self.collectionView.layer.masksToBounds = YES;
    
    self.simpleQRView.layer.cornerRadius = 10;
    self.simpleQRView.layer.masksToBounds = YES;
    self.customQRView.layer.cornerRadius = 10;
    self.customQRView.layer.masksToBounds = YES;
    self.simpleQRImageView.layer.cornerRadius = 10;
    self.simpleQRImageView.layer.masksToBounds = YES;
    self.customQRImageView.layer.cornerRadius = 10;
    self.customQRImageView.layer.masksToBounds = YES;
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.collectionView.contentInset = UIEdgeInsetsMake(50, 10, 50, 10);
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
    
        if(result.height == 568)
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.optionsConstraint.constant = 180;
                self.createLabel.hidden = YES;
            }];
        }
    }
    
    [self loadBase];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:NO];
    [self reload];
}
-(void)loadBase{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"QRPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    [request setEntity:description];
    [request setFetchBatchSize:20];
    NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
    [request setSortDescriptors:@[sdName]];
    NSError* reqestError = nil;
    NSArray* resultArray = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
    if (reqestError) {
        NSLog(@"%@", [reqestError localizedDescription]);
    }
    self.history = resultArray;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.history.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QRCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(QRCollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    QRPost* post = [self.history objectAtIndex:indexPath.row];
    cell.post = post;
    cell.delegate = self;
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yy HH:mm"];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@  %@", [df stringFromDate:post.dateOfCreation], post.type];
    cell.infoLabel.text = post.value;
    
    if ([post.type isEqualToString:@"Простой"]) {
        
        NSData* dataPicture = post.data;
        cell.imageCell.layer.magnificationFilter = kCAFilterNearest;
        cell.imageCell.image = [UIImage imageWithData:dataPicture];
    } else if ([post.type isEqualToString:@"contact"]) {
//        NSLog(@"AAA - %@", post.value);
//        cell.infoLabel.text = @"Контакт";
        cell.infoLabel.text = [self findNameAndLastName:post.value];
        
        NSData* dataPicture = post.data;
        cell.imageCell.image = [UIImage imageWithData:dataPicture];
    }  else if (![post.type isEqualToString:@"Простой"]) {
        NSData* dataPicture = post.data;
        cell.imageCell.image = [UIImage imageWithData:dataPicture];
    }
//другие типы

    
}
#pragma mark - Methods
-(NSString*)findNameAndLastName:(NSString*)string{
    NSArray* array = [string componentsSeparatedByString:@";"];
    
    for (NSString* str in array) {
        if ([str rangeOfString:@"N:"].location != NSNotFound) {
            NSString* test = [str substringFromIndex:[str rangeOfString:@"N:"].location + 2];
            return test;
        }
    }
    return @"Контакт";
}
-(UIImage*)makeQRFromText:(NSString*)text from:(UIImageView*)imageView{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = imageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = imageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                               scale:[UIScreen mainScreen].scale
                         orientation:UIImageOrientationUp];
    
}

-(void) reload{
    [self loadBase];
    [self.collectionView reloadData];
}

-(void)allertForDelete{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Отчистить все?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager] deleteQR];
        [self reload];
    }];
    
    
    [ac2 addAction:aa];
    [ac2 addAction:clear];
    
    [self presentViewController:ac2 animated:YES completion:nil];
}

#pragma mark - Actions
- (IBAction)actionDeleteAllQR:(UIButton *)sender {
    [self allertForDelete];
}

#pragma mark - QRCollectionViewCellDelegate

- (void)deleteCellForIndexPath:(QRPost*)post{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Удалить QR?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager].persistentContainer.viewContext deleteObject:post];
        [[DataManager sharedManager] saveContext];
        [self reload];
    }];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    
    [ac2 addAction:aa];
    [ac2 addAction:clear];
    
    [self presentViewController:ac2 animated:YES completion:nil];
}
//- (void)showCellForQR:(QRPost*)post{
//    ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
//    vc.postQR = post;
//    vc.fromCamera = NO;
//    [self presentViewController:vc animated:YES completion:nil];
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    QRPost* post = [self.history objectAtIndex:indexPath.row];

    if ([post.type isEqualToString:@"contact"]) {
        ContactTableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"testIDForPush"];
        tvc.meCard = post.value;
        tvc.imageData = post.data;
        [self.navigationController pushViewController:tvc animated:YES];
    } else {
        ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
        vc.postQR = post;
        vc.fromCamera = NO;
        CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version <= 12.9) {
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        [self presentViewController:vc animated:YES completion:nil];
    }
}
//#pragma mark -  MakeSimpleQRViewControllerDelegate
//- (void)qrCodeIsCreated:(MakeSimpleQRViewController*)controller{
//    [self reload];
//}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// // Get the new view controller using [segue destinationViewController].
// // Pass the selected object to the new view controller.
//     if ([segue.identifier isEqualToString:@"simpleQR"]) {
//         MakeSimpleQRViewController* vc = segue.destinationViewController;
//         vc.delegate = self;
//     }
// }

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (IBAction)test:(id)sender {
//    [self loadBase];
//    [self.collectionView reloadData];
//}
@end
