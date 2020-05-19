//
//  ViewController.m
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//
@import GoogleMobileAds;
@import Photos;
@import PhotosUI;
#import "ViewController.h"
#import "HwPhotoHelper.h"
#import "HWProgressHUD.h"
#import "HWPhotoMosaicViewController.h"
#import "MetaPhoto.h"
#import "UIImage+HWMosaic.h"
@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIImage *inputImage;
    NSMutableArray *libraryMetaPhotos;
    IBOutlet GADBannerView *gaBannerView;
    NSArray <PHAssetCollection*> *imageCollections;
    NSInteger selectedAlbumIndex;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    gaBannerView.adUnitID = kGADBannerUnitID;
    gaBannerView.rootViewController = self;
    [gaBannerView loadRequest:[GADRequest request]];
//    [self scanLibrary];
    imageCollections = [HwPhotoHelper getAllPhotoAlbums];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [gaBannerView loadRequest:[GADRequest request]];
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scanLibrary
{
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:self.view
                                         dimBackground:YES
                                              animated:YES
                                             withTitle:@"Scanning library..."];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        libraryMetaPhotos = [NSMutableArray array];
//        PHAssetCollection *collection;
//        if (selectedAlbumIndex == 0){
//            //all photos
//        } else {
//            collection = imageCollections[selectedAlbumIndex - 1];
//        }
//        NSMutableArray *onePixels = [NSMutableArray new];
//        NSArray *thumbnails = [HwPhotoHelper getAllThumbnailPhotosFromAlbum:collection onePixels:onePixels];
        [HwPhotoHelper getAllThumbnailPhotosFromLibraryWithResponse:^(NSMutableArray *thumbnails) {
            //process thumbnails
            NSInteger imageCount = thumbnails.count;
            __block NSInteger index = 0;
            NSDate *startDate = [NSDate date];
            for (UIImage *image in thumbnails)
            {
                MetaPhoto *metaPhoto = [[MetaPhoto alloc] init];
                metaPhoto.photo = image;
                metaPhoto.averageColor = image.mergedColor;
                [libraryMetaPhotos addObject:metaPhoto];
                index ++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.detailsLabel.text = [NSString stringWithFormat: @"Processing %ld/%ld...", index, imageCount];
                    hud.progress = 1.0f * index/imageCount;
                });
            }
            NSLog(@"Scan library done: %f", -[startDate timeIntervalSinceNow]);

            dispatch_async(dispatch_get_main_queue(), ^{
                [HWProgressHUD hideHUDForView:self.view animated:YES];
                _lbPhotoNumber.text = [NSString stringWithFormat:@"%ld photos loaded", thumbnails.count];

            });
            
        }];
    });

}
- (IBAction)btnScanLibraryTapped:(id)sender {
    [self scanLibrary];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    inputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSegueWithIdentifier:@"mosaicSegue" sender:self];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showImagePickerSegue"])
    {
        UIImagePickerController *controller = [[segue destinationViewController] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"mosaicSegue"])
    {
        HWPhotoMosaicViewController *viewController = [segue destinationViewController];
        viewController.inputImage = inputImage;
        viewController.metaPhotos = libraryMetaPhotos;
    }
}

- (IBAction)startOver:(UIStoryboardSegue *)unwindSegue
{
}
#pragma mark addelegate
-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%@", error.localizedDescription);
}
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSLog(@"Ad received");
}

#pragma mark picker view
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return imageCollections.count + 1;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row == 0){
        return @"All Photos";
    }
    return imageCollections[row-1].localizedTitle;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedAlbumIndex = row;
}
@end
