//
//  WMRouter.m
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import "WMRouter.h"
#import "NSDictionary+WMRouter.h"
#import "NSString+WMRouter.h"

NSString * const WMScheme = @"wm";
static const WMRouterShowWay kRouterDefaultWay = WMRouterShowWayPush; //默认跳转方式

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) \
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) { \
block(); \
} else { \
dispatch_async(dispatch_get_main_queue(), block); \
}
#endif

@interface WMRouter ()

@property (nonatomic, strong) NSDictionary *originForwardParamsDic; //原始前进参数字典
@property (nonatomic, copy) NSString *originForwardParamsUrl; //原始前进参数链接
@property (nonatomic, strong) NSDictionary *forwardParamRules; //前进参数匹配规则key:形参，value:实参

@property (nonatomic, strong) NSDictionary *originBackwardParamsDic; //原始后退参数字典
@property (nonatomic, strong) NSDictionary *backwardParamRules; //后退参数匹配规则key:形参，value:实参

@property (nonatomic, strong) NSMutableArray *interceptBlocks; //跳转前拦截回调
@property (nonatomic, strong) NSMutableArray *interceptPassBlocks; //跳转前拦截放行回调
@property (nonatomic, strong) NSMutableArray *completionBlocks; //跳转成功执行回调
@property (nonatomic, strong) NSMutableArray *errorBlocks; //错误执行回调

@end

@implementation WMRouter

#pragma mark - 配置
- (WMRouter *(^)(Class nc))navigationController {
    return ^(Class nc){
        WMRouterManager.manager.navigationControllerClass = nc;
        return self;
    };
}

#pragma mark - 参数
- (WMRouter *(^)(NSDictionary *params))dicMap {
    return ^(NSDictionary *params){
        self.originForwardParamsDic = params;
        return self;
    };
}

- (WMRouter *(^)(NSString *url))urlMap {
    return ^(NSString *url){
        self.originForwardParamsUrl = url;
        return self;
    };
}

- (WMRouter *(^)(NSDictionary *paramRules))mapRules {
    return ^(NSDictionary *rules){
        self.forwardParamRules = rules;
        return self;
    };
}

- (WMRouter *(^)(NSDictionary *params))backDicMap {
    return ^(NSDictionary *params){
        self.originBackwardParamsDic = params;
        return self;
    };
}

- (WMRouter *(^)(NSDictionary *paramRules))backMapRules {
    return ^(NSDictionary *rules){
        self.backwardParamRules = rules;
        return self;
    };
}

#pragma mark - 回调
- (WMRouter *(^)(BOOL (^block)(void)))intercept {
    return ^(BOOL (^block)(void)){
        if (block) {
            [self.interceptBlocks addObject:block];
        }
        return self;
    };
}

- (WMRouter *(^)(void (^block)(void)))completion {
    return ^(void (^block)(void)){
        if(block) {
            [self.completionBlocks addObject:block];
        }
        return self;
    };
}

- (WMRouter *(^)(void (^block)(WMRouterErrorCode errorCode)))errorCatch {
    return ^(void (^block)(WMRouterErrorCode errorCode)){
        if(block) {
            [self.errorBlocks addObject:block];
        }
        return self;
    };
}

- (WMRouter *(^)(void (^interceptBlock)(void (^passBlock)(NSDictionary *passParams))))interceptPass {
    return ^(void (^interceptBlock)(void (^passBlock)(NSDictionary *passParams))){
        if(interceptBlock) {
            [self.interceptPassBlocks addObject:interceptBlock];
        }
        return self;
    };
}

- (WMRouter *)toIntercept:(BOOL (^)(void))block {
    if (block) {
        [self.interceptBlocks addObject:block];
    }
    return self;
}

- (WMRouter *)toInterceptPass:(BOOL (^)(void (^passBlock)(NSDictionary *passParams)))interceptBlock {
    if (interceptBlock) {
        [self.interceptPassBlocks addObject:interceptBlock];
    }
    return self;
}

