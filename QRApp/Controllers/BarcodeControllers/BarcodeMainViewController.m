//
//  BarcodeMainViewController.m
//  QRApp
//
//  Created by Сергей Семин on 25/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "BarcodeMainViewController.h"
#import "DataManager.h"

#import "HistoryCell.h"
#import "BarcodePost+CoreDataClass.h"

#import "ShowBarcodeViewController.h"

@interface BarcodeMainViewController ()
@property(assign, nonatomic)BOOL isEditing;
@end

@implementation BarcodeMainViewController
@synthesize fetchedResultsController = _fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIRefreshControl* refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshTableView) forControlEvents:(UIControlEventValueChanged)];
    self.refreshControl = refresh;
    self.isEditing = NO;
}
-(void)refreshTableView{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
- (NSFetchedResultsController*) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"BarcodePost" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setFetchBatchSize:20];
    NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
    [request setSortDescriptors:@[sdName]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSourse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"historyCell2";
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    //BarcodePost* post = nil;
    BarcodePost* post = [self.fetchedResultsController objectAtIndexPath:indexPath];

   
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.dateLabel.textColor = [UIColor whiteColor];
    cell.typeLabel.textColor = [UIColor whiteColor];
    
    cell.tintColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    cell.dateLabel.text = [df stringFromDate:post.dateOfCreation];
    cell.typeLabel.text = @"";
    
    if (post.note) {
        cell.nameLabel.text = post.note;
    } else {
        cell.nameLabel.text = post.value;
    }
    
    if (!post.picture) {
        cell.imageViewCell.image = [UIImage imageWithData:post.barcode];
    } else {
        cell.imageViewCell.image = [UIImage imageWithData:post.picture];
        cell.imageViewCell.contentMode = UIViewContentModeScaleAspectFill;
        //[self addImageFromCell:cell addInCenter:[UIImage imageWithData:post.picture]];
        [self addBarcodeToImage:[UIImage imageWithData:post.barcode] andFromImageView:cell.imageViewCell];
    }
    
}


-(void)addBarcodeToImage:(UIImage*)image andFromImageView:(UIImageView*)imageView{
    UIImageView* test = [[UIImageView alloc] initWithImage:image];
    
    
    CGFloat coordX = (CGRectGetWidth(imageView.frame) - CGRectGetWidth(imageView.frame)/2) - 3;
    CGFloat coordY = (CGRectGetHeight(imageView.frame) - CGRectGetHeight(imageView.frame)/2) - 2;
    
    [test setFrame:CGRectMake(coordX,
                              coordY,
                              CGRectGetWidth(imageView.frame)/2,
                              CGRectGetHeight(imageView.frame)/2)];
    [imageView addSubview:test];
}
- (void)addImageFromCell:(HistoryCell*)cell addInCenter:(UIImage*)image{
    
   
    CGSize size = cell.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0,
                                 0,
                                 size.width,
                                 size.height)];
    

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageViewCell.image = image;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Удалить";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BarcodePost* post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ShowBarcodeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowBarcodeViewController"];
    vc.post = post;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)deleteAll:(UIBarButtonItem *)sender {
    [self allertForDelete];
}

- (IBAction)actionEdit:(UIBarButtonItem *)sender {
    if (!self.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        self.isEditing = YES;
    } else {
        [self.tableView setEditing:NO animated:YES];

        self.isEditing = NO;
    }
}

-(void)allertForDelete{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Очистить созданные штрихкоды?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager] deleteBarcode];
        [self.tableView reloadData];
    }];
    
    [ac2 addAction:clear];
    [ac2 addAction:aa];
    
    [self presentViewController:ac2 animated:NO completion:nil];
}
@end
