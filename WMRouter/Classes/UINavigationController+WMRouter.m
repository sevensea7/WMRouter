//
//  UINavigationController+WMRouter.m
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import "UINavigationController+WMRouter.h"
#import "UIViewController+WMRouter.h"

@implementation UINavigationController (WMRouter)

+ (UINavigationController *)current {
	if (UIViewController.current && [UIViewController.current isKindOfClass:[UINavigationController class]]) {
		return (UINavigationController *)UIViewController.current;
	}
	if (UIViewController.current && [UIViewController.current isKindOfClass:[UITabBarController class]]) {
		UITabBarController *tbc = (UITabBarController *)UIViewController.current;
		UIViewController *vc = [tbc.viewControllers objectAtIndex:tbc.selectedIndex];
		if ([vc isKindOfClass:[UINavigationController class]]) {
			return (UINavigationController *)vc;
		}
		return vc.navigationController;
	}
	if (UIViewController.current && [UIViewController.current isKindOfClass:[UIViewController class]]) {
		return UIViewController.current.navigationController;
	}
	return nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[self pushViewController:viewController animated:animated];
	[CATransaction commit];
}

- (void)popViewController:(BOOL)animated completion:(void (^)(void))completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[self popViewControllerAnimated:animated];
	[CATransaction commit];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[self popToViewController:viewController animated:animated];
	[CATransaction commit];
}

- (void)popToViewControllerName:(NSString *)name animated:(BOOL)animated completion:(void (^)(void))completion {
	NSArray *vcs = self.viewControllers;
	vcs = [[vcs reverseObjectEnumerator] allObjects];
	for (UIViewController *vc in vcs) {
		NSString *className = NSStringFromClass([vc class]);
		if ([className isEqualToString:name]) {
			[CATransaction begin];
			[CATransaction setCompletionBlock:completion];
			[self popToViewController:vc animated:animated];
			[CATransaction commit];
			break;
		}
	}
}

- (void)popToRootViewController:(BOOL)animated completion:(void (^)(void))completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[self popToRootViewControllerAnimated:animated];
	[CATransaction commit];
}

@end
