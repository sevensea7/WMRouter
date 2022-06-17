//
//  UIViewController+WMRouter.m
//  WMRouter
//
//  Created by 七海 on 2021/7/25.
//  Copyright © 2021 . All rights reserved.
//

#import "UIViewController+WMRouter.h"
#import <objc/runtime.h>

static NSString * const kWMVCForwardParamKey = @"kWMVCForwardParamKey";
static NSString * const kWMVCBackwardParamKey = @"kWMVCBackwardParamKey";

@implementation UIViewController (WMRouter)

#pragma mark - getter

- (NSDictionary *)wm_forwardParams {
	return objc_getAssociatedObject(self, &kWMVCForwardParamKey);
}

- (NSDictionary *)wm_backwardParams {
	return objc_getAssociatedObject(self, &kWMVCBackwardParamKey);
}

#pragma mark - setter

- (void)setWm_forwardParams:(NSDictionary *)wm_forwardParams {
	if(!wm_forwardParams || !wm_forwardParams.allKeys.count) {
		return;
	}
	objc_setAssociatedObject(self, &kWMVCForwardParamKey, wm_forwardParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	for (NSString *key in wm_forwardParams.allKeys) {
		if([self isPropertyExists:key]) {
			[self setValue:wm_forwardParams[key] forKey:key];
		}
	}
}

- (void)setWm_backwardParams:(NSDictionary *)wm_backwardParams {
	if(!wm_backwardParams || !wm_backwardParams.allKeys.count) {
		return;
	}
	objc_setAssociatedObject(self, &kWMVCBackwardParamKey, wm_backwardParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	for (NSString *key in wm_backwardParams.allKeys) {
		if([self isPropertyExists:key]) {
			[self setValue:wm_backwardParams[key] forKey:key];
		}
	}
}

#pragma mark - class method
+ (UIViewController *)current {
	UIViewController *topVC = self.currentWindow.rootViewController;
    UIViewController *currentVC = [self currentFrom:topVC];
    return currentVC;
}

+ (UIViewController *)currentFrom:(UIViewController *)vc {
    UIViewController *currentVC;
    if ([vc presentedViewController]) {
        UIViewController *rootVC = [vc presentedViewController];
        currentVC = [self currentFrom:rootVC];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UIViewController *rootVC = [(UITabBarController *)vc selectedViewController];
        currentVC = [self currentFrom:rootVC];
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UIViewController *rootVC = [(UINavigationController *)vc visibleViewController];
        currentVC = [self currentFrom:rootVC];
    } else {
        currentVC = vc;
    }
    return currentVC;
}

+ (UIWindow *)currentWindow {
	UIWindow *window = [UIApplication sharedApplication].delegate.window;
	if (window.windowLevel != UIWindowLevelNormal) {
		NSArray *windows = [UIApplication sharedApplication].windows;
		for (UIWindow *target in windows) {
			if (target.windowLevel == UIWindowLevelNormal) {
				window = target;
				break;
			}
		}
	}
	return window;
}


+ (BOOL)isExist:(NSString *)vcName {
	const char *className = [vcName cStringUsingEncoding:NSASCIIStringEncoding];
	Class newClass = objc_getClass(className);
	if (!newClass) {
		NSAssert(NO,@"路由错误：类\"%@\"不存在！",vcName);
		return NO;
	}
	if (![[newClass new] isKindOfClass:[UIViewController class]]) {
		NSAssert(NO,@"路由错误：控制器\"%@\"不存在！",vcName);
		return NO;
	}
	return YES;
}

+ (UIViewController *)controllerWithName:(NSString *)vcName {
    Class newClass = NSClassFromString(vcName);
    if (newClass == nil) {
        if ([vcName containsString:@"."]) {
            newClass = NSClassFromString(vcName);
        } else {
            // 这里swift.需要替换为当前项目的swift的路径包名
            newClass = NSClassFromString([NSString stringWithFormat:@"swift.%@", vcName]);
        }
    }
	return [newClass new];
}

#pragma mark - 判断属性是否存在
- (BOOL)isPropertyExists:(NSString *)propertyName {
	if(!propertyName.length) {
		return NO;
	}
	unsigned int count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	for(int i = 0; i < count; i++) {
		objc_property_t property = properties[i];

		NSString *name = [NSString stringWithUTF8String:property_getName(property)];
		if ([name isEqualToString:propertyName]) {
			return YES;
		}
	}
	free(properties);
	return NO;
}

@end
