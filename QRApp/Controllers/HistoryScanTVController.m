//
//  HistoryScanTVController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "HistoryScanTVController.h"
#import "QRViewController.h"
#import "HistoryCell.h"
#import "HistoryPost+CoreDataClass.h"
#import "ResultViewController.h"

#import "DataManager.h"

#import "ContactTableViewController.h"

#import "WebViewController.h"
#import "ScrollViewController.h"
#import "ResultTextVC.h"



typedef enum {
    Editing,
    ShowAll,
    ShowQR,
    ShowPDF,
    ShowBarcode,
    ShowText,
    ClearHistory
} UserCommitSettings;

NSString* const UserAddSideMenuNotificftion = @"UserAddSideMenuNotificftion";

@interface HistoryScanTVController () <ScrollViewControllerDelegate>


@property(strong, nonatomic)NSMutableArray* filterObject;
@property(assign, nonatomic)BOOL isFiltered;
@property(assign, nonatomic)BOOL isEditing;
@property(strong, nonatomic)NSMutableArray* tempObjectArray;
@property(strong, nonatomic)NSMutableArray* tempCellArray;


@property(strong, nonatomic)NSArray*withExport;
@property(strong, nonatomic)NSArray*withOutExport;

@property(assign, nonatomic)UserCommitSettings* settings;

@end

@implementation HistoryScanTVController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFiltered = NO;
    self.isEditing = NO;
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"Отмена"];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    UIBarButtonItem* export = [[UIBarButtonItem alloc] initWithTitle:@"Экспорт" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionExport:)];
    export.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:self action:nil];
    
    UIBarButtonItem* delete = [[UIBarButtonItem alloc] initWithTitle:@"Удалить" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionDelete:)];
    delete.tintColor = [UIColor redColor];
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionCancelEditing:)];
    cancel.tintColor = [UIColor whiteColor];
    
    self.withExport =@[cancel, flex,  export, flex, delete];
    self.withOutExport = @[cancel, flex, delete];
    
    self.toolbarItems = self.withExport;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.width, 0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    UIRefreshControl* refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshTableView) forControlEvents:(UIControlEventValueChanged)];
    self.refreshControl = refresh;
    self.isEditing = NO;
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sideMenuSettings: )
                                                 name:@"UserCommitSettingsDidChangeNotificftion"
                                               object:nil];

}


-(void)sideMenuSettings:(NSNotification*)note{

    UserCommitSettings settings = [[note.userInfo valueForKey:@"resultForHistory"] intValue];
    switch (settings) {
        case Editing:
            [self setEditingHistory];
            break;
        case ShowAll:
            [self showAll];
            break;
        case ShowQR:
            [self showQR];
            break;
        case ShowPDF:
            [self showPDF];
            break;
        case ShowBarcode:
            [self showBarcode];
            break;
        case ShowText:
            [self showText];
            break;
        case ClearHistory:
            [self clearHistory];
            break;
        default:
            break;
    }
}


-(void)refreshTableView{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationItem setTitle:@"История"];
    [self showAll];
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Side Bar methods
-(void)showAll{

    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    [self.navigationItem setTitle:@"История"];
    [self.tableView reloadData];
}
-(void)showQR{

    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type contains[cd] %@ OR type contains[cd] %@", @"QR", @"Контакт"];
    [[self.fetchedResultsController fetchRequest] setPredicate:predicate];
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    [self.navigationItem setTitle:@"История (QR)"];
    [self.tableView reloadData];

}

-(void)showPDF{
    
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type contains[cd] %@", @"PDF"];
    [[self.fetchedResultsController fetchRequest] setPredicate:predicate];
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    [self.navigationItem setTitle:@"История (PDF)"];
    [self.tableView reloadData];
    
}
-(void)showBarcode{
    
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type contains[cd] %@", @"Штрихкод"];
    [[self.fetchedResultsController fetchRequest] setPredicate:predicate];
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    [self.navigationItem setTitle:@"Штрихкоды"];
    [self.tableView reloadData];
    
}
-(void)showText{
    
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type contains[cd] %@", @"Text"];
    [[self.fetchedResultsController fetchRequest] setPredicate:predicate];
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    [self.navigationItem setTitle:@"История (Тексты)"];
    [self.tableView reloadData];
    
}

- (NSFetchedResultsController*) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:self.managedObjectContext];
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
}

#pragma mark - ScrollViewControllerDelegate

- (void) changeScreen:(BOOL)stopSession{
    
    if (stopSession) {
        self.navigationController.navigationBarHidden = NO;
        [self.tabBarController.tabBar setHidden:NO];
        [self.tableView reloadData];
    }
}



