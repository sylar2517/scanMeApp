//
//  QRPost+CoreDataProperties.m
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "QRPost+CoreDataProperties.h"

@implementation QRPost (CoreDataProperties)

+ (NSFetchRequest<QRPost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"QRPost"];
}

@dynamic data;
@dynamic dateOfCreation;
@dynamic type;
@dynamic value;

@end
