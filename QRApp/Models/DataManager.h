//
//  DataManager.h
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@class AVCaptureSession;
@interface DataManager : NSObject
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) AVCaptureSession* currentSession;
+ (DataManager*) sharedManager;

- (void)saveContext;
//-(void) deleteHistory;
-(void)deleteHistoryScan;
-(void)deleteQR;
-(void) deleteAll;
-(void)deleteBarcode;
-(void)startSession;

@end

NS_ASSUME_NONNULL_END