#pragma mark - UITableViewDataSourse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"historyCell";
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    HistoryPost* post = nil;
    if (self.filterObject) {
        post = [self.filterObject objectAtIndex:indexPath.row];
    } else {
        post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
   
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.dateLabel.textColor = [UIColor whiteColor];
    cell.typeLabel.textColor = [UIColor whiteColor];
    
    if (self.tempObjectArray.count > 0) {
        for (HistoryPost* postAdd in self.tempObjectArray) {
            if ([postAdd isEqual:post]) {
                cell.nameLabel.textColor = [UIColor blackColor];
                cell.dateLabel.textColor = [UIColor blackColor];
                cell.typeLabel.textColor = [UIColor blackColor];
            }
        }
    }
    
    cell.tintColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    cell.dateLabel.text = [df stringFromDate:post.dateOfCreation];


    
    if ([post.type isEqualToString:@"QR"]) {
        if ([post.value rangeOfString:@"MECARD:"].location != NSNotFound) {
            if ([self findNameAndLastName:post.value]) {
                cell.nameLabel.text = [NSString stringWithFormat:@"%@", [self findNameAndLastName:post.value]];
                cell.typeLabel.text = @"Контакт";
            } else {
                cell.nameLabel.text = @"Контакт";
                cell.typeLabel.text = @"QR";
            }

        } else {
            cell.nameLabel.text = post.value;
            cell.typeLabel.text = @"QR";
        }
        
        cell.imageViewCell.layer.magnificationFilter = kCAFilterNearest;
        cell.imageViewCell.image = [UIImage imageWithData:post.picture];

    } else if ([post.type isEqualToString:@"PDF"]){
        cell.nameLabel.text = post.value;
        cell.imageViewCell.image = [UIImage imageNamed:@"pdf"];
        cell.imageViewCell.backgroundColor = [UIColor redColor];
        cell.typeLabel.text = @"PDF";
    } else if ([post.type isEqualToString:@"Штрихкод"]){
        cell.nameLabel.text = post.value;
        cell.imageViewCell.image = [UIImage imageWithData:post.picture];
        cell.imageViewCell.backgroundColor = [UIColor whiteColor];
        cell.typeLabel.text = @"Штрихкод";
    }  else if ([post.type isEqualToString:@"Text"]){
        cell.nameLabel.text = post.value;
        cell.imageViewCell.image = [UIImage imageNamed:@"text"];
        cell.imageViewCell.backgroundColor = [UIColor whiteColor];
        cell.typeLabel.text = @"Текст";
    }
    
    
    
}

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
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    if (!self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        HistoryPost* post = nil;
        if (self.filterObject) {
            
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        if ([post.type isEqualToString:@"QR"]) {
            if ([post.value rangeOfString:@"MECARD:"].location != NSNotFound) {
                ContactTableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"testIDForPush"];
                tvc.meCard = post.value;
                tvc.imageData = post.picture;
                [self.navigationController pushViewController:tvc animated:YES];
            } else {
                ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
                    vc.post = post;
                    vc.fromCamera = NO;
                    vc.isBarcode = NO;
                    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
                    if (version <= 12.9) {
                        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    }
                    [self presentViewController:vc animated:YES completion:nil];
            }
            
//            ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
//            vc.post = post;
//            vc.fromCamera = NO;
//            vc.delegate = self;
//            [self presentViewController:vc animated:YES completion:nil];
        } else if ([post.type isEqualToString:@"PDF"]) {
            WebViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
            vc.post = post;
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }  else if ([post.type isEqualToString:@"Штрихкод"]) {
            ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
            vc.post = post;
            vc.fromCamera = NO;
            vc.isBarcode = YES;
            
            
            CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version <= 12.9) {
                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            }
            
            
//            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        } else if ([post.type isEqualToString:@"Text"]) {
//            [self.hsDelegate historyScanTVControllerPresentResultBarcode:post];
            ResultTextVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVCText"];
            vc.fromCamera = NO;
            vc.text = post.value;
            CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version <= 12.9) {
                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            }
            
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    } else {
        
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        [self.tempObjectArray addObject:post];
        
        if(self.tempObjectArray.count > 1){
            
            self.navigationItem.leftBarButtonItems = self.withOutExport;
    
        } else {
            
            self.navigationItem.leftBarButtonItems = self.withExport;
            
        }
        
        HistoryCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.tempCellArray addObject:cell];
        
        cell.nameLabel.textColor = [UIColor blackColor];
        cell.dateLabel.textColor = [UIColor blackColor];
        cell.typeLabel.textColor = [UIColor blackColor];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isEditing) {
        return;
    } else {
       
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        [self.tempObjectArray removeObject:post];
        
        if(self.tempObjectArray.count > 1){
            self.navigationItem.leftBarButtonItems = self.withOutExport;
   
        } else {
            self.navigationItem.leftBarButtonItems = self.withExport;

        }
        
        HistoryCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.tempCellArray removeObject:cell];
        
        cell.nameLabel.textColor = [UIColor whiteColor];
        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.typeLabel.textColor = [UIColor whiteColor];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isFiltered) {
        self.isFiltered = NO;
        //NSLog(@"%lu", (unsigned long)self.filterObject.count);
        return self.filterObject.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 3;
}

