//
//  HWPhotoMosaicViewController.m
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HWPhotoMosaicViewController.h"
#import "UIImage+HWMosaic.h"
#import "HWProgressHUD.h"
#import "HWSettingViewController.h"
#import "JTSImageViewController.h"
#import "ASValueTrackingSlider.h"
@interface HWPhotoMosaicViewController ()
{
    UIImage *outputImage;
}
@end

@implementation HWPhotoMosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView.image = _inputImage;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [_sliderMosaicSize setNumberFormatter:formatter];
    [_sliderSampleSize setNumberFormatter:formatter];
    [self updateDescription];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnProcessTapped:(id)sender {
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:self.view animated:YES withTitle:@"Processing"];
    hud.mode = MBProgressHUDModeDeterminate;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        NSInteger sampleSize = (NSInteger) _sliderSampleSize.value;
        NSInteger mosaicSize = (NSInteger) _sliderMosaicSize.value;
        NSDictionary *params = @{
                                 @"metric":@"1", //riemersmaDistanceTo
                                 @"dx"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"dy"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"width" :[NSNumber numberWithInteger:sampleSize],
                                 @"height":[NSNumber numberWithInteger:sampleSize],
                                 };
        [_inputImage createMosaicWithMetaPhotos:_metaPhotos params:params progress:^(float percentage, UIImage *mosaicImage) {
            if (mosaicImage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.image = mosaicImage;
                    outputImage = mosaicImage;
                    UIImageWriteToSavedPhotosAlbum(mosaicImage, nil, nil, nil);
                    [HWProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
            hud.detailsLabelText = [NSString stringWithFormat:@"Processing %0.1f%%", percentage*100];
            hud.progress = percentage;
        }];
    });
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    JTSImageInfo *jtsImgInfo = [[JTSImageInfo alloc] init];
    jtsImgInfo.image = _imageView.image;
    
    JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:jtsImgInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    [imageViewController showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

- (IBAction)sliderSampleSizeChange:(id)sender {
    [self updateDescription];
}
- (IBAction)sliderMosaicSizeChange:(id)sender {
    [self updateDescription];
}
- (IBAction)btnComparePressed:(id)sender {
    _imageView.image = _inputImage;
}
- (IBAction)btnCompareReleased:(id)sender {
    _imageView.image = outputImage;
}
- (void)updateDescription{
    NSInteger size =  (NSInteger)_sliderMosaicSize.value * (NSInteger)_sliderSampleSize.value;
    _lbDescription.text = [NSString stringWithFormat:@"Estimated output size: {%ld, %ld}", size, size];
   
}
@end
