CustomURLCache
==============

The Custom NSURLCache for iOS NSURLCache, can be used to download web request result to your own custom directory

This class makes the download work so easy, that the user need only to specify the path where he wants to download the web request result, especially while developing with UIWebViewController.

There are 2 modes in this class:NORMAL_MODE,DOWN_MODE.While NORMAL_MODE does the completely same work as the default NSURLCache, the DOWN_MODE can be used to store all the web request result to your specified path.

In the following, I will guide you how to use with this class.

1. In iOS 8 , change URLCache to your own URLCache can only be executed in the :
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions in the AppDelegate.m . 
To use the NSURLCache, copy the following code:

CustomURLCache *_mCache = [[CustomURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                diskCapacity:200 * 1024 * 1024
                                                    diskPath:nil
                                                   cacheTime:0
                                                subDirectory:nil];

[NSURLCache setSharedURLCache:_mCache];

This will shift the URLCache from NSURLCache to your CustomURLCache.

The parameters:
		disPath is the path where you want to store. if set to nil, it equals the default cache directory.
		cacheTime is the expiring time of the caches.if set to 0, the cache will never be expired.
		subDirectory is a subdirectory in the diskPath. While initialising it needn’t to set this, just set it to nil;
In addition, while initialising the CustomURLCache, the default mode is NORMAL_MODE which means the function of this class now is completely same as NSURLCache.


2. Now, you may want to use download mode in your app. And in the following, I will give an example of downloading all the resource of a web page to teach you how to use this class.
   Let’s denote the controller where you want to display the web page webController.
   
   1) In the (id)init function or (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil of webController, add the following code:
	 CustomURLCache *_mCache = (CustomURLCache *)[NSURLCache sharedURLCache];
        [_mCache changeToDownloadMode:_subDir];//_subDir is the sub directory under diskPath to store your URL request.
   
   2) Then all the request in a certain page will automatically be downloaded into your specified directory.

   3) While leaving this page, there is some additional work to do in the dealloc function or the custom function which will destroy the webController and back to the former controller:
      if you want to change the mode back to NORMAL_MODE: [_mCache changeToNormalMode];
      if you wanna restore all the cache in the subDirectory you set, then do noting, but if you want to delete all the caches , call this function:[_mCache removeCustomRequestDictionary ];
      And maybe you want to store the full path where you download all the page resources to a dictionary, call this:[_mCache subDirectoryFullPath]. It will return the full path.

3. Now suppose you enter this webController again, you fill find this page will be loaded in a minute.


Using CustomURLCache is just this easy, hope you enjoy it!
	
	
   
