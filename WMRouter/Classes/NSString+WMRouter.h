//
//  NSString+WMRouter.h
//  WMRouter
//
//  Created by 七海 on 2021/7/26.
//  Copyright © 2021 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WMRouter)

/**参数转译*/
- (NSDictionary *)mapBy:(NSDictionary *)rules;

@end
