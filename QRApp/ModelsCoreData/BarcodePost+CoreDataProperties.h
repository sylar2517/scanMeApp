//
//  BarcodePost+CoreDataProperties.h
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "BarcodePost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BarcodePost (CoreDataProperties)

+ (NSFetchRequest<BarcodePost *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *barcode;
@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, retain) NSData *picture;
@property (nullable, nonatomic, copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
