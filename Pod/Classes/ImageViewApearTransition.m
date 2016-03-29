//
//  ImageViewApearTransition.m
//  renyan
//
//  Created by guoshencheng on 12/31/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import "POP.h"
#import "ImageViewApearTransition.h"
#import "BrowsePictureViewController.h"

NSString *const kPOPIMAGEVIEW_APEAR_PROPERTY = @"pop.animtion.image.apear";
NSString *const kIMAGEVIEW_APEAR_TRANSITION_KEY = @"kpop_ImageViewApearTransition";

@implementation UIImage (ImageViewApearTransition)

+ (UIImage *)browseImageWithView:(UIView *)view {
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@interface ImageViewApearTransition ()

@property (assign, nonatomic) CGFloat transitionProgress;

@end

@implementation ImageViewApearTransition {
    UIViewController *fromViewController;
    BrowsePictureViewController *toViewController;
    UIImageView *animationView;
    id<UIViewControllerContextTransitioning> context;
    UIView *originImageView;
    UIImageView *currentImageView;
    UIView *containerView;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    context = transitionContext;
    if (self.isPop) {
        [self animateToPop];
    } else {
        [self animateToPush];
    }
}

#pragma mark - Animations

- (void)animateToPush {
    [self configureValue];
    originImageView.hidden = YES;
    POPBasicAnimation *animation = [self popAnimation];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    [toViewController showHideAllViews:NO];
    [UIView animateWithDuration:0.1 animations:^{
        toViewController.view.alpha = 1;
    } completion:nil];
    
}

- (void)animateToPop {
    [self configureValue];
    originImageView.hidden = YES;
    if ([toViewController.delegate respondsToSelector:@selector(browsePictureViewControllerWillPopBack:)]) {
        [toViewController.delegate browsePictureViewControllerWillPopBack:toViewController];
    }
    POPBasicAnimation *animation = [self popAnimation];
    animation.fromValue = @(1);
    animation.toValue = @(0);
    [UIView animateWithDuration:0.1 animations:^{
        toViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        toViewController.view.hidden = YES;
    }];
}

- (POPBasicAnimation *)popAnimation {
    if ([self pop_animationForKey:kIMAGEVIEW_APEAR_TRANSITION_KEY]) {
        return [self pop_animationForKey:kIMAGEVIEW_APEAR_TRANSITION_KEY];
    }
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [self springAnimationProperty];
    animation.duration = [self transitionDuration:context];
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) self.isPop ? [self handlePopAnimationFinished] : [self handlePushAnimtionFinished];
    };
    [self pop_addAnimation:animation forKey:kIMAGEVIEW_APEAR_TRANSITION_KEY];
    return animation;
}

#pragma mark - AnimtionFinish Handler

- (void)handlePopAnimationFinished {
    originImageView.hidden = NO;
    if ([toViewController.delegate respondsToSelector:@selector(browsePictureViewControllerDidPopBack:)]) {
        [toViewController.delegate browsePictureViewControllerDidPopBack:toViewController];
    }
    [toViewController.view removeFromSuperview];
    [animationView removeFromSuperview];
    [context completeTransition:![context transitionWasCancelled]];
    fromViewController.navigationController.delegate = nil;
}

- (void)handlePushAnimtionFinished {
    [toViewController showHideAllViews:YES];
    originImageView.hidden = NO;
    [fromViewController.view removeFromSuperview];
    [animationView removeFromSuperview];
    [context completeTransition:![context transitionWasCancelled]];
    toViewController.navigationController.delegate = nil;
}

#pragma mark - Progress Control

- (void)setTransitionProgress:(CGFloat)transitionProgress {
    _transitionProgress = transitionProgress;
    animationView.frame = [ImageViewApearTransition rectWithProgress:transitionProgress startRect:[self fromFrame] toRect:[self toFrame]];
    animationView.layer.cornerRadius = [ImageViewApearTransition valueWithProgress:transitionProgress startValue:originImageView.layer.cornerRadius toValue:0];
}

