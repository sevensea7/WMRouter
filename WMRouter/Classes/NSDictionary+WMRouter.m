//
//  NSDictionary+WMRouter.m
//  WMRouter
//
//  Created by 七海 on 2021/7/26.
//  Copyright © 2021 . All rights reserved.
//

#import "NSDictionary+WMRouter.h"

@implementation NSDictionary (WMRouter)

- (NSDictionary *)mapBy:(NSDictionary *)rules {
	if(!self.count) {
		return nil;
	}
	if(!rules || !rules.count) {
		return self;
	}
	NSMutableDictionary *formatParams = [NSMutableDictionary dictionary];
	for(NSString *key in self.allKeys) {
		if([rules.allKeys containsObject:key]) {
			[formatParams setValue:self[key] forKey:rules[key]];
		}else{
			[formatParams setValue:self[key] forKey:key];
		}
	}
	return formatParams;
}

@end
