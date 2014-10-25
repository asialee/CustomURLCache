//
//  CustomURLCache.h
//  LocalCache
//
//  Created by tan on 13-2-12.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
typedef enum
{
    NORMAL_MODE = 0,
    DOWNLOAD_MODE = 1
}MODE;
@interface CustomURLCache : NSURLCache
{
    int mode;
}

@property(nonatomic, assign) NSInteger cacheTime;
@property(nonatomic, retain) NSString *diskPath;
@property(nonatomic, retain) NSString *subDirectory;
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;
@property(nonatomic, retain) NSMutableDictionary *requestDictionary;
@property(nonatomic, assign) BOOL savedOnDisk;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime subDirectory:(NSString*)subDirectory;
-(void) removeCustomRequestDictionary;
- (NSString*) subDirectoryFullPath;
//- (NSString*) getDiskCacheForRequest:(NSString *)request;

- (void)changeToDownloadMode:(NSString *)downDir;
- (void)changeToNormalMode;
@end