#pragma mark - PrivateMethod

- (CGRect)toFrame {
    if (self.isPop) {
        return [currentImageView convertRect:currentImageView.bounds toView:containerView];
    } else {
        if (toViewController.scaleToMax) {
            return [UIScreen mainScreen].bounds;
        } else {
            CGSize toSize = [ImageViewApearTransition size:[self originImage].size aspectToFitSize:[UIScreen mainScreen].bounds.size];
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            return CGRectMake((screenWidth - toSize.width) / 2, (screenHeight - toSize.height) / 2, toSize.width, toSize.height);
        }
    }
}

- (CGRect)fromFrame {
    return [originImageView convertRect:originImageView.bounds toView:containerView];
}

- (POPBasicAnimation *)popCornerAnimation {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    animation.duration = [self transitionDuration:context];
    return animation;
}

- (POPAnimatableProperty *)springAnimationProperty {
    POPAnimatableProperty *springAnimationProperty = [POPAnimatableProperty propertyWithName:kPOPIMAGEVIEW_APEAR_PROPERTY initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj transitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return springAnimationProperty;
}

+ (CGRect)rectWithProgress:(CGFloat)progress startRect:(CGRect)startRect toRect:(CGRect)toRect {
    CGFloat x = [self valueWithProgress:progress startValue:startRect.origin.x toValue:toRect.origin.x];
    CGFloat y = [self valueWithProgress:progress startValue:startRect.origin.y toValue:toRect.origin.y];
    CGFloat width = [self valueWithProgress:progress startValue:startRect.size.width toValue:toRect.size.width];
    CGFloat height = [self valueWithProgress:progress startValue:startRect.size.height toValue:toRect.size.height];
    return CGRectMake(x, y, width, height);
}

+ (CGFloat)valueWithProgress:(CGFloat)progress startValue:(CGFloat)startValue toValue:(CGFloat)toValue {
    return startValue + (toValue - startValue) * progress;
}

+ (CGSize)size:(CGSize)size aspectToFitSize:(CGSize)toSize {
    if (size.height / size.width > toSize.height / toSize.width) {
        CGFloat scale = size.width / size.height;
        return CGSizeMake(toSize.height * scale, toSize.height);
    } else if (size.height / size.width < toSize.height / toSize.width) {
        CGFloat scale = size.height / size.width;
        return CGSizeMake(toSize.width, toSize.width * scale);
    } else {
        return toSize;
    }
}

- (UIImage *)originImage {
    if ([originImageView isKindOfClass:[UIImageView class]]) {
        return ((UIImageView *)originImageView).image;
    } else {
        return [UIImage browseImageWithView:originImageView];
    }
}

- (void)configureValue {
    [animationView pop_removeAnimationForKey:@"ImageViewApearTransition"];
    [animationView pop_removeAnimationForKey:@"ImageViewApearCornerTransition"];
    fromViewController = self.isPop ? [context viewControllerForKey:UITransitionContextToViewControllerKey] : [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController = (BrowsePictureViewController *)(self.isPop ? [context viewControllerForKey:UITransitionContextFromViewControllerKey] : [context viewControllerForKey:UITransitionContextToViewControllerKey]);
    fromViewController.view.frame = [UIScreen mainScreen].bounds;
    toViewController.view.frame = [UIScreen mainScreen].bounds;
    originImageView = [toViewController currentOriginImageView];
    currentImageView = [toViewController currentImageView];
    containerView = [context containerView];
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    animationView = [[UIImageView alloc] initWithFrame:self.isPop ? [self toFrame] : [self fromFrame]];
    animationView.contentMode = UIViewContentModeScaleAspectFill;
    animationView.clipsToBounds = YES;
    [containerView addSubview:animationView];
    animationView.image = [self originImage];
}

@end
