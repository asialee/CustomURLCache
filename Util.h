//
//  Util.h
//  LocalCache
//
//  Created by asialee on 14-10-25.
//  Copyright (c) 201d年 adways. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)sha1:(NSString *)str;
+ (NSString *)md5Hash:(NSString *)str;

@end
