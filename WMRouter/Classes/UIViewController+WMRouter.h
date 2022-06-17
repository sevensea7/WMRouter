//
//  UIViewController+WMRouter.h
//  WMRouter
//
//  Created by 七海 on 2021/7/25.
//  Copyright © 2021 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WMRouter)

/**正向路由传参*/
@property (nonatomic, strong) NSDictionary *wm_forwardParams;
/**反向路由传参*/
@property (nonatomic, strong) NSDictionary *wm_backwardParams;

/**寻找最上层控制器*/
+ (UIViewController *)current;

/**
   通过类名判断是否存在该控制器

   @param vcName 控制器名
   @return 是否存在
 */
+ (BOOL)isExist:(NSString *)vcName;

/**
   通过类名初始化

   @param vcName 控制器名
   @return 控制器
 */
+ (UIViewController *)controllerWithName:(NSString *)vcName;

@end
