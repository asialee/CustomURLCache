//
//  ViewController.m
//  CustomURLCacheExample
//
//  Created by  李亚洲 on 10/25/14.
//  Copyright (c) 2014 UCAS. All rights reserved.
//

#import "ViewController.h"
#import "DisplayController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController
/*-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mCache = (CustomURLCache*)[NSURLCache sharedURLCache];
        [_mCache changeToDownloadMode:@"subdir"];
    }
    return self;
}*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterDisplayPage:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    DisplayController *controller = [[DisplayController alloc]init];
    [appDelegate.navController pushViewController:controller animated:YES];
}
@end