- (WMRouter *)toCompletion:(void (^)(void))block {
    if (block) {
        [self.completionBlocks addObject:block];
    }
    return self;
}

- (WMRouter *)toErrorCatch:(void (^)(WMRouterErrorCode errorCode))block {
    if (block) {
        [self.errorBlocks addObject:block];
    }
    return self;
}

#pragma mark - 通用跳转
- (WMRouter *(^)(id vc, BOOL animated))push {
    return ^(id vc, BOOL animated) {
        if ([vc isKindOfClass:[NSString class]]) {
            self.goVCByNameFull(vc, WMRouterShowWayPush, animated);
        } else if ([vc isKindOfClass:[UIViewController class]]) {
            self.goVCFull(vc, WMRouterShowWayPush, animated);
        } else if ([vc isKindOfClass:[WMPath class]]) {
            self.goPathFull(vc, WMRouterShowWayPush, animated);
        } else if ([vc isKindOfClass:[NSURL class]]) {
            self.goUrlFull(vc, WMRouterShowWayPush, animated);
        }
        return self;
    };
}

- (WMRouter *(^)(id vc, BOOL animated))present {
    return ^(id vc, BOOL animated) {
        if ([vc isKindOfClass:[NSString class]]) {
            self.goVCByNameFull(vc, WMRouterShowWayPresent, animated);
        } else if ([vc isKindOfClass:[UIViewController class]]) {
            self.goVCFull(vc, WMRouterShowWayPresent, animated);
        } else if ([vc isKindOfClass:[WMPath class]]) {
            self.goPathFull(vc, WMRouterShowWayPresent, animated);
        } else if ([vc isKindOfClass:[NSURL class]]) {
            self.goUrlFull(vc, WMRouterShowWayPresent, animated);
        }
        return self;
    };
}

#pragma mark - 通过url跳转
- (WMRouter *(^)(NSURL *url))goUrl {
    return ^(NSURL *url) {
        self.goUrlFull(url, kRouterDefaultWay, YES);
        return self;
    };
}

- (WMRouter *(^)(NSURL *url, WMRouterShowWay way, BOOL animated))goUrlFull {
    return ^(NSURL *url, WMRouterShowWay way, BOOL animated) {
        if (url) {
            NSString *relativePath = [url.host stringByAppendingString:url.path];
            WMPath *path = [WMRouterManager.manager lookForPath:relativePath];
            if(!path) {
                [self executeErrorBlocks:WMRouterErrorCodeWrongUrl];
                NSLog(@"Router Error: Url配置找不到");
                return self;
            }
            path.url = url;
            self.goPathFull(path, way, animated);
        }
        return self;
    };
}

#pragma mark - 通过path跳转
- (WMRouter *(^)(WMPath *path))goPath {
    return ^(WMPath *path) {
        self.goPathFull(path,kRouterDefaultWay,YES);
        return self;
    };
}

- (WMRouter *(^)(WMPath *path, WMRouterShowWay way, BOOL animated))goPathFull {
    return ^(WMPath *path, WMRouterShowWay way, BOOL animated) {
        if(path) {
            if (path.isStoryboard) {
                //内部链接
                if (!path.controller) {
                    [self executeErrorBlocks:WMRouterErrorCodeNullVC];
                    NSLog(@"Router Error: 控制器为空");
                } else {
                    path.controller.wm_forwardParams = path.params;
                    [self preRedirect:path.controller way:way animated:animated];
                }
            } else {
                if ([WMScheme isEqualToString:path.scheme]) {
                    //内部链接
                    if (!path.controller) {
                        [self executeErrorBlocks:WMRouterErrorCodeNullVC];
                        NSLog(@"Router Error: 控制器为空");
                    } else {
                        path.controller.wm_forwardParams = path.params;
                        [self preRedirect:path.controller way:way animated:animated];
                    }
                } else {
                    [self executeErrorBlocks:WMRouterErrorCodeWrongScheme];
                    NSLog(@"Router Error: Scheme不合法");
                }
            }
        }
        return self;
    };
}

