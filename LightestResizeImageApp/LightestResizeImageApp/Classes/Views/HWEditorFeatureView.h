//
//  HWEditorFeatureView.h
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/6/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//
/*
 * This abstract class for all feature view
 */
#import <UIKit/UIKit.h>
#import "HWFunctionScrollView.h"
#define kFxFontSize 10
@interface HWEditorFeatureView : UIView{
    NSArray *theSubFunctionTitles;
    NSArray *theSubFunctionOffImageNames;
    NSArray *theSubFunctionOnImageNames;
    HWFunctionScrollView *theSubFunctionScrollView;

    int theButtonHeight;
    int theButtonLabelHeight;
    int theButtonWidth;
    
    CGRect contentRect;
}
@property (strong, nonatomic) UIImageView *thePreviewImageView;
@property (assign, nonatomic) BOOL hasMoveUpHightLightStatus; //this property use for effect view
//for manual change state of sub function
- (void)manualChangeToSubFunctionViewWithTag:(NSInteger)tag;

// need init the subfunction items before call this method
- (void)createSubFunctionGUI;

//Abtract method
- (BOOL)shouldCancelFeature;
- (BOOL)shouldApplyFeature;
- (void)didCancelFeature;
- (void)didApplyFeature;
- (void)active;
- (void)reset;
- (UIImage*)processImage:(UIImage*)inputImage;

//call when subfunciton tapped
- (void)callSubFunctionWithTag:(NSInteger)tag;


@end