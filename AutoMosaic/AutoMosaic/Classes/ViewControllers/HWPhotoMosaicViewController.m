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
@interface HWPhotoMosaicViewController () <ADBannerViewDelegate, ADInterstitialAdDelegate>
{
    UIImage *outputImage;
    UIView *adContainerView;
    ADInterstitialAd *adInterstitial;
}
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
    [self updateDescription];
    
    //AD
    adInterstitial = [[ADInterstitialAd alloc] init];
    adInterstitial.delegate = self;
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
    if (_inputImage){
        _imageView.image = _inputImage;
    }
    [self showAd];
}
- (IBAction)btnCompareReleased:(id)sender {
    if (outputImage){
        _imageView.image = outputImage;
    }
}
- (void)updateDescription{
    NSInteger size =  (NSInteger)_sliderMosaicSize.value * (NSInteger)_sliderSampleSize.value;
    _lbDescription.text = [NSString stringWithFormat:@"Estimated output size: {%ld, %ld}", size, size];
   
}
- (void)showAd{
    if (adInterstitial.loaded)
    {
        adContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:adContainerView];
        [adInterstitial presentInView: adContainerView];
    }
}
#pragma mark - AdBannerDelegate
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Ad failed: %@", error.localizedDescription);
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad banner will be loaded");
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad banner did load");
}

#pragma mark - ad interstitialAd delegate
- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error{
    NSLog(@"Ad failed: %@", error.localizedDescription);
}
- (void)interstitialAdWillLoad:(ADInterstitialAd *)interstitialAd{
    NSLog(@"Ad interstitial will load");
}
- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd{
    NSLog(@"Ad interstitial did load");
}
- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd{
    NSLog(@"Ad interstitial did unload");
//    [self prepareForInterfaceBuilder];
}
- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd{
    NSLog(@"Ad interstitial action did finish");
    [adContainerView removeFromSuperview];
}
@end
