//
//  ImageViewApearTransition.h
//  renyan
//
//  Created by guoshencheng on 12/31/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageViewApearTransition)

+ (UIImage *)browseImageWithView:(UIView *)view;

@end

@interface ImageViewApearTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPop;

@end
