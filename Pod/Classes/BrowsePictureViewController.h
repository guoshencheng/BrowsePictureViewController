//
//  BrowsePictureViewController.h
//  renyan
//
//  Created by guoshencheng on 12/30/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowsePictureCustomConfig : NSObject

@property (strong, nonatomic) UIImage *waterMarkImge;
@property (strong, nonatomic) NSString *saveString;

+ (instancetype)sharedConfig;

@end

typedef void(^ImageDownLoadFinish)(UIImage *image, NSInteger index);

@protocol BrowsePictureViewControllerDelegate;
@interface BrowsePictureViewController : UIViewController < UINavigationControllerDelegate>

@property (weak, nonatomic) id<BrowsePictureViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL scaleToMax;
@property (assign, nonatomic) NSInteger startPage;

+ (instancetype)create;
- (UIImageView *)currentImageView;
- (UIImageView *)currentOriginImageView;

@end

@protocol BrowsePictureViewControllerDelegate <NSObject>
@optional
- (NSInteger)numberOfImagesInBrowsePictureViewController:(BrowsePictureViewController *)browsePitureViewController;
- (NSString *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController textAtIndex:(NSInteger)index;
- (void)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController downLoadImage:(ImageDownLoadFinish)downLoadImage index:(NSInteger)Index;
- (void)browsePictureViewControllerDidFinishSaving:(BrowsePictureViewController *)browsePictureViewController;

@required
- (UIImageView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index;

@end

@interface UINavigationController (BrowsePictureViewController)

- (void)pushBrowsePictureViewController:(BrowsePictureViewController *)browsePictureViewController;

@end

