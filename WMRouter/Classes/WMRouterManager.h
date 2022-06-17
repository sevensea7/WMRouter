//
//  WMPathManager.h
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMPath.h"

@interface WMRouterManager : NSObject
/**导航器类*/
@property (nonatomic, strong) Class navigationControllerClass;
/**获取原配置（path作为key）*/
@property (nonatomic, strong, readonly) NSDictionary *originConfigure;
/**获取转译后的配置（class作为key）*/
@property (nonatomic, strong, readonly) NSDictionary *transConfigure;

/**获取单例*/
+ (instancetype)manager;

/**通过path查找配置*/
- (WMPath *)lookForPath:(NSString *)path;

@end

