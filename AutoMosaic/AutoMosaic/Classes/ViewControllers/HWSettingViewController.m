//
//  HWSettingViewController.m
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HWSettingViewController.h"

@implementation HWSettingViewController
+(HWSettingViewController *)sharedSetting
{
    // 1
    static HWSettingViewController *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HWSettingViewController alloc] init];
    });
    return _sharedInstance;
}
- (IBAction)methodChanged:(UISegmentedControl *)sender {
}
- (IBAction)sampleSizeChanged:(UISlider *)sender {
    _lbSampleSize.text = [NSString stringWithFormat:@"%0.0f", sender.value];
}
@end