#pragma mark - 通过控制器名跳转
- (WMRouter *(^)(NSString *vc))goVCByName {
    return ^(NSString *vc) {
        self.goVCByNameFull(vc, kRouterDefaultWay, YES);
        return self;
    };
}

- (WMRouter *(^)(NSString *vc, WMRouterShowWay way, BOOL animated))goVCByNameFull {
    return ^(NSString *vc, WMRouterShowWay way, BOOL animated) {
        [self preRedirect:[UIViewController controllerWithName:vc] way:way animated:animated];
        return self;
    };
}

#pragma mark - 通过控制器跳转
- (WMRouter *(^)(UIViewController *vc))goVC {
    return ^(UIViewController *vc) {
        self.goVCFull(vc, kRouterDefaultWay, YES);
        return self;
    };
}

- (WMRouter *(^)(UIViewController *vc, WMRouterShowWay way, BOOL animated))goVCFull {
    return ^(UIViewController *vc, WMRouterShowWay way, BOOL animated) {
        [self preRedirect:vc way:way animated:animated];
        return self;
    };
}

#pragma mark - 直接返回
- (WMRouter *(^)(void))back {
    return ^{
        self.backFull(YES);
        return self;
    };
}

- (WMRouter *(^)(BOOL animated))backFull {
    return ^(BOOL animated) {
        [self goBack:nil root:NO name:nil animated:animated];
        return self;
    };
}

#pragma mark - 返回到根部
- (WMRouter *(^)(void))backToRoot {
    return ^{
        self.backToRootFull(YES);
        return self;
    };
}

- (WMRouter *(^)(BOOL animated))backToRootFull {
    return ^(BOOL animated) {
        [self goBack:nil root:YES name:nil animated:animated];
        return self;
    };
}

#pragma mark - 通过控制器名返回
- (WMRouter *(^)(NSString *vc))backToName {
    return ^(NSString *vc) {
        self.backToNameFull(vc,YES);
        return self;
    };
}

- (WMRouter *(^)(NSString *vc,BOOL animated))backToNameFull {
    return ^(NSString *vc,BOOL animated) {
        [self goBack:nil root:NO name:vc animated:animated];
        return self;
    };
}

#pragma mark - 通过控制器名返回
- (WMRouter *(^)(UIViewController *vc))backToVC {
    return ^(UIViewController *vc) {
        self.backToVCFull(vc,YES);
        return self;
    };
}

- (WMRouter *(^)(UIViewController *vc,BOOL animated))backToVCFull {
    return ^(UIViewController *vc,BOOL animated) {
        [self goBack:vc root:NO name:nil animated:animated];
        return self;
    };
}

#pragma mark - private
- (void)preRedirect:(UIViewController *)vc way:(WMRouterShowWay)way animated:(BOOL)animated {
    if (!vc) {
        [self executeErrorBlocks:WMRouterErrorCodeNullVC];
        NSLog(@"Router Error: 控制器为空");
        return;
    }
    
    //跳转前拦截
    BOOL should = [self excuteInterceptBlocks];
    if (!should) {
        return;
    }
    
    //跳转前拦截放行
    if (self.interceptPassBlocks.count) {
        [self excuteInterceptPassBlocks:vc way:way animated:animated];
    } else {
        [self redirect:vc way:way animated:animated];
    }
}

