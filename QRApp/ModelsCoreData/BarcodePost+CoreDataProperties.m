//
//  BarcodePost+CoreDataProperties.m
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "BarcodePost+CoreDataProperties.h"

@implementation BarcodePost (CoreDataProperties)

+ (NSFetchRequest<BarcodePost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BarcodePost"];
}

@dynamic barcode;
@dynamic dateOfCreation;
@dynamic note;
@dynamic picture;
@dynamic value;

@end
