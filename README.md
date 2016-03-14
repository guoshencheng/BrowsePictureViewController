# BrowsePictureViewController

[![CI Status](http://img.shields.io/travis/guoshencheng/BrowsePictureViewController.svg?style=flat)](https://travis-ci.org/guoshencheng/BrowsePictureViewController)
[![Version](https://img.shields.io/cocoapods/v/BrowsePictureViewController.svg?style=flat)](http://cocoapods.org/pods/BrowsePictureViewController)
[![License](https://img.shields.io/cocoapods/l/BrowsePictureViewController.svg?style=flat)](http://cocoapods.org/pods/BrowsePictureViewController)
[![Platform](https://img.shields.io/cocoapods/p/BrowsePictureViewController.svg?style=flat)](http://cocoapods.org/pods/BrowsePictureViewController)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Dependence

- [Masonry](https://github.com/SnapKit/Masonry) `Harness the power of AutoLayout NSLayoutConstraints with a simplified, chainable and expressive syntax. Supports iOS and OSX Auto Layout`
- [POP](https://github.com/facebook/pop) `An extensible iOS and OS X animation library, useful for physics-based interactions.`

## Requirements

iOS 7 or higher

## Installation

BrowsePictureViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BrowsePictureViewController"
```

## Classes

###BrowsePictureCustomConfig

- `waterMarkImge`:Make a watermark if need, this property configure the image of watermark </br>
- `saveString`: The string in the left bottom, just prepare for localizing </br>
- `+ (instancetype)sharedConfig;` : Return the shared config object global

###ImageViewApearTransition
`The animation for pushing BrowseViewController, use facebook pop animation, useing BasePopAnimation temporarily`

###UIImage (WaterMark)

```objc
- (UIImage *)addMsakImage:(UIImage *)maskImage text:(NSString *)text msakRect:(CGRect)msakRect textRect:(CGRect)textRect fontSize:(CGFloat)fontSize;
```
Utility Extension Category for add water mark

###BrowsePictureViewController
The Controller for Browse picture

`typedef void(^ImageDownLoadFinish)(UIImage *image, NSInteger index);` ： A block for download image

####Public Method
- `+ (instancetype)create` : the function for create BrowsePictureViewController
- `- (UIImageView *)currentImageView` return the current ImageView browsing
- `- (UIImageView *)currentOriginImageView` return the current origin ImageView (this function just redirect the tast to Delegate `- (UIImageView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index`)
- `- (void)showHideAllViews:(BOOL)show` show hide some views in animation

#####_For all public functions, just the `create` is useful the users, others is used to make animation_

####Delegate

#####optional
- `- (NSInteger)numberOfImagesInBrowsePictureViewController:(BrowsePictureViewController *)browsePitureViewController;` : return the number of Images in BrowsePictureViewController
- `- (NSString *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController textAtIndex:(NSInteger)index;`: return the text which will be made a water mark if need
- `- (void)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController downLoadImage:(ImageDownLoadFinish)downLoadImage index:(NSInteger)Index;` : down loadimage delegate, the download function is made a delegate for muti implements of download image
- `- (void)browsePictureViewControllerDidFinishSaving:(BrowsePictureViewController *)browsePictureViewController;` : the delegate for notification of finish saving

#####required
- `- (UIImageView *)browsePictureViewController:(BrowsePictureViewController *)browsePictureViewController imageViewAtIndex:(NSInteger)index;` : return imageview for index

###UINavigationController (BrowsePictureViewController)

`A extension category for push BrowsePictureViewController`

For pushing BrowsePictureViewController, make sure to use the function `- (void)pushBrowsePictureViewController:(BrowsePictureViewController *)browsePictureViewController;` to push

## Author

Century guo, guoshencheng1@gmail.com

## License

BrowsePictureViewController is available under the MIT license. See the LICENSE file for more info.
