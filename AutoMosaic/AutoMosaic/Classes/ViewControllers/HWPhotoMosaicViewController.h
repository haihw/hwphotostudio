//
//  HWPhotoMosaicViewController.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
@class ASValueTrackingSlider, GADBannerView;
@interface HWPhotoMosaicViewController : UIViewController
@property (strong) UIImage *inputImage;
@property (strong) NSMutableArray *metaPhotos;
@property (strong, nonatomic) IBOutlet ASValueTrackingSlider *sliderSampleSize;
@property (strong, nonatomic) IBOutlet ASValueTrackingSlider *sliderMosaicSize;
@property (strong, nonatomic) IBOutlet UIButton *btnCompare;
@property (strong, nonatomic) IBOutlet UIButton *btnProcess;
@property (strong, nonatomic) IBOutlet UILabel *lbDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;
- (IBAction)btnProcessTapped:(id)sender;
- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender;
- (IBAction)sliderSampleSizeChange:(id)sender;
- (IBAction)sliderMosaicSizeChange:(id)sender;
- (IBAction)btnShareTapped:(id)sender;
@property (strong, nonatomic) IBOutlet ADBannerView *iAdTopBanner;
@property (strong, nonatomic) IBOutlet GADBannerView *GAdBanner;

@end
