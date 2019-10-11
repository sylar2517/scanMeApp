//
//  ParentTabViewController.h
//  QRApp
//
//  Created by Сергей Семин on 24/09/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ParentTabViewController;
@protocol ParentTabViewControllerDelegate
- (void)changeStartScroll:(BOOL)startScroll;

@end


@interface ParentTabViewController : UITabBarController
@property (nonatomic, weak) id <ParentTabViewControllerDelegate> delegateToChanged;
@end

NS_ASSUME_NONNULL_END
