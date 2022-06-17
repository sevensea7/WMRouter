//
//  UINavigationController+WMRouter.h
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import <UIKit/UIKit.h>

/**导航器便利工具*/
@interface UINavigationController (WMRouter)

/**寻找最上层导航器*/
+ (UINavigationController *)current;

/**
   跳转控制器

   @param viewController 目标控制器
   @param animated 是否显示动画
   @param completion 完成回调
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
   返回

   @param animated 是否显示动画
   @param completion 完成回调
 */
- (void)popViewController:(BOOL)animated completion:(void (^)(void))completion;


/**
   返回到指定控制器

   @param viewController 指定控制器
   @param animated 是否显示动画
   @param completion 完成回调
 */
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
   通过控制器类名返回

   @param name 指定控制器名
   @param animated 是否显示动画
   @param completion 完成回调
 */
- (void)popToViewControllerName:(NSString *)name animated:(BOOL)animated completion:(void (^)(void))completion;

/**
   返回到根控制器

   @param animated 是否显示动画
   @param completion 完成回调
 */
- (void)popToRootViewController:(BOOL)animated completion:(void (^)(void))completion;

@end

