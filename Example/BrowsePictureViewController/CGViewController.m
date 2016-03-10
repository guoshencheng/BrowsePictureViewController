//
//  CGViewController.m
//  BrowsePictureViewController
//
//  Created by guoshencheng on 03/10/2016.
//  Copyright (c) 2016 guoshencheng. All rights reserved.
//

#import "CGViewController.h"
#import "BrowsePictureViewController.h"

@interface CGViewController ()<BrowsePictureViewControllerDelegate>

@property (strong, nonatomic) UIButton *button;

@end

@implementation CGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:self.button];
    [self.button setBackgroundColor:[UIColor blackColor]];
    [self.button addTarget:self action:@selector(didClickButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickButton {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController downLoadImage:(ImageDownLoadFinish)downLoadImage index:(NSInteger)Index {
    
}

- (NSString *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController textAtIndex:(NSInteger)index {
    return @"water mark test";
}

- (UIImageView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index {
    UIImageView *imageView = [[UIImageView alloc] init];
    return imageView;
}

- (NSInteger)numberOfImagesInBrowsePictureViewController:(BrowsePictureViewController *)browsePitureViewController {
    return 3;
}

- (void)browsePictureViewControllerDidFinishSaving:(BrowsePictureViewController *)browsePictureViewController {
    NSLog(@"finish saving");
}


@end
