//
//  BrowsePictureCell.m
//  renyan
//
//  Created by guoshencheng on 12/30/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import "BrowsePictureCell.h"
#import <CoreMotion/CoreMotion.h>

#define BROWSE_PICTURE_CELL_DEFAULT_MAX_SCALE 2
#define BROWSE_PICTURE_CELL_DEFAULT_SCALE 1

@interface BrowsePictureCell ()

@property (nonatomic) CMMotionManager *motionManger;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *waterMarkIcon;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation BrowsePictureCell{
    CGFloat _previousValue;
}

- (void)awakeFromNib {
    [self configureScrollView];
    [self addTapGesture];
}

- (void)makeShadowWithLabelWord:(UILabel *)label font:(UIFont *)font {
    if (label.text && label.text.length > 0) {
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowBlurRadius = 1.0;
        shadow.shadowColor = [UIColor blackColor];
        CGFloat offset = 0.5 / 8 * font.pointSize;
        shadow.shadowOffset = CGSizeMake(offset, offset);
        NSDictionary *attributeDic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor],NSShadowAttributeName:shadow,NSVerticalGlyphFormAttributeName:@(0)};
        label.attributedText = [[NSAttributedString alloc]initWithString:label.text attributes:attributeDic];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stopMotion];
}

- (void)updateImageViewWithImage:(UIImage *)image {
    _previousValue = 0;
    [self updateTextAndWaterMark];
    self.imageView.image = image;
    self.image = image;
    if (image) {
        [self updateScrollView];
    }
}

- (void)updateUrlImage:(UIImage *)image {
    if (self.image) {
        self.imageView.image = image;
        self.image = image;
    } else {
        [self updateImageViewWithImage:image];
    }
}

- (void)updateTextAndWaterMark {
    self.waterMarkIcon.image = nil;
    self.albumNameLabel.text = nil;
    if ([self.delegate respondsToSelector:@selector(waterMarkInBrowsePictureCell:)]) {
        self.waterMarkIcon.image = [self.delegate waterMarkInBrowsePictureCell:self];
    }
    if ([self.delegate respondsToSelector:@selector(textInBrowsePictureCell:)]) {
        self.albumNameLabel.text = [self.delegate textInBrowsePictureCell:self];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   [self stopMotion];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self stopMotion];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _previousValue = scrollView.contentOffset.x;
    [self centerScrollViewContents];
}

#pragma mark - PrivateMethod

- (void)updateScrollView {
    self.scrollView.frame = self.bounds;
    [self.scrollView setZoomScale:BROWSE_PICTURE_CELL_DEFAULT_SCALE];
    CGRect frame = self.scrollView.frame;
    CGSize imageSize = self.image.size;
    CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    if (frame.size.width <= frame.size.height) {
        CGFloat ratio = frame.size.width/imageFrame.size.width;
        imageFrame.size.height = imageFrame.size.height * ratio;
        imageFrame.size.width = frame.size.width;
    }else{
        CGFloat ratio = frame.size.height/imageFrame.size.height;
        imageFrame.size.width = imageFrame.size.width * ratio;
        imageFrame.size.height = frame.size.height;
    }
    self.containerView.frame = imageFrame;
    CGFloat width = imageFrame.size.width * 0.1;
    CGFloat height = imageFrame.size.width * 0.1 * 22.0 / 40;
    CGFloat fontSize = imageFrame.size.width * 0.025;
    [self makeShadowWithLabelWord:self.albumNameLabel font:[UIFont systemFontOfSize:fontSize]];
    self.albumNameLabel.font = [UIFont systemFontOfSize:fontSize];
    self.waterMarkIcon.frame = CGRectMake((imageFrame.size.width - width) / 2, imageFrame.size.height - (fontSize + 9 + height), width, height);
    self.albumNameLabel.frame = CGRectMake((imageFrame.size.width - 320) / 2, imageFrame.size.height - (fontSize + 8), 320, (fontSize + 1));
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.contentSize = self.image.size;
    [self.scrollView setMaximumZoomScale:[self calculatePictureScrollViewMaxZoomScale]];
    [self.scrollView setMinimumZoomScale:[self calculatePictureScrollViewMinZoomScale]];
    [self.scrollView setZoomScale:self.scaleToMax ? [self calculatePictureScrollViewMaxZoomScale] : [self calculatePictureScrollViewMinZoomScale]];
    [self centerScrollViewContents];
}

