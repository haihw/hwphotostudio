//
//  HWPhotoMosaicViewController.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASValueTrackingSlider;
@interface HWPhotoMosaicViewController : UIViewController
@property (strong) UIImage *inputImage;
@property (strong) NSMutableArray *metaPhotos;
@property (strong, nonatomic) IBOutlet ASValueTrackingSlider *sliderSampleSize;
@property (strong, nonatomic) IBOutlet ASValueTrackingSlider *sliderMosaicSize;
@property (strong, nonatomic) IBOutlet UILabel *lbDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)btnProcessTapped:(id)sender;
- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender;
- (IBAction)sliderSampleSizeChange:(id)sender;
- (IBAction)sliderMosaicSizeChange:(id)sender;

@end
