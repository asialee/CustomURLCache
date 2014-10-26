//
//  DisplayController.h
//  CustomURLCacheExample
//
//  Created by  李亚洲 on 10/26/14.
//  Copyright (c) 2014 UCAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomURLCache.h"

@interface DisplayController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *mWebview;
@property (strong, nonatomic) CustomURLCache *mCache;
- (IBAction)backToMainPage:(id)sender;

@end
