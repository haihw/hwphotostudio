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
@interface HWPhotoMosaicViewController ()

@end

@implementation HWPhotoMosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    _imageView.image = _inputImage;
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
        NSDictionary *params = @{
                                 @"metric": @"1", //riemersmaDistanceTo
                                 @"dx":@32,
                                 @"dy":@32,
                                 @"width":@100,
                                 @"height":@100,
                                 };
        [_inputImage createMosaic2WithMetaPhotos:_metaPhotos params:params progress:^(float percentage, UIImage *mosaicImage) {
            if (mosaicImage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.image = mosaicImage;
                    UIImageWriteToSavedPhotosAlbum(mosaicImage, nil, nil, nil);
                    [HWProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
            hud.detailsLabelText = [NSString stringWithFormat:@"Processing %0.1f%%", percentage*100];
            hud.progress = percentage;
        }];
    });
}
@end
