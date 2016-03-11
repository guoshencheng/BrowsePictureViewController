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

@interface ImageViewApearTransition ()

@property (assign, nonatomic) CGFloat transitionProgress;

@end

@implementation ImageViewApearTransition {
    UIViewController *fromViewController;
    BrowsePictureViewController *toViewController;
    UIImageView *animationView;
    id<UIViewControllerContextTransitioning> context;
    UIImageView *originImageView;
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

- (void)animateToPush {
    [self configureValue];
    toViewController.view.hidden = YES;
    POPBasicAnimation *animation = [self popAnimation];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    [self pop_addAnimation:animation forKey:@"ImageViewApearTransition"];
    if (originImageView.layer.cornerRadius != 0) {
        POPBasicAnimation *cornerAnimation = [self popCornerAnimation];
        cornerAnimation.fromValue = @(originImageView.layer.cornerRadius);
        cornerAnimation.toValue = @(0);
        [animationView.layer pop_addAnimation:cornerAnimation forKey:@"ImageViewApearCornerTransition"];
    }
}

- (void)animateToPop {
    [self configureValue];
    originImageView.hidden = YES;
    [UIView animateWithDuration:0.05 animations:^{
        toViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        toViewController.view.hidden = YES;
        POPBasicAnimation *animation = [self popAnimation];
        animation.fromValue = @(1);
        animation.toValue = @(0);
        if (originImageView.layer.cornerRadius != 0) {
            POPBasicAnimation *cornerAnimation = [self popCornerAnimation];
            cornerAnimation.fromValue = @(0);
            cornerAnimation.toValue = @(originImageView.layer.cornerRadius);
            [animationView.layer pop_addAnimation:cornerAnimation forKey:@"ImageViewApearCornerTransition"];
        }
        [self pop_addAnimation:animation forKey:@"ImageViewApearTransition"];
    }];
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
    animationView = [[UIImageView alloc] initWithFrame:[currentImageView convertRect:currentImageView.bounds toView:containerView]];
    animationView.contentMode = UIViewContentModeScaleAspectFill;
    animationView.clipsToBounds = YES;
    [containerView addSubview:animationView];
    animationView.image = originImageView.image;
}

- (POPBasicAnimation *)popAnimation {
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [self springAnimationProperty];
    animation.duration = [self transitionDuration:context];
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            if (self.isPop) {
                originImageView.hidden = NO;
                [toViewController.view removeFromSuperview];
                [animationView removeFromSuperview];
                [context completeTransition:![context transitionWasCancelled]];
                fromViewController.navigationController.delegate = nil;
            } else {
                toViewController.view.alpha = 0;
                toViewController.view.hidden = NO;
                [UIView animateWithDuration:0.05 animations:^{
                    toViewController.view.alpha = 1;
                } completion:^(BOOL finished) {
                    [fromViewController.view removeFromSuperview];
                    [animationView removeFromSuperview];
                    [context completeTransition:![context transitionWasCancelled]];
                    toViewController.navigationController.delegate = nil;
                }];
            }
        }
    };
    return animation;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress {
    _transitionProgress = transitionProgress;
    animationView.frame = [ImageViewApearTransition rectWithProgress:transitionProgress startRect:[self fromFrame] toRect:[self toFrame]];
}

- (CGRect)toFrame {
    if (self.isPop) {
        return [currentImageView convertRect:currentImageView.bounds toView:containerView];
    } else {
        if (toViewController.scaleToMax) {
            return [UIScreen mainScreen].bounds;
        } else {
            CGSize toSize = [ImageViewApearTransition size:animationView.bounds.size aspectToFitSize:[UIScreen mainScreen].bounds.size];
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

@end
