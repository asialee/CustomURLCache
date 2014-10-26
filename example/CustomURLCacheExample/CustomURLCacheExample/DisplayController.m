//
//  DisplayController.m
//  CustomURLCacheExample
//
//  Created by  李亚洲 on 10/26/14.
//  Copyright (c) 2014 UCAS. All rights reserved.
//

#import "DisplayController.h"

@interface DisplayController ()

@end

@implementation DisplayController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mCache = (CustomURLCache *)[NSURLCache sharedURLCache];
        [_mCache changeToDownloadMode:@"download_dir"];
    }
    return  self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_mWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://liyazhou.com"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToMainPage:(id)sender {
    [_mCache changeToNormalMode];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
