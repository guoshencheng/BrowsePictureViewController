//
//  BrowsePictureViewController.m
//  renyan
//
//  Created by guoshencheng on 12/30/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import "BrowsePictureViewController.h"
#import "BrowsePictureCell.h"
#import "Masonry.h"
#import "ImageViewApearTransition.h"

@implementation UIImage (WaterMark)

- (UIImage *)addMsakImage:(UIImage *)maskImage text:(NSString *)text msakRect:(CGRect)msakRect textRect:(CGRect)textRect fontSize:(CGFloat)fontSize {
    UIGraphicsBeginImageContextWithOptions(self.size,NO, 2);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 1.0;
    shadow.shadowColor = [UIColor blackColor];
    CGFloat offset = 0.5 / 8 * fontSize;
    shadow.shadowOffset = CGSizeMake(offset, offset);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor],NSShadowAttributeName:shadow,NSVerticalGlyphFormAttributeName:@(0), NSParagraphStyleAttributeName: style};
    if (maskImage) [maskImage drawInRect:msakRect];
    if (text && text.length > 0) [text drawInRect:textRect withAttributes:attr];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end


@implementation BrowsePictureCustomConfig

+ (instancetype)sharedConfig {
    static BrowsePictureCustomConfig *config = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        config = [[BrowsePictureCustomConfig alloc] init];
        config.saveString = @"save";
        config.waterMarkImge = nil;
    });
    return config;
}

@end

@interface BrowsePictureViewController () <UICollectionViewDataSource, UICollectionViewDelegate, BrowsePictureCellDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@end

@implementation BrowsePictureViewController

#pragma mark - PublicMethod

+ (instancetype)create {
    BrowsePictureViewController *browsePictureViewController = [[BrowsePictureViewController alloc] init];
    browsePictureViewController.automaticallyAdjustsScrollViewInsets = NO;
    browsePictureViewController.scaleToMax = NO;
    return browsePictureViewController;
}

- (UIImageView *)currentImageView {
    BrowsePictureCell *cell = (BrowsePictureCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.pageControl.currentPage inSection:0]];
    UIImageView *imageView = cell.imageView;
    return imageView;
}

- (UIImageView *)currentOriginImageView {
    UIImageView *imageView = [self.delegate browsePictureViewController:self imageViewAtIndex:self.pageControl.currentPage];
    return imageView;
}

- (void)showHideAllViews:(BOOL)show {
    self.collectionView.hidden = !show;
    self.saveButton.hidden = !show;
}

- (IBAction)clickSaveImageButton:(id)sender {
    [self startIndicatorView];
    BrowsePictureCell *browsePictureCell = self.collectionView.visibleCells[0];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:browsePictureCell];
    UIImage *image = browsePictureCell.image;
    CGFloat width = image.size.width * 0.1;
    CGFloat height = image.size.width * 0.1 * 22.0 / 40;
    CGFloat fontSize = image.size.width * 0.025;
    UIImage *waterMarkedImage = [image addMsakImage:[self waterMarkImage] text:[self waterMarkTextAtIndex:indexPath.row] msakRect:CGRectMake((image.size.width - width) / 2, image.size.height - (fontSize + 9 + height), width, height) textRect:CGRectMake((image.size.width - 320) / 2, image.size.height - (fontSize + 8), 320, (fontSize + 1)) fontSize:fontSize];
    UIImageWriteToSavedPhotosAlbum(waterMarkedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self configureCollectionView];
    [self configurePageControl];
    [self configureSaveButton];
}

- (void)configureCollectionView {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView setContentOffset:CGPointMake(self.startPage * [UIScreen mainScreen].bounds.size.width, 0) animated:NO];
    [self.collectionView registerNib:[UINib nibWithNibName:BROWSE_PICTURE_CELL_NIBNAME bundle:nil] forCellWithReuseIdentifier:BROWSE_PICTURE_CELL_ID];
}

- (void)configurePageControl {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInBrowsePictureViewController:)]) {
        self.pageControl.numberOfPages = [self.delegate numberOfImagesInBrowsePictureViewController:self];
    } else {
        self.pageControl.numberOfPages = 1;
    }
    self.pageControl.currentPage = self.startPage;
    self.pageControl.hidden = self.pageControl.numberOfPages == 1;
}

- (void)configureSaveButton {
    [self.saveButton setTitle:[BrowsePictureCustomConfig sharedConfig].saveString forState:UIControlStateNormal];
}

- (NSString *)waterMarkTextAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(browsePictureViewController:textAtIndex:)]) {
        return [self.delegate browsePictureViewController:self textAtIndex:index];
    } else {
        return nil;
    }
}

- (UIImage *)waterMarkImage {
    return [BrowsePictureCustomConfig sharedConfig].waterMarkImge;
}

#pragma mark - Private Method

- (void)startIndicatorView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; {
    [_indicatorView stopAnimating];
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
    if ([self.delegate respondsToSelector:@selector(browsePictureViewControllerDidFinishSaving:)]) {
        [self.delegate browsePictureViewControllerDidFinishSaving:self];
    }
}

#pragma mark - BrosePictureCellDelegate

- (void)browsePictureCellDidTapImage:(BrowsePictureCell *)browsePicture {
    self.navigationController.delegate = self;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)waterMarkInBrowsePictureCell:(BrowsePictureCell *)cell {
    return [self waterMarkImage];
}

- (NSString *)textInBrowsePictureCell:(BrowsePictureCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return [self waterMarkTextAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDatasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowsePictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BROWSE_PICTURE_CELL_ID forIndexPath:indexPath];
    cell.scaleToMax = self.scaleToMax;
    cell.tag = indexPath.row;
    cell.delegate = self;
    if ([self.delegate respondsToSelector:@selector(browsePictureViewController:imageViewAtIndex:)]) {
        UIImageView *imageView = [self.delegate browsePictureViewController:self imageViewAtIndex:indexPath.row];
        if (imageView.image) [cell updateImageViewWithImage:imageView.image];
    }
    if ([self.delegate respondsToSelector:@selector(browsePictureViewController:downLoadImage:index:)]) {
        [self.delegate browsePictureViewController:self downLoadImage:^(UIImage *image, NSInteger index) {
            if (cell && index == cell.tag) {
                 [cell updateUrlImage:image];
            }
        } index:indexPath.row];
    }
    if (self.scaleToMax) [cell startMotion];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInBrowsePictureViewController:)]) {
        return [self.delegate numberOfImagesInBrowsePictureViewController:self];
    } else {
        return 1;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if (page != self.pageControl.currentPage) {
        self.pageControl.currentPage = page;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        ImageViewApearTransition *transition = [ImageViewApearTransition new];
        transition.isPop = YES;
        return transition;
    } else {
        ImageViewApearTransition *transition = [ImageViewApearTransition new];
        transition.isPop = NO;
        return transition;
    }
}

@end

@implementation UINavigationController (BrowsePictureViewController)

- (void)pushBrowsePictureViewController:(BrowsePictureViewController *)browsePictureViewController {
    self.delegate = browsePictureViewController;
    [self pushViewController:browsePictureViewController animated:YES];
}

@end
