//
//  ViewController.m
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "ViewController.h"
#import "HwPhotoHelper.h"
#import "HWProgressHUD.h"
#import "GPUImage.h"
#import "HWPhotoMosaicViewController.h"
#import "MetaPhoto.h"
#import "UIImage+HWMosaic.h"
@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *inputImage;
    NSMutableArray *libraryMetaPhotos;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
    [self scanLibrary];
}
- (void)viewDidAppear:(BOOL)animated
{
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
        [HwPhotoHelper getAllThumbnailPhotosFromLibraryWithResponse:^(NSMutableArray *thumbnails) {
            //process thumbnails
            NSInteger imageCount = thumbnails.count;
            __block NSInteger index = 0;
            for (UIImage *image in thumbnails)
            {
                MetaPhoto *metaPhoto = [[MetaPhoto alloc] init];
                metaPhoto.photo = image;
                metaPhoto.averageColor = image.mergedColor;
                [libraryMetaPhotos addObject:metaPhoto];
                index ++;
                hud.detailsLabelText = [NSString stringWithFormat: @"Processing %ld/%ld...", index, imageCount];
                hud.progress = 1.0f * index/imageCount;
//            GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
//            [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime) {
//                UIColor *color = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
//                MetaPhoto *metaPhoto = [[MetaPhoto alloc] init];
//                metaPhoto.photo = image;
//                metaPhoto.averageColor = color;
//                [libraryMetaPhotos addObject:metaPhoto];
//                index ++;
//                NSLog(@"processed %ld", index);
//                CGFloat r, g, b, a;
//                [image.mergedColor getRed:&r green:&g blue:&b alpha:&a];
//                CGFloat rr, gg, bb, aa;
//                [image.onePixelColor getRed:&rr green:&gg blue:&bb alpha:&aa];
//                hud.detailsLabelText = [NSString stringWithFormat: @"Processing %ld/%ld...", index, imageCount];
//
//            }];

//            [averageColor imageByFilteringImage:image];
            }
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

@end
