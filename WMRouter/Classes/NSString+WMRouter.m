//
//  NSString+WMRouter.m
//  WMRouter
//
//  Created by 七海 on 2021/7/26.
//  Copyright © 2021 . All rights reserved.
//

#import "NSString+WMRouter.h"

@implementation NSString (WMRouter)

- (NSDictionary *)mapBy:(NSDictionary *)rules {
	if(!self.length) {
		return nil;
	}

	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	NSArray *paramArray = [self componentsSeparatedByString:@"&"];
	for (NSString *paramString in paramArray) {
		if (paramString.length) {
			NSArray *keyValueArray = [paramString componentsSeparatedByString:@"="];
            if (keyValueArray.count == 2) {
                NSString *key = [keyValueArray firstObject];
                NSString *value = [keyValueArray lastObject];

                if (rules.count && [rules.allKeys containsObject:key]) {
                    [params setValue:value forKey:rules[key]];
                }else{
                    [params setValue:value forKey:key];
                }
            }
		}
	}
	return params;
}

@end
