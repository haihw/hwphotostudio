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
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *sliderSampleSize;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *sliderMosaicSize;
@property (weak, nonatomic) IBOutlet UIButton *btnCompare;
@property (weak, nonatomic) IBOutlet UIButton *btnProcess;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbProcessingTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
- (IBAction)btnProcessTapped:(id)sender;
- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender;
- (IBAction)sliderSampleSizeChange:(id)sender;
- (IBAction)sliderMosaicSizeChange:(id)sender;
- (IBAction)btnShareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet GADBannerView *GAdBanner;

@end
