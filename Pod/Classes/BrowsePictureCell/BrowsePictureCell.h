//
//  BrowsePictureCell.h
//  renyan
//
//  Created by guoshencheng on 12/30/15.
//  Copyright © 2015 zixin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BROWSE_PICTURE_CELL_NIBNAME @"BrowsePictureCell"
#define BROWSE_PICTURE_CELL_ID @"BrowsePictureCell"


@protocol BrowsePictureCellDelegate;
@interface BrowsePictureCell : UICollectionViewCell<UIScrollViewDelegate>

@property (weak, nonatomic) id<BrowsePictureCellDelegate> delegate;
@property (assign, nonatomic) BOOL scaleToMax;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)updateImageViewWithImage:(UIImage *)image;
- (void)updateUrlImage:(UIImage *)image;
- (void)startMotion;

@end

@protocol BrowsePictureCellDelegate <NSObject>
@optional
- (void)browsePictureCellDidTapImage:(BrowsePictureCell *)browsePicture;
- (UIImage *)waterMarkInBrowsePictureCell:(BrowsePictureCell *)cell;
- (NSString *)textInBrowsePictureCell:(BrowsePictureCell *)cell;

@end