- (void)redirect:(UIViewController *)vc way:(WMRouterShowWay)way animated:(BOOL)animated {
    dispatch_main_async_safe(^{
        if (self.originForwardParamsUrl) {
            NSDictionary *formatParams = [self.originForwardParamsUrl mapBy:self.forwardParamRules];
            vc.wm_forwardParams = formatParams;
        }
        if (self.originForwardParamsDic) {
            NSDictionary *formatParams = [self.originForwardParamsDic mapBy:self.forwardParamRules];
            vc.wm_forwardParams = formatParams;
        }
        
        if (way == WMRouterShowWayPresent) {
            UINavigationController *nc = nil;
            if(WMRouterManager.manager.navigationControllerClass) {
                nc = [[WMRouterManager.manager.navigationControllerClass alloc] initWithRootViewController:vc];;
            } else {
                nc = [[UINavigationController alloc] initWithRootViewController:vc];
            }
            nc.modalPresentationStyle = UIModalPresentationFullScreen;
            [UIViewController.current presentViewController:nc animated:animated completion:^{
                for(void (^block)(void) in self.completionBlocks) {
                    block();
                }
            }];
        } else {
            [UINavigationController.current pushViewController:vc animated:animated completion:^{
                for(void (^block)(void) in self.completionBlocks) {
                    block();
                }
            }];
        }
        NSLog(@"Router go vc :%@ params: %@",NSStringFromClass([vc class]),vc.wm_forwardParams);
    });
}

- (void)goBack:(UIViewController *)vc root:(BOOL)root name:(NSString *)vcName animated:(BOOL)animated {
    UINavigationController *nc = UINavigationController.current;
    UIViewController *targetVC = nil;
    NSArray *childVCs = [nc.viewControllers reverseObjectEnumerator].allObjects;
    if (vc) {
        targetVC = vc;
    } else if (root) {
        if (nc.viewControllers.count > 1) {
            targetVC = childVCs.lastObject;
        }
    } else if (vcName.length) {
        for (UIViewController *childVC in childVCs) {
            if ([vcName isEqualToString:NSStringFromClass([childVC class])] && ![childVC isEqual:childVCs.firstObject]) {
                targetVC = childVC;
                break;
            }
        }
    } else if (nc.viewControllers.count > 1) {
        targetVC = [childVCs objectAtIndex:1];
    }
    if (targetVC) {
        targetVC.wm_backwardParams = [self.originBackwardParamsDic mapBy:self.backwardParamRules];
        [nc popToViewController:targetVC animated:animated];
    }
}

#pragma mark - 执行错误回调
- (void)executeErrorBlocks:(WMRouterErrorCode)errorCode {
    for (void (^block)(WMRouterErrorCode errorCode) in self.errorBlocks) {
        block(errorCode);
    }
}

#pragma mark - 执行拦截回调
- (BOOL)excuteInterceptBlocks {
    if (self.interceptBlocks.count) {
        BOOL (^block)(void) = self.interceptBlocks.firstObject;
        BOOL result = block();
        [self.interceptBlocks removeObjectAtIndex:0];
        if(!result) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 执行拦截放行回调
- (void)excuteInterceptPassBlocks:(UIViewController *)vc way:(WMRouterShowWay)way animated:(BOOL)animated {
    if (self.interceptPassBlocks.count) {
        __weak __typeof__(self) weakSelf = self;
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        void (^interceptBlock)(void (^passBlock)(NSDictionary *passParams)) = self.interceptPassBlocks.firstObject;
        
        interceptBlock(^(NSDictionary *passParams) {
            if(!strongSelf.originForwardParamsDic) {
                strongSelf.originForwardParamsDic = [NSMutableDictionary dictionary];
            }
            [strongSelf.originForwardParamsDic setValuesForKeysWithDictionary:passParams];
            [strongSelf preRedirect:vc way:way animated:animated];
        });
        [self.interceptPassBlocks removeObjectAtIndex:0];
    }
}

#pragma mark - getter
- (NSMutableArray *)interceptBlocks {
    if (!_interceptBlocks) {
        _interceptBlocks = [NSMutableArray array];
    }
    return _interceptBlocks;
}

- (NSMutableArray *)interceptPassBlocks {
    if(!_interceptPassBlocks) {
        _interceptPassBlocks = [NSMutableArray array];
    }
    return _interceptPassBlocks;
}

- (NSMutableArray *)completionBlocks {
    if(!_completionBlocks) {
        _completionBlocks = [NSMutableArray array];
    }
    return _completionBlocks;
}

- (NSMutableArray *)errorBlocks {
    if(!_errorBlocks) {
        _errorBlocks = [NSMutableArray array];
    }
    return _errorBlocks;
}

@end
