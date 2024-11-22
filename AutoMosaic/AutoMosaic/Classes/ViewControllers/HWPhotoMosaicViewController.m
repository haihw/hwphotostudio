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
@import GoogleMobileAds;
@interface HWPhotoMosaicViewController () <GADBannerViewDelegate, GADFullScreenContentDelegate>
{
    UIImage *outputImage;
    UIView *adContainerView;
    
}
@property(nonatomic, strong) GADInterstitialAd *interstitial;

@end

@implementation HWPhotoMosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView.image = _inputImage;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingMode = NSNumberFormatterRoundDown;
    [_sliderMosaicSize setNumberFormatter:formatter];
    [_sliderSampleSize setNumberFormatter:formatter];
    [_sliderOpacity setNumberFormatter:formatter];
    
    _GAdBanner.adUnitID = kGADBannerUnitID;
    _GAdBanner.rootViewController = self;
    
    self.sliderOpacity.value = 50;
    self.sliderMosaicSize.value = 40;
    self.sliderSampleSize.value = 200;
    [self updateDescription];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_GAdBanner loadRequest:[GADRequest request]];
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
    [self createAndLoadInterstitial];
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:_imageContainerView animated:YES withTitle:@"Processing"];
    hud.mode = MBProgressHUDModeDeterminate;
    _btnCompare.enabled = NO;
    _btnProcess.enabled = NO;
    NSInteger sampleSize = (NSInteger) _sliderSampleSize.value;
    NSInteger mosaicSize = (NSInteger) _sliderMosaicSize.value;
    NSInteger opacity = (NSInteger) _sliderOpacity.value;
    NSDate *startTime = [NSDate date];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Do something...
        NSDictionary *params = @{
                                 @"metric":@"1", //riemersmaDistanceTo
                                 @"dx"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"dy"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"width" :[NSNumber numberWithInteger:sampleSize],
                                 @"height":[NSNumber numberWithInteger:sampleSize],
                                 @"opacity":[NSNumber numberWithInteger:opacity]
                                 };
        NSArray *copiedMetaPhotos = [self.metaPhotos mutableCopy];
        //shadow copy to prevent changing to original array
        [self.inputImage createMosaicWithMetaPhotos: copiedMetaPhotos params:params progress:^(float percentage, UIImage *mosaicImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (mosaicImage){
                    self.btnCompare.enabled = YES;
                    self.btnProcess.enabled = YES;
                    
                    self.imageView.image = mosaicImage;
                    self->outputImage = mosaicImage;
                    self.lbDescription.text = [NSString stringWithFormat:@"Result size: %0.2f Megapixels", 1.0f * mosaicImage.size.height * mosaicImage.size.width / 1024 / 1024];
                    float time = [[NSDate date] timeIntervalSinceDate:startTime];
                    self.lbProcessingTime.text = [NSString stringWithFormat:@"Process time: %0.2f s", time];
                    //                    UIImageWriteToSavedPhotosAlbum(mosaicImage, nil, nil, nil);
                    [self showAd];
                    [HWProgressHUD hideHUDForView: self.imageContainerView animated:YES];
                }
                
                hud.detailsLabel.text = [NSString stringWithFormat:@"%0.1f%%", percentage*100];
                hud.progress = percentage;
            });
        }];
    });
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    JTSImageInfo *jtsImgInfo = [[JTSImageInfo alloc] init];
    jtsImgInfo.image = _imageView.image;
    
    JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:jtsImgInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    imageViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [imageViewController showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (IBAction)sliderSampleSizeChange:(id)sender {
    [self updateDescription];
}
- (IBAction)sliderMosaicSizeChange:(id)sender {
    [self updateDescription];
}
- (IBAction)sliderMosaicOpacityChange:(id)sender{
//    [self updateDescription];
}

- (IBAction)btnMoreSettingTapped:(id)sender {
    NSArray *titles = @[@"More", @"Less"];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.btnMoreSetting setTitle:titles[self.stackSettingView.hidden]
                             forState:UIControlStateNormal];
        self.stackSettingView.hidden = !self.stackSettingView.hidden;
    } completion:nil];
}

- (IBAction)btnShareTapped:(id)sender {
    UIImage *image = _imageView.image;
    NSString *message = @"My mosaic photo by #mosaicify";
    NSArray *postItems = @[message, image];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}
- (IBAction)btnComparePressed:(id)sender {
    if (_inputImage){
        _imageView.image = _inputImage;
    }
}
- (IBAction)btnCompareReleased:(id)sender {
    if (outputImage){
        _imageView.image = outputImage;
    }
}
- (void)updateDescription{
    NSInteger size =  (NSInteger)_sliderMosaicSize.value * (NSInteger)_sliderSampleSize.value;
    _lbDescription.text = [NSString stringWithFormat:@"Estimated output: %0.2f Megapixels", 1.0f * size * size / 1024 / 1024];
    
    NSString *complexity;
    float range = _sliderSampleSize.maximumValue - _sliderSampleSize.minimumValue;
    if (_sliderSampleSize.value > _sliderSampleSize.minimumValue + range*0.67f){
        complexity = @"Slow";
    } else if (_sliderSampleSize.value < _sliderSampleSize.minimumValue + range*0.33f){
        complexity = @"Fast";
    } else {
        complexity = @"Medium";
    }
    _lbProcessingTime.text = [NSString stringWithFormat:@"Estimated time: %@", complexity];
   
}
- (void)showAd{
    if (self.interstitial) {
      // The UIViewController parameter is nullable.
      [self.interstitial presentFromRootViewController:nil];
    } else {
      NSLog(@"Ad wasn't ready");
    }
}
- (void)createAndLoadInterstitial {
//    interstitial = [[GADInterstitial alloc] initWithAdUnitID:kGADInterstitialUnitID];
//    interstitial.delegate = self;
//    
//    GADRequest *request = [GADRequest request];
//    // Request test ads on devices you specify. Your test device ID is printed to the console when
//    // an ad request is made. GADInterstitial automatically returns test ads when running on a
//    // simulator.
//    [interstitial loadRequest:request];
//    
    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:kGADInterstitialUnitID
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            return;
        }
        self.interstitial = ad;
        self.interstitial.fullScreenContentDelegate = self;
    }];

}

#pragma mark GADInterstitialDelegate implementation
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"Ad did dismiss full screen content.");
}

#pragma mark GADBannerViewDelegate implementation
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    [_GAdBanner performSelector:@selector(loadRequest:) withObject:[GADRequest request] afterDelay:5];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidDismissScreen");
}
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSLog(@"GAd banner did receive ad");
}
@end
