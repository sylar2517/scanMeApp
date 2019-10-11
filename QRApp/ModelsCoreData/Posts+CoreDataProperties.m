//
//  Posts+CoreDataProperties.m
//  QRApp
//
//  Created by Сергей Семин on 20/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "Posts+CoreDataProperties.h"

@implementation Posts (CoreDataProperties)

+ (NSFetchRequest<Posts *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Posts"];
}


@end
