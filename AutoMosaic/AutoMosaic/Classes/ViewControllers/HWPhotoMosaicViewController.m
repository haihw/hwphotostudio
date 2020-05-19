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
#import <GoogleMobileAds/GoogleMobileAds.h>
@interface HWPhotoMosaicViewController () <ADBannerViewDelegate, ADInterstitialAdDelegate, GADInterstitialDelegate, GADBannerViewDelegate>
{
    UIImage *outputImage;
    UIView *adContainerView;
    ADInterstitialAd *adInterstitial;
    GADInterstitial *interstitial;
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
    
    _GAdBanner.adUnitID = kGADBannerUnitID;
    _GAdBanner.rootViewController = self;
    [_GAdBanner loadRequest:[GADRequest request]];

//    _iAdTopBanner.hidden = YES;
    _GAdBanner.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [_GAdBanner loadRequest:[GADRequest request]];
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
    [self createAndLoadInterstitial];
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:_imageContainerView animated:YES withTitle:@"Processing"];
    hud.mode = MBProgressHUDModeDeterminate;
    _btnCompare.enabled = NO;
    _btnProcess.enabled = NO;
    NSInteger sampleSize = (NSInteger) _sliderSampleSize.value;
    NSInteger mosaicSize = (NSInteger) _sliderMosaicSize.value;

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        NSDictionary *params = @{
                                 @"metric":@"1", //riemersmaDistanceTo
                                 @"dx"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"dy"    :[NSNumber numberWithInteger:mosaicSize],
                                 @"width" :[NSNumber numberWithInteger:sampleSize],
                                 @"height":[NSNumber numberWithInteger:sampleSize],
                                 };
        [_inputImage createMosaicWithMetaPhotos:_metaPhotos params:params progress:^(float percentage, UIImage *mosaicImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (mosaicImage){
                    _btnCompare.enabled = YES;
                    _btnProcess.enabled = YES;
                    
                    _imageView.image = mosaicImage;
                    outputImage = mosaicImage;
                    //                    UIImageWriteToSavedPhotosAlbum(mosaicImage, nil, nil, nil);
                    [self showAd];
                    [HWProgressHUD hideHUDForView:_imageContainerView animated:YES];
                }
                
                hud.detailsLabel.text = [NSString stringWithFormat:@"Processing %0.1f%%", percentage*100];
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
    _lbDescription.text = [NSString stringWithFormat:@"Estimated output size: {%ld, %ld}", size, size];
   
}
- (void)showAd{
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:self];
    } else if (adInterstitial.loaded)
    {
        adContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:adContainerView];
        [adInterstitial presentInView: adContainerView];
    }
}
- (void)createAndLoadInterstitial {
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:kGADInterstitialUnitID];
    interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.
    [interstitial loadRequest:request];
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
}

#pragma mark GADBannerViewDelegate implementation
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSLog(@"GAd banner did receive ad");
    _GAdBanner.hidden = NO;
    _iAdTopBanner.hidden = YES;
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"GAd failed: %@", error.localizedDescription);
    _GAdBanner.hidden = YES;
    _iAdTopBanner.hidden = NO;
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
    if (_GAdBanner.hidden){
        _iAdTopBanner.hidden = NO;
    }
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
