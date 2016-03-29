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

@interface TestCell : UITableViewCell;

@end

@implementation TestCell

- (instancetype)init {
    if (self = [super init]) {
        }
    return self;
}

@end

@interface CGViewController ()<BrowsePictureViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation CGViewController

- (void)viewDidLoad {
    self.view.frame = [UIScreen mainScreen].bounds;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@(0));
        make.width.equalTo(@(320));
        make.height.equalTo(@(400));
    }];
    [self.tableView registerClass:[TestCell class] forCellReuseIdentifier:@"TestCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didClickButton {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.delegate = self;
    [self.navigationController pushBrowsePictureViewController:viewController];
}

- (void)didClickImageView:(UIGestureRecognizer *)gesture {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.startPage = gesture.view.tag;
    viewController.delegate = self;
    [self.navigationController pushBrowsePictureViewController:viewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BrowsePictureViewController *viewController = [BrowsePictureViewController create];
    viewController.startPage = indexPath.row;
    viewController.delegate = self;
    [self.navigationController pushBrowsePictureViewController:viewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
    cell.imageView.image = [UIImage imageNamed:indexPath.row % 2 == 0 ? @"test_image" : @"test_image2"];
    return cell;
}

- (void)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController downLoadImage:(ImageDownLoadFinish)downLoadImage index:(NSInteger)Index {
    
}

- (UIView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index {
    TestCell *cell = (TestCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell;
}

- (NSInteger)numberOfImagesInBrowsePictureViewController:(BrowsePictureViewController *)browsePitureViewController {
    return 20;
}

- (void)browsePictureViewControllerDidFinishSaving:(BrowsePictureViewController *)browsePictureViewController {
    NSLog(@"finish saving");
}

- (void)browsePictureViewControllerWillPopBack:(BrowsePictureViewController *)browsePictureViewController {
    NSLog(@"will popback");
}

- (void)browsePictureViewControllerDidPopBack:(BrowsePictureViewController *)browsePictureViewController {
    NSLog(@"did popback");
}

@end
