//
//  CGAppDelegate.m
//  BrowsePictureViewController
//
//  Created by guoshencheng on 03/10/2016.
//  Copyright (c) 2016 guoshencheng. All rights reserved.
//

#import "CGAppDelegate.h"
#import "CGViewController.h"

@implementation CGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CGViewController *viewController = [CGViewController new];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.navigationController.navigationBarHidden = YES;
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
