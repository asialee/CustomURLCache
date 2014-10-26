//
//  CustomURLCache.h
//  LocalCache
//
//  Created by asialee on 14-10-25.
//  Copyright (c) 2014年 adways. All rights reserved.
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
//The disk path where you want to download the request result to 
@property(nonatomic, retain) NSString *diskPath;
@property(nonatomic, retain) NSString *subDirectory;

//The dictionary for the results downloaded
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;

//The dictionary for the requests
@property(nonatomic, retain) NSMutableDictionary *requestDictionary;
@property(nonatomic, assign) BOOL savedOnDisk;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime subDirectory:(NSString*)subDirectory;
-(void) removeCustomRequestDictionary;
- (NSString*) subDirectoryFullPath;
- (void)changeToDownloadMode:(NSString *)downDir;
- (void)changeToNormalMode;
@end