#pragma mark -  UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.width, 0);
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    self.filterObject = nil;
    
    if (self.isEditing) {
        self.isEditing = !self.isEditing;
    }
    
    [self.tempObjectArray removeAllObjects];
    
    [self.tempCellArray removeAllObjects];
    
    
    self.navigationItem.leftBarButtonItems = nil;
    [self.tableView setEditing:self.isEditing animated:YES];
    [self.tableView reloadData];
    

}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    self.isFiltered = YES;
    if (searchText.length == 0) {
        self.isFiltered = NO;
        self.filterObject = nil;
        searchBar.showsCancelButton = NO;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.width, 0);
        [self.tableView reloadData];
    } else {
        self.isFiltered = YES;
        searchBar.showsCancelButton = YES;
        self.filterObject = [NSMutableArray array];
        [self filterContentForSearchText:searchText];
        
        if (self.tempObjectArray.count > 0) {

            [self.tempObjectArray removeAllObjects];
            [self.tableView reloadData];
        }
    }

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.width, 0);
    [searchBar resignFirstResponder];
}
#pragma mark -  Private Methods
- (void)filterContentForSearchText:(NSString*)searchText
{

    
    if (searchText !=nil)
    {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"value contains[cd] %@", searchText];
        //        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:description];
        [request setFetchBatchSize:20];
        [request setPredicate:predicate];
        NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
        [request setSortDescriptors:@[sdName]];
        NSError* reqestError = nil;
        NSArray* resultArray = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
        if (reqestError) {
            NSLog(@"%@", [reqestError localizedDescription]);
            self.filterObject = nil;
        } else {
            self.filterObject = [NSMutableArray arrayWithArray:resultArray];
        }
        
        
    } else {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"All"];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        self.filterObject = nil;
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.tableView reloadData];

    
}


-(void)setEditingHistory{
    self.isEditing = !self.isEditing;
    if (self.isEditing == NO) {
        
        [self.tempObjectArray removeAllObjects];
        [self.tempCellArray removeAllObjects];
        self.navigationItem.leftBarButtonItems = nil;
        [self.tableView reloadData];
        [self.navigationItem setTitle:@"История"];
    } else {
        
        self.navigationItem.leftBarButtonItems = self.withExport;
        self.tempObjectArray = [NSMutableArray array];
        self.tempCellArray = [NSMutableArray array];
    }
    [self.tableView setEditing:self.isEditing animated:YES];

}
-(void)clearHistory{
    [self allertForDelete];
}


-(void)allertForDelete{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Очистить историю?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager] deleteHistoryScan];
        [self.tableView reloadData];
    }];
    
    [ac2 addAction:clear];
    [ac2 addAction:aa];
    
    [self presentViewController:ac2 animated:NO completion:nil];
}
#pragma mark -  Actions UIBarButtonItem
-(void)actionExport:(UIBarButtonItem*)sender{
    
    NSMutableArray* temp = [NSMutableArray array];
    NSArray* array = nil;
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    if (self.tempObjectArray.count != 0 && self.tempObjectArray) {
        for (HistoryPost* post in self.tempObjectArray) {
            NSString* test = post.value;
            NSString* string = [NSString stringWithFormat:@"text -%@\ndate of creation -  %@", test, [df stringFromDate:post.dateOfCreation]];
            [temp addObject:string];
        }
        
        array = [NSArray arrayWithArray:temp];
//        NSLog(@"%@", array);
        UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        //avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [self presentViewController:avc animated:YES completion:nil];

    }
}
-(void)actionDelete:(UIBarButtonItem*)sender{
    
    if (self.tempObjectArray.count != 0 && self.tempObjectArray) {

        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
        self.searchBar.text = nil;
        self.filterObject = nil;
        
        if (self.isEditing) {
            self.isEditing = !self.isEditing;
        }
        
        
        NSArray* array = [NSArray arrayWithArray:self.tempObjectArray];
        [self.tempObjectArray removeAllObjects];
        [self.tempCellArray removeAllObjects];
        
        self.navigationItem.leftBarButtonItems = nil;

        [self.tableView setEditing:self.isEditing animated:NO];
        [self.tableView reloadData];
        
        
        for (HistoryPost* post in array) {
            [[DataManager sharedManager].persistentContainer.viewContext deleteObject:post];
        }
        [[DataManager sharedManager] saveContext];
       
        [self.tableView reloadData];
        
    }
}

-(void)actionCancelEditing:(UIBarButtonItem*)sender{
    self.isEditing = !self.isEditing;
    [self.tempObjectArray removeAllObjects];
    
    [self.tempCellArray removeAllObjects];
    self.navigationItem.leftBarButtonItems = nil;
    [self.navigationItem setTitle:@"История"];
    [self.tableView setEditing:self.isEditing animated:YES];
    [self.tableView reloadData];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"showContainerSideController"]) {
//        SideBarViewController* vc = segue.destinationViewController;
//        vc.historyVC = self;
//    }
}
- (IBAction)actionSideMenu:(UIButton *)sender{
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:@(2) forKey:@"resultForHistory"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserAddSideMenuNotificftion
                                                        object:nil
                                                      userInfo:dict];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
            });
}


@end
