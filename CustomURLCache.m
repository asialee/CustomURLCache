//
//  CustomURLCache.m
//  LocalCache
//
//  Created by tan on 13-2-12.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import "CustomURLCache.h"

@interface CustomURLCache(private)

- (NSString *)cacheFolder;
- (NSString *)cacheFilePath:(NSString *)file;
- (NSString *)cacheRequestFileName:(NSString *)requestUrl;
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl;
- (NSCachedURLResponse *)dataForRequest:(NSURLRequest *)request;
- (void)deleteCacheFolder;

@end

@implementation CustomURLCache

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime subDirectory:(NSString*)subDirectory{
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        
        //If set the cacheTime to 0, the cache will never expire
        self.cacheTime = cacheTime;
        
        //subDirectory is the path where the cache stored
        self.subDirectory = subDirectory;
        if (path)
            self.diskPath = path;
        else
        {
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        }
        
        //The default mode is NORMAL_MODE the same as NSURLCache
        mode = NORMAL_MODE;
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        self.requestDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        _savedOnDisk = YES;
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if (NORMAL_MODE == mode) {
        // While in the mode of NORMAL_MODE:doing the same work with NSURLCache
       return  [super cachedResponseForRequest:request];
    }
    
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    //Add the request to _requestDictionary
    NSString *url = request.URL.absoluteString;
    if ([_requestDictionary objectForKey:url] == nil) {
        [_requestDictionary setObject:request forKey:url];
    }
    return  [self dataForRequest:request];
}

- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    [super removeCachedResponseForRequest:request];
    if (mode == NORMAL_MODE) {
        return;
    }
    
    
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:otherInfoPath error:nil];
}

#pragma mark - custom url cache

- (NSString *)cacheFolder {
    return @"URLCache";
}


// Delete the cache in the custom directory
- (void)deleteCacheFolder {
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheFilePath:(NSString *)file {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *subDirPath = [NSString stringWithFormat:@"%@/%@/%@",self.diskPath,[self cacheFolder],self.subDirectory];
    if ([fileManager fileExistsAtPath:subDirPath isDirectory:&isDir] && isDir) {
    }
    else
    {
        [fileManager createDirectoryAtPath:subDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", subDirPath, file];
}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
    return [Util md5Hash:requestUrl];
}

- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
    return [Util md5Hash:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
}


- (NSString*) subDirectoryFullPath
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    return  path;
}


- (NSCachedURLResponse *)dataForRequest:(NSURLRequest *)request {
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSDate *date = [NSDate date];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {

        //find cache in custom directory
        BOOL expire = false;
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
        
        if (self.cacheTime > 0) {
            NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                expire = true;
            }
        }
        
        if (expire == false) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                MIMEType:[otherInfo objectForKey:@"MIMEType"]
                                                   expectedContentLength:data.length
                                                        textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            return cachedResponse;
        } else {
            NSLog(@"cache expire ... ");
            
            [fileManager removeItemAtPath:filePath error:nil];
            [fileManager removeItemAtPath:otherInfoPath error:nil];
            return  nil;
        }
    }
    else
    {
        self.savedOnDisk = NO;
    __block NSCachedURLResponse *cachedResponse = nil;
    //sendSynchronousRequest请求也要经过NSURLCache
    id boolExsite = [self.responseDictionary objectForKey:url];
    if (boolExsite == nil) {
        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
  
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
        {
            
            if (error) {
                NSLog(@"error : %@", error);
                [self.responseDictionary removeObjectForKey:url];
                cachedResponse = nil;
            }
            else
            {
               //Save to custom directory
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
                                  response.MIMEType, @"MIMEType",
                                  response.textEncodingName, @"textEncodingName", nil];
                BOOL result1 = [dict writeToFile:otherInfoPath atomically:YES];
                BOOL result = [data writeToFile:filePath atomically:YES];
                if(result1 == NO || result == NO)
                {
                    NSLog(@"Fail to write cache to the custom directory");
                    [self.responseDictionary removeObjectForKey:url];
                }
                else{
                    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                    [super storeCachedResponse:cachedResponse forRequest:request];
                }
            }
        }];
        
        return cachedResponse;
    }
    return nil;
}

    
}

-(void) removeCustomRequestDictionary
{
    if (mode == NORMAL_MODE) {
        return;
    }
    [self deleteCacheFolder];//删除文章对应的子目录
}
- (BOOL) savedOnDisk
{
    return  _savedOnDisk;
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
	//
	// Current code only substitutes PNG images
	//
	return @"image/png";
}

-(void)changeToDownloadMode:(NSString *)downDir
{
    mode = DOWNLOAD_MODE;
    self.subDirectory = downDir;
}

-(void) changeToNormalMode
{
    mode = NORMAL_MODE;
}
@end
