//
//  HWSettingViewController.m
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HWSettingViewController.h"

@implementation HWSettingViewController

- (IBAction)methodChanged:(UISegmentedControl *)sender {
}
- (IBAction)sampleSizeChanged:(UISlider *)sender {
    _lbSampleSize.text = [NSString stringWithFormat:@"%0.0f", sender.value];
}
@end
