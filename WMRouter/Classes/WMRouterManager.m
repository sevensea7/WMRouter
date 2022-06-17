//
//  WMRouterManager.m
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import "WMRouterManager.h"

@implementation WMRouterManager

@synthesize originConfigure = _originConfigure;
@synthesize transConfigure = _transConfigure;

#pragma mark - 获取单例
+ (instancetype) manager {
	static WMRouterManager *_instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[WMRouterManager alloc] init];
	});
	return _instance;
}

#pragma mark - 通过path查找配置
- (WMPath *)lookForPath:(NSString *)path {
	NSDictionary *config = self.originConfigure[path];
	WMPath *wmpath = [WMPath pathWithConfig:config];
	return wmpath;
}

#pragma mark - getter
- (NSDictionary *)originConfigure {
	if(!_originConfigure) {
		NSString *configPath = [[NSBundle mainBundle] pathForResource:@"WMScheme" ofType:@"plist"];
		NSMutableDictionary *totalConfig = [NSMutableDictionary dictionary];
		NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
		for (NSString *path in config.allKeys) {
			NSMutableDictionary *subConfig = [NSMutableDictionary dictionaryWithDictionary:config[path]];
			[subConfig setValue:path forKey:@"path"];
			[totalConfig setValue:subConfig forKey:path];
		}
		_originConfigure = totalConfig;
	}
	return _originConfigure;
}

- (NSDictionary *)transConfigure {
	if(!_transConfigure) {
		_transConfigure = [NSMutableDictionary dictionary];
		for (NSString *path in self.originConfigure.allKeys) {
			@autoreleasepool {
				NSDictionary *subConfig = self.originConfigure[path];
				NSMutableDictionary *subTransConfig = [NSMutableDictionary dictionary];
				[subTransConfig setValue:path forKey:@"path"];
				NSString *className = nil;
				for (NSString *key in subConfig.allKeys) {
					[subTransConfig setValue:subConfig[key] forKey:key];
					if ([key isEqualToString:@"class"]) {
						className = subConfig[key];
					}
				}
				[_transConfigure setValue:subTransConfig forKey:className];
			}
		}
	}
	return _transConfigure;
}

@end