- (void)configureScrollView {
    self.bounds = [UIScreen mainScreen].bounds;
    self.scrollView.delegate = self;
    [self.scrollView.layer setMasksToBounds:NO];
}

- (void)addTapGesture {
    UITapGestureRecognizer *singleTapViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapViewGestureAction:)];
    [self addGestureRecognizer:singleTapViewRecognizer];
    UITapGestureRecognizer *doubleTapViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapViewGestureAction:)];
    doubleTapViewRecognizer.numberOfTapsRequired = 2;
    [singleTapViewRecognizer requireGestureRecognizerToFail:doubleTapViewRecognizer];
    [self addGestureRecognizer:doubleTapViewRecognizer];
}

- (void)singleTapViewGestureAction:(UITapGestureRecognizer *)gesture {
    [self stopMotion];
    if ([self.delegate respondsToSelector:@selector(browsePictureCellDidTapImage:)]) {
        [self.delegate browsePictureCellDidTapImage:self];
    }
}

- (void)doubleTapViewGestureAction:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale == BROWSE_PICTURE_CELL_DEFAULT_SCALE) {
        [self.scrollView setZoomScale:[self calculatePictureScrollViewMaxZoomScale] animated:YES];
        [self startMotion];
    } else {
        [self.scrollView setZoomScale:BROWSE_PICTURE_CELL_DEFAULT_SCALE animated:YES];
        [self stopMotion];
    }
}

- (CGFloat)calculatePictureScrollViewMaxZoomScale {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.image.size.height * [UIScreen mainScreen].bounds.size.width / self.image.size.width);
    CGFloat scale = [BrowsePictureCell scaleOfsize:imageSize toAspectFillSize:screenSize];
    return scale;
}

- (CGFloat)calculatePictureScrollViewMinZoomScale {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.image.size.height * [UIScreen mainScreen].bounds.size.width / self.image.size.width);
    CGFloat scale = [BrowsePictureCell scaleOfSize:imageSize toAspectFitSize:screenSize];
    return scale;
}

- (void)centerScrollViewContents {
    self.containerView.center = [self centerOfScrollViewContent:self.scrollView];
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)stopMotion {
    if (self.motionManger.deviceMotionActive) {
        [self.motionManger stopDeviceMotionUpdates];
    }
}

- (void)newOffsetWithValue:(CGFloat)value {
    if (self.scrollView.contentSize.width == [UIScreen mainScreen].bounds.size.width) {
        return;
    }
    _previousValue += value;
    if (_previousValue < 0) {
        _previousValue = 0;
    } else if (_previousValue > self.scrollView.contentSize.width - [UIScreen mainScreen].bounds.size.width) {
        _previousValue = self.scrollView.contentSize.width - [UIScreen mainScreen].bounds.size.width;
    }
}

- (void)startMotion {
    if (!self.motionManger.deviceMotionActive) {
        if (self.motionManger.deviceMotionAvailable) {
            self.motionManger.deviceMotionUpdateInterval = 0.01;
            [self.motionManger startDeviceMotionUpdatesToQueue:self.operationQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                if (error) {
                    return;
                }
                if (motion) {
                    CGFloat rotationRateY = floorf(motion.rotationRate.y * 1000)/100;
                    if (fabs(rotationRateY) < 1) {
                        return;
                    }
                    [self newOffsetWithValue:rotationRateY];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
                            [_scrollView setContentOffset:CGPointMake(_previousValue, 0) animated:NO];
                        } completion:nil];
                    });
                }
            }];
        }
    }
}
- (CMMotionManager *)motionManger {
    if (_motionManger) {
        return _motionManger;
    }
    _motionManger = [CMMotionManager new];
    return _motionManger;
}

- (NSOperationQueue *)operationQueue {
    if (_operationQueue) {
        return _operationQueue;
    }
    _operationQueue = [NSOperationQueue new];
    return _operationQueue;
}

+ (float)scaleOfsize:(CGSize)scaleSize toAspectFillSize:(CGSize)size {
    if ((scaleSize.width / scaleSize.height)  >= (size.width / size.height)) {
        return size.height / scaleSize.height;
    } else {
        return size.width / scaleSize.width;
    }
}

+ (float)scaleOfSize:(CGSize)scaleSize toAspectFitSize:(CGSize)size {
    if ((scaleSize.width / scaleSize.height)  >= (size.width / size.height)) {
        return size.width / scaleSize.width;
    } else {
        return size.height / scaleSize.height;
    }
}

@end
