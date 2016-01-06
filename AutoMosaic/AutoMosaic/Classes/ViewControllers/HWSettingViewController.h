//
//  HWSettingViewController.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWSettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISlider *sliderSampleSize;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedMethod;
@property (strong, nonatomic) IBOutlet UILabel *lbSampleSize;
+ (HWSettingViewController *)sharedSetting;
@end
