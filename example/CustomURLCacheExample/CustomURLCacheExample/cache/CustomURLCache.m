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
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request;
- (void)deleteCacheFolder;

@end

@implementation CustomURLCache

@synthesize cacheTime = _cacheTime;
@synthesize diskPath = _diskPath;
@synthesize responseDictionary = _responseDictionary;
@synthesize requestDictionary = _requestDictionary;
@synthesize savedOnDisk = _savedOnDisk;
@synthesize subDirectory = _subDirectory;
@synthesize localReourcePath = _localReourcePath;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime subDirectory:(NSString*)subDirectory{
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        self.cacheTime = cacheTime;
        self.subDirectory = subDirectory;
        if (path)
            self.diskPath = path;
        else
        {
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
        }
        mode = NORMAL_MODE;
        NSLog(@"disk path %@",self.diskPath);
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        self.requestDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        self.localReourcePath = [NSMutableDictionary dictionaryWithCapacity:5];
        _savedOnDisk = YES;
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if (NORMAL_MODE == mode) {
        NSLog(@"normal mode:%@",[[request URL]absoluteString]);
       return  [super cachedResponseForRequest:request];
    }
    //if (1 == _mode) {
        NSLog(@"article mode:%@",[[request URL]absoluteString]);
      //  return [super cachedResponseForRequest:request];
    //}
    
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    //NSLog(@"CACHED request %@",request.URL.absoluteString);
    
    NSString *url = request.URL.absoluteString;
    if ([_requestDictionary objectForKey:url] == nil) {
        [_requestDictionary setObject:request forKey:url];
        //NSLog(@"加入 %@",url);
    }
    //if this request is local resource
    if ([self.localReourcePath objectForKeyedSubscript:url] != nil)
    {
        NSCachedURLResponse *cachedResponse = [self loadLocalResouce:request path:[self.localReourcePath objectForKey:url]];
        if (cachedResponse != nil) {
            NSLog(@"load from local resource %@",request.URL.absoluteString);
            return  cachedResponse;
        }
        else
        {
            return [self dataFromRequest:request];
        }
    }
    return  [self dataFromRequest:request];
}

- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
    
    //[self deleteCacheFolder];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    [super removeCachedResponseForRequest:request];
    //这句要不要需要测试一下
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
    return @"URLCACHE";
}

- (void)deleteCacheFolder {
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    NSLog(@"delete file:%@",path);
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
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@", subDirPath, file]);
    return [NSString stringWithFormat:@"%@/%@", subDirPath, file];
}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
    return [requestUrl lastPathComponent];
    //return [Util md5Hash:requestUrl];
}

- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
    return [Util md5Hash:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
}

- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request {
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSDate *date = [NSDate date];
    //NSLog(@"data from request %@",[request description]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        BOOL expire = false;
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
        
        if (self.cacheTime > 0) {
            NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                expire = true;
            }
        }
        
        if (expire == false) {
            NSLog(@"data from cache ...");
            
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
    //NSLog(@"load from net %@",url);
    __block NSCachedURLResponse *cachedResponse = nil;
    //sendSynchronousRequest请求也要经过NSURLCache
    id boolExsite = [self.responseDictionary objectForKey:url];
    if (boolExsite == nil) {
        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
  
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
        {
            //[self.responseDictionary removeObjectForKey:url];
            
            if (error) {
                NSLog(@"error : %@", error);
                NSLog(@"not cached: %@", request.URL.absoluteString);
                cachedResponse = nil;
            }
            else
            {
            
                NSLog(@"get request ... %@",url);
            
                //save to cache
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
                                  response.MIMEType, @"MIMEType",
                                  response.textEncodingName, @"textEncodingName", nil];
                BOOL result1 = [dict writeToFile:otherInfoPath atomically:YES];
                BOOL result = [data writeToFile:filePath atomically:YES];
                if(result1 == NO || result == NO)
                {
                    NSLog(@"写入错误");
                }
                else{
                    NSLog(@"写入成功");
                }
                cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            
            }
        }];
        [super storeCachedResponse:cachedResponse forRequest:request];
        return cachedResponse;
        //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
    }

    return nil;
    }

    
}
- (NSString*) getDiskCacheForRequest:(NSString *)request
{
    NSString *url = request;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return filePath;
    }
    else
    {
        return nil;
    }
}
- (NSString*) subDirectoryFullPath
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    return  path;
}
-(void) removeCustomRequestDictionary
{
    
    /*NSEnumerator *enumerator = [_requestDictionary keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        [self removeCachedResponseForRequest:(NSURLRequest *)[_requestDictionary objectForKey:key]];
    }*/
    [self deleteCacheFolder];//删除文章对应的子目录
}
- (BOOL) savedOnDisk
{
    return  _savedOnDisk;
}

-(void) addLocalReourcePath:(NSString *)path request:(NSString *)request
{
    if ([self.localReourcePath objectForKey:request] != nil) {
        return;
    }
    [self.localReourcePath setObject:path forKey:request];
    return;
}

-(NSCachedURLResponse*) loadLocalResouce:(NSURLRequest*)request path:(NSString*)path
{
    //NSLog(@"load from local source %@,%@",request.URL.absoluteString,path);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    
    // Load the data
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    // Create the cacheable response
    NSURLResponse *response =
    [[NSURLResponse alloc]
      initWithURL:[request URL]
      MIMEType:[self mimeTypeForPath:[[request URL] absoluteString]]
      expectedContentLength:[data length]
      textEncodingName:nil];
    NSCachedURLResponse  *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    [self storeCachedResponse:cachedResponse forRequest:request];
    return cachedResponse;
    
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
