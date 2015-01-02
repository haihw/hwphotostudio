//
//  ViewController.m
//  LightestResizeImageApp
//
//  Created by Hai Hw on 2/1/15.
//  Copyright (c) 2015 Hai Hw. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

#define kTagImport 101
#define kTagExport 102
@interface ViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate>
{
    UIImage *originalImage;
    NSMutableDictionary *metadata;
    CGSize desiredSize;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderChanged:(id)sender {
    desiredSize = CGSizeMake(floorf(originalImage.size.width * _slider.value), floorf(originalImage.size.height * _slider.value));
    [self updateInfo];
}

- (IBAction)btnImportTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Import Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", @"Paste", nil];
    actionSheet.tag = kTagImport;
    [actionSheet showInView:self.view];
}

- (IBAction)btnCropTapped:(id)sender {
}

- (IBAction)btnResizeTapped:(id)sender {
    _slider.hidden = NO;
}

- (IBAction)btnRotateTapped:(id)sender {
}

- (IBAction)btnExportTapped:(id)sender {
    if (originalImage){
        UIImage *newImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:desiredSize interpolationQuality:kCGInterpolationHigh];

        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[newImage, @"My Photo"]
                                                                                 applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Export Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save To Library", @"iMessage", @"Mail", nil];
//        actionSheet.tag = kTagExport;
//        [actionSheet showInView:self.view];
    }
}
- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kTagImport){
        switch (buttonIndex) {
            case 0:
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:picker animated:YES completion:nil];
                
                break;
            }
            case 1:
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
                
                break;
            }
            case 2:
            {
                originalImage = [UIPasteboard generalPasteboard].image;
                desiredSize = originalImage.size;
                [self updateInfo];
                
            }
            default:
                break;
        }
    } else
    {
        UIImage *newImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:desiredSize interpolationQuality:kCGInterpolationHigh];

        switch (buttonIndex) {
            case 0:
            {
                [self saveImageToLibrary:newImage];
                break;
            }
            case 1:
            {
                [self sendImageViaImessage:newImage];
                break;
            }
            case 2:
            {
                [self sendImageViaMail:newImage];
                break;
            }
        }
    }
}

- (void)sendImageViaImessage:(UIImage *)image
{
    MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
    [messageCompose addAttachmentData: UIImagePNGRepresentation(image) typeIdentifier: @"public.image" filename:@"Attachment.png"];
    messageCompose.delegate = self;
    [self presentViewController:messageCompose animated:YES completion:nil];
}
- (void)sendImageViaMail:(UIImage *)image
{
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    [mailCompose addAttachmentData:UIImagePNGRepresentation(image) mimeType:@"image/png" fileName:@"Attachment.png"];
    mailCompose.delegate = self;
    [self presentViewController:mailCompose animated:YES completion:nil];
}

- (void)saveImageToLibrary:(UIImage *)image
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Saved!";
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        [hud hide:YES];
    }];
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [metadata setObject:[self gpsDictionaryForLocation:manager.location] forKey:(NSString*)kCGImagePropertyGPSDictionary];
    [manager stopUpdatingLocation];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.image = originalImage;
    desiredSize = originalImage.size;
    [self updateInfo];

    switch (picker.sourceType) {
        case UIImagePickerControllerSourceTypeCamera:
        {
            metadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager startUpdatingLocation];

        }
        default:
        {
            NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                // Get the image metadata (EXIF & TIFF)
                NSMutableDictionary * imageMetadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
                //Note: The photo metadata dictionary is available only when using an image picker whose source type is set to UIImagePickerControllerSourceTypeCamera, and applies only to still images.
                
                if (!imageMetadata)
                {
                    imageMetadata = [NSMutableDictionary dictionary];
                    // try to retrieve gps metadata coordinates
                    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                    if ( location ) {
                        [imageMetadata setObject:[self gpsDictionaryForLocation:location] forKey:(NSString*)kCGImagePropertyGPSDictionary];
                    }
                    
                }
                metadata = imageMetadata;

                [self dismissViewControllerAnimated:YES completion:nil];
            } failureBlock:^(NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
                NSLog(@"Failed to get asset from library");
            }];
            
            break;
            
        }
    }
}
- (void)updateInfo
{
    _lbInfo.text = [NSString stringWithFormat:@"Size: %@", NSStringFromCGSize(desiredSize)];
    _lbNoImageImported.hidden = YES;
}

#pragma mark - MFMailComposeViewControllerDelegate - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark image saving methods
/**
 A convenience method to generate the {GPS} portion of a photo's EXIF data from a CLLLocation.
 
 @param location the location to base the NSDictionary on
 
 @return NSDictionary containing {GPS} block for a photo's EXIF data
 */
- (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location
{
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    
    // requires ImageIO
    [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
    
}

@end
