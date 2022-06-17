//
//  WMPath.m
//  WMRouter
//
//  Created by 七海 on 2021/7/22.
//  Copyright © 2021 . All rights reserved.
//

#import "WMPath.h"
#import "NSString+WMRouter.h"

@implementation WMPath

+ (WMPath *)pathWithConfig:(NSDictionary *)config {
	if(!config) {
		return nil;
	}
	WMPath *path = [WMPath new];
	path.path = config[@"path"];
	path.note = config[@"note"];
	path.classRule = config[@"class"];
	path.originParamRule = config[@"param"];
	path.needLogin = [config[@"needLogin"] boolValue];
	path.needInfo = [config[@"needInfo"] boolValue];
	return path;
}

- (instancetype)initWithBundle:(NSBundle *)bundle {
    if (self) {
        self.bundle = bundle;
    }
    return self;
}

#pragma mark - setter
- (void)setUrl:(NSURL *)url {
	_url = url;
	if(url) {
		_scheme = url.scheme;
		_params = [url.query mapBy:_transParamRule];
	}
}

- (void)setClassRule:(NSString *)classRule {
	_classRule = classRule;

	if ([classRule containsString:@":"]) {
        NSArray *classArr = [classRule componentsSeparatedByString:@":"];
        if (classArr.count == 1) {
            _controllerName = classRule;
            _isStoryboard = NO;
            _controller = [[NSClassFromString(_controllerName) alloc] init];
            return;
        } else if (classArr.count == 2) {
            _controllerName = [classArr firstObject];
            _storyName = [classArr lastObject];
            _bundleName = nil;
            _isStoryboard = YES;
        } else {
            _controllerName = [classArr firstObject];
            _storyName = [classArr objectAtIndex:1];
            _bundleName = [classArr objectAtIndex:2];
            _isStoryboard = YES;
        }
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(_controllerName)];
        NSString *path = [bundle pathForResource:_bundleName ofType:@"bundle"];
        NSBundle *sbBundle = path ? [NSBundle bundleWithPath:path] : [NSBundle mainBundle];
		UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:_storyName bundle:sbBundle];
		_controller = [storyBoard instantiateViewControllerWithIdentifier:_controllerName];
	} else {
		_controllerName = classRule;
		_isStoryboard = NO;
		_controller = [[NSClassFromString(_controllerName) alloc] init];
	}
}

- (void)setOriginParamRule:(NSString *)originParamRule {
	_originParamRule = originParamRule;

	if(!originParamRule.length) {
		return;
	}
	//解析成字典
	NSMutableDictionary *mapDic = [NSMutableDictionary dictionary];
	NSArray *mapArray = [originParamRule componentsSeparatedByString:@"/"];
	for (NSString *mapString in mapArray) {
		if ([mapString containsString:@":"]) {
			NSArray *keyValueArray = [mapString componentsSeparatedByString:@":"];
			NSString *h5Key = [keyValueArray firstObject];
			NSString *nativeKey = [keyValueArray lastObject];
			[mapDic setValue:h5Key forKey:nativeKey];
		}
	}
	_transParamRule = mapDic;
	_params = [_url.query mapBy:mapDic];
}

@end
