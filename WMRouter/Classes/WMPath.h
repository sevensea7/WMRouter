//
//  WMPath.h
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import <UIKit/UIKit.h>

/**跳转数据模型*/
@interface WMPath : NSObject

/**链接*/
@property (nonatomic, strong) NSURL *url;
/**协议头*/
@property (nonatomic, copy) NSString *scheme;
/**路径*/
@property (nonatomic, copy) NSString *path;
/**目标释义*/
@property (nonatomic, copy) NSString *note;
/**是否需要登录访问*/
@property (nonatomic, assign) BOOL needLogin;
/**是否需要完善信息访问*/
@property (nonatomic, assign) BOOL needInfo;

/**原始传参规则*/
@property (nonatomic, copy) NSString *originParamRule;
/**转译后的传参规则(形参:实参)*/
@property (nonatomic, strong) NSDictionary *transParamRule;
/**最终传参*/
@property (nonatomic, strong) NSDictionary *params;

/**原始目标规则 （类名：sb名：bundle名）*/
@property (nonatomic, copy) NSString *classRule;
/**目标控制器是否通过storyboard布局*/
@property (nonatomic, assign) BOOL isStoryboard;
/**bundle名*/
@property (nonatomic, copy) NSString *bundleName;
/**storyboard*/
@property (nonatomic, copy) NSString *storyName;
/**控制器类名*/
@property (nonatomic, copy) NSString *controllerName;
/**控制器*/
@property (nonatomic, strong) UIViewController *controller;
/** 初始化时加上当前 bundle */
@property (nonatomic, strong) NSBundle *bundle;


/** 简单工厂*/
+ (WMPath *)pathWithConfig:(NSDictionary *)config;

/** 当无法获取 mainBundle 的资源时 需要传 bundle */
- (instancetype)initWithBundle:(NSBundle *)bundle;

@end
