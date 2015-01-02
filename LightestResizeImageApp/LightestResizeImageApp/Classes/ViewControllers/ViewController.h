//
//  ViewController.h
//  LightestResizeImageApp
//
//  Created by Hai Hw on 2/1/15.
//  Copyright (c) 2015 Hai Hw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *lbInfo;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *lbNoImageImported;
- (IBAction)sliderChanged:(id)sender;

- (IBAction)btnImportTapped:(id)sender;

- (IBAction)btnCropTapped:(id)sender;
- (IBAction)btnResizeTapped:(id)sender;
- (IBAction)btnRotateTapped:(id)sender;
- (IBAction)btnExportTapped:(id)sender;
@end

