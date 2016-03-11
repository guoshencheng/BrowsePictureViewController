//
//  CGViewController.m
//  BrowsePictureViewController
//
//  Created by guoshencheng on 03/10/2016.
//  Copyright (c) 2016 guoshencheng. All rights reserved.
//

#import "CGViewController.h"
#import "BrowsePictureViewController.h"
#import <Masonry/Masonry.h>

@interface CGViewController ()<BrowsePictureViewControllerDelegate>

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:self.button];
    [self.button setBackgroundColor:[UIColor blackColor]];
    [self.button addTarget:self action:@selector(didClickButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [self.view addSubview:self.imageView];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    [self.imageView setImage:[UIImage imageNamed:@"test_image"]];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImageView)];
    self.imageView.layer.cornerRadius = 50;
    [self.imageView addGestureRecognizer:gesture];
}

- (void)didClickButton {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.delegate = self;
    [self.navigationController pushBrowsePictureViewController:viewController];
}

- (void)didClickImageView {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.delegate = self;
    [self.navigationController pushBrowsePictureViewController:viewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController downLoadImage:(ImageDownLoadFinish)downLoadImage index:(NSInteger)Index {
    
}

- (NSString *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController textAtIndex:(NSInteger)index {
    return nil;
}

- (UIImageView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index {
    return self.imageView;
}

- (NSInteger)numberOfImagesInBrowsePictureViewController:(BrowsePictureViewController *)browsePitureViewController {
    return 1;
}

- (void)browsePictureViewControllerDidFinishSaving:(BrowsePictureViewController *)browsePictureViewController {
    NSLog(@"finish saving");
}


@end
