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
@import AssetsLibrary;
#import "ViewController.h"
#import "HwPhotoHelper.h"
#import "HWProgressHUD.h"
#import "HWPhotoMosaicViewController.h"
#import "MetaPhoto.h"
#import "UIImage+HWMosaic.h"
@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    __weak IBOutlet UIPickerView *albumPicker;
    UIImage *inputImage;
    NSMutableArray *libraryMetaPhotos;
    __weak IBOutlet GADBannerView *gaBannerView;
    NSArray <PHAssetCollection*> *imageCollections;
//    NSArray <ALAssetsGroup*> *imageGroups;
    NSInteger selectedAlbumIndex;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Google Mobile Ads SDK version: %ld", (long)[GADRequest version]);
    gaBannerView.adUnitID = kGADBannerUnitID;
    gaBannerView.rootViewController = self;
    
}
- (void)loadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [HWProgressHUD showHUDAddedTo:self.view
                        dimBackground:YES
                             animated:YES
                            withTitle:@"Scanning library..."];
    });
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self->imageCollections = [HwPhotoHelper getAllPhotoAlbums];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->albumPicker reloadAllComponents];
            [HWProgressHUD hideHUDForView:self.view animated:YES];
        });
    });

}
- (void)viewDidAppear:(BOOL)animated
{
#ifndef DEBUG
    [gaBannerView loadRequest:[GADRequest request]];
#endif

    [self requestAuthorizationWithRedirectionToSettings];
    [super viewDidAppear:animated];
}
- (void)requestAuthorizationWithRedirectionToSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            //We have permission. Do whatever is needed
            [self loadData];
        } else {
            //No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self loadData];
                } else {
                    //User don't give us permission. Showing alert with redirection to settings
                    //Getting description string from info.plist file
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alertController animated:YES completion:nil];
                    });
                }
            }];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**new API but slower*/
- (void)scanLibrary
{
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:self.view
                                         dimBackground:YES
                                              animated:YES
                                             withTitle:@"Scanning library..."];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self->libraryMetaPhotos = [NSMutableArray array];
        PHAssetCollection *collection;
        NSMutableArray *onePixels = [NSMutableArray new];
        NSArray *thumbnails;

        collection = self->imageCollections[self->selectedAlbumIndex];
        thumbnails = [HwPhotoHelper getAllThumbnailPhotosFromAlbum:collection onePixels:onePixels];
//        NSAssert(onePixels.count == thumbnails.count, @"corrupted data");
        //process thumbnails
        NSInteger imageCount = thumbnails.count;
        __block NSInteger index = 0;
        NSDate *startDate = [NSDate date];

        for (int i=0; i<imageCount; i++)
        {
            MetaPhoto *metaPhoto = [[MetaPhoto alloc] init];
            metaPhoto.photo = thumbnails[i];
            UIImage * onePixel = thumbnails[i];
            metaPhoto.averageColor = onePixel.mergedColor;
            [self->libraryMetaPhotos addObject:metaPhoto];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.detailsLabel.text = [NSString stringWithFormat: @"Processing %d/%ld...", i, (long)imageCount];
                hud.progress = 1.0f * index/imageCount;
            });
        }
        NSLog(@"Scan library done: %f", -[startDate timeIntervalSinceNow]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HWProgressHUD hideHUDForView:self.view animated:YES];
            self->_lbPhotoNumber.text = [NSString stringWithFormat:@"%lu photos loaded", (unsigned long)thumbnails.count];
            
        });
        

    });

}
//old
- (void)scanLibrary2
{
    /*
    HWProgressHUD *hud = [HWProgressHUD showHUDAddedTo:self.view
                                         dimBackground:YES
                                              animated:YES
                                             withTitle:@"Scanning library..."];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        libraryMetaPhotos = [NSMutableArray array];
        ALAssetsGroup *group = imageGroups[selectedAlbumIndex];
        [HwPhotoHelper getThumbnailsFromGroup:group response:^(NSMutableArray *thumbnails) {
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
                    hud.detailsLabel.text = [NSString stringWithFormat: @"Processing %ld/%ld...", (long)index, (long)imageCount];
                    hud.progress = 1.0f * index/imageCount;
                });
                
            }
            NSLog(@"Scan library done: %f", -[startDate timeIntervalSinceNow]);

            dispatch_async(dispatch_get_main_queue(), ^{
                [HWProgressHUD hideHUDForView:self.view animated:YES];
                _lbPhotoNumber.text = [NSString stringWithFormat:@"%d photos loaded", thumbnails.count];

            });
            
        }];
    });
*/
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
- (BOOL) isReadyToMosaicify{
    if (libraryMetaPhotos.count == 0){
        _lbPhotoNumber.text = @"0 photo loaded. Please select album and start scan library first";
    }
    

    return libraryMetaPhotos.count > 0;
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"showImagePickerSegue"]){
        return [self isReadyToMosaicify];
    } else if ([identifier isEqualToString:@"mosaicSegue"])
    {
        return [self isReadyToMosaicify] && inputImage != nil;
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showImagePickerSegue"]){
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
//-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    NSLog(@"%@", error.localizedDescription);
//    [gaBannerView performSelector:@selector(loadRequest:) withObject:[GADRequest request] afterDelay:5];
//}
//- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
//    NSLog(@"Ad received");
//}

#pragma mark picker view
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    NSLog(@"picker: %d", imageGroups.count);
//    return imageGroups.count;
    NSLog(@"picker: %d", (int)imageCollections.count);
    return imageCollections.count;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    ALAssetsGroup *group = imageGroups[row];
//    NSString *title  = [group valueForProperty:ALAssetsGroupPropertyName];
//    NSLog(@"picker: %@", title);
//    return title;
    NSLog(@"picker: %@", imageCollections[row].localizedTitle);
    return imageCollections[row].localizedTitle;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedAlbumIndex = row;
}
@end
