//
//  BarcodeMainViewController.h
//  QRApp
//
//  Created by Сергей Семин on 25/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BarcodeMainViewController : CoreDataTableViewController

- (IBAction)deleteAll:(UIBarButtonItem *)sender;
- (IBAction)actionEdit:(UIBarButtonItem *)sender;


@end

NS_ASSUME_NONNULL_END
