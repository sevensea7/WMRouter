//
//  WMRouter.h
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPath.h"
#import "WMRouterManager.h"
#import "UIViewController+WMRouter.h"
#import "NSString+WMRouter.h"
#import "UINavigationController+WMRouter.h"

/**便利构造*/
#define WMROUTER [WMRouter new]


/**微脉协议头*/
extern NSString * const WMScheme;

/**跳转方式*/
typedef NS_ENUM (int, WMRouterShowWay) {
	WMRouterShowWayPush = 0,
	WMRouterShowWayPresent,
};

/**错误代码*/
typedef NS_ENUM (int, WMRouterErrorCode) {
	WMRouterErrorCodeNullVC = 1,//控制器为空
	WMRouterErrorCodeWrongUrl = 2,//Scheme连接配置找不到
	WMRouterErrorCodeWrongScheme = 3, //Scheme不合法
};

@interface WMRouter : NSObject

#pragma mark - 配置相关

/**全局配置导航器类*/
- (WMRouter *(^)(Class nc))navigationController;

#pragma mark - 参数相关

/**通过字典前进参数组装*/
- (WMRouter *(^)(NSDictionary *params))dicMap;
/**通过url前进参数组装*/
- (WMRouter *(^)(NSString *url))urlMap;
/**前进参数映射规则 key:形参，value:实参*/
- (WMRouter *(^)(NSDictionary *paramRules))mapRules;
/**通过字典后退参数组装*/
- (WMRouter *(^)(NSDictionary *params))backDicMap;
/**后退参数映射规则 key:形参，value:实参*/
- (WMRouter *(^)(NSDictionary *paramRules))backMapRules;

#pragma mark - 回调相关

/**错误处理*/
- (WMRouter *(^)(void (^block)(WMRouterErrorCode errorCode)))errorCatch;
/**跳转前拦截*/
- (WMRouter *(^)(BOOL (^block)(void)))intercept;
/**跳转前拦截放行,放行情况下直接执行passBlock即可*/
- (WMRouter *(^)(void (^interceptBlock)(void (^passBlock)(NSDictionary *passParams))))interceptPass;
/**跳转成功回调*/
- (WMRouter *(^)(void (^block)(void)))completion;

#pragma mark - 参数是block的链式方法调用不方便，所以多提供普通方法

/**错误处理*/
- (WMRouter *)toErrorCatch:(void (^)(WMRouterErrorCode errorCode))block;
/**跳转前拦截*/
- (WMRouter *)toIntercept:(BOOL (^)(void))block;
/**跳转前拦截放行*/
- (WMRouter *)toInterceptPass:(BOOL (^)(void (^passBlock)(NSDictionary *passParams)))interceptBlock;
/**跳转成功回调*/
- (WMRouter *)toCompletion:(void (^)(void))block;

#pragma mark - 跳转控制

/// 通用跳转
- (WMRouter *(^)(id vc, BOOL animated))push;
- (WMRouter *(^)(id vc, BOOL animated))present;

#pragma mark - 返回控制，目前只支持同一navigationController

///直接返回
- (WMRouter *(^)(void))back;
- (WMRouter *(^)(BOOL animated))backFull;

///返回到根部
- (WMRouter *(^)(void))backToRoot;
- (WMRouter *(^)(BOOL animated))backToRootFull;

///通过控制器名返回
- (WMRouter *(^)(NSString *vc))backToName;
- (WMRouter *(^)(NSString *vc,BOOL animated))backToNameFull;

///通过控制器返回
- (WMRouter *(^)(UIViewController *vc))backToVC;
- (WMRouter *(^)(UIViewController *vc,BOOL animated))backToVCFull;


@end

