//
//  HWCropView.m
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/12/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//
#import "HWCropView.h"
#import "UIImageExtras.h"
#import "HWCropBoundView.h"

@interface HWCropView()
{
    
    float currentRatio;
    enum UBoxCropMode currentCropMode;
    HWCropBoundView *theCropBoundsView;
    
    //save state for restore if user cancel feature
    CGRect savedCropBounds;
    float savedRotateDegree;
    
    //For gesturerecognizer
    CGPoint theOriginalCenter;
    CGRect theOriginalBound;
    
    float rotateDegree;
}
@end
@implementation HWCropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        theSubFunctionTitles = @[KKLocalizedString(@"UB_CR_ORIGINAL"),
//                                 KKLocalizedString(@"UB_CR_CUSTOM"),
//                                 KKLocalizedString(@"UB_CR_SQUARE"),
//                                 KKLocalizedString(@"UB_CR_ROTATE"),
//                                 ];
//        theSubFunctionOffImageNames = @[
//                                        @"UboxPhotoEditorResources.bundle/edit_crop_ogirinal_off",
//                                        @"UboxPhotoEditorResources.bundle/edit_crop_custom_off",
//                                        @"UboxPhotoEditorResources.bundle/edit_crop_square_off",
//                                        @"UboxPhotoEditorResources.bundle/edit_rotate_right_off",
//                                        ];
//        theSubFunctionOnImageNames = @[
//                                       @"UboxPhotoEditorResources.bundle/edit_crop_original_on",
//                                       @"UboxPhotoEditorResources.bundle/edit_crop_custom_on",
//                                       @"UboxPhotoEditorResources.bundle/edit_crop_square_on",
//                                       @"UboxPhotoEditorResources.bundle/edit_rotate_right_on",
//                                       ];
        contentRect = self.bounds;

        [self createSubFunctionGUI];
        theSubFunctionScrollView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        rotateDegree = 0;
    }
    return self;
}
- (void)callSubFunctionWithTag:(NSInteger)tag
{
    [self createCropOverlayForCropMode:tag];
}
- (void)createCropOverlayForCropMode:(enum UBoxCropMode)mode
{
    currentCropMode = mode;
    
    switch (mode) {
        case UBoxCropModeOriginal:
            theCropBoundsView.hidden = YES;
            rotateDegree = 0;
            self.thePreviewImageView.transform = CGAffineTransformIdentity;
            return;
        case UboxCropModeRotate:
        {
            NSLog(@"Rotate");
            theCropBoundsView.hidden = YES;
            rotateDegree += 90;
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    self.thePreviewImageView.transform = CGAffineTransformRotate(self.thePreviewImageView.transform, M_PI_2);
                                    
                                    //TODO: change limited bounds
                                    CGPoint center = theCropBoundsView.center;
                                    center = CGPointMake(CGRectGetMinX(theCropBoundsView.theLimitedBounds) + CGRectGetWidth(theCropBoundsView.theLimitedBounds) / 2,
                                                         CGRectGetMinY(theCropBoundsView.theLimitedBounds) + CGRectGetHeight(theCropBoundsView.theLimitedBounds) / 2);
                                    float newH = CGRectGetWidth(theCropBoundsView.theLimitedBounds);
                                    float newW = CGRectGetHeight(theCropBoundsView.theLimitedBounds);
                                    theCropBoundsView.theLimitedBounds = CGRectMake(center.x - newW/2, center.y - newH/2, newW, newH);

                                    NSLog(@"New preview frame: %@", NSStringFromCGRect(self.thePreviewImageView.frame));
                                } completion:^(BOOL finished) {
                                    
                                }];
            return;
        }
        case UBoxCropModeCustom:
            theCropBoundsView.ratio = 1;
            theCropBoundsView.isManualMode = YES;
            break;
        case UboxCropModeSquare:
            theCropBoundsView.ratio = 1;
            theCropBoundsView.isManualMode = NO;
            break;

        default:
            break;
    }
    theCropBoundsView.hidden = NO;
    theCropBoundsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.thePreviewImageView.frame)/2, CGRectGetWidth(self.thePreviewImageView.frame)/2 * currentRatio);
    theCropBoundsView.center = CGPointMake(CGRectGetWidth(self.thePreviewImageView.frame)/2, CGRectGetHeight(self.thePreviewImageView.frame)/2);
}
#pragma mark - overide methods
- (BOOL)shouldCancelFeature
{
    return NO;
}
- (void)didCancelFeature
{
    theCropBoundsView.hidden = YES;
    self.thePreviewImageView.transform = CGAffineTransformIdentity;
    rotateDegree = 0;
    theCropBoundsView.frame = savedCropBounds;
    rotateDegree = savedRotateDegree;
}
- (void)didApplyFeature
{
    theCropBoundsView.hidden = YES;
    self.thePreviewImageView.transform = CGAffineTransformIdentity;
}

//get the obsolute frame of image in a boudary frame
- (CGRect) displayedImageRectForImage:(UIImage *)image fitInFrame:(CGRect)rect
{
    CGSize imageSize = image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(rect)/imageSize.width, CGRectGetHeight(rect)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(CGRectGetMinX(rect) + 0.5f*(CGRectGetWidth(rect)-scaledImageSize.width), CGRectGetMinY(rect) + 0.5f*(CGRectGetHeight(rect)-scaledImageSize.height), scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
}
- (void)active
{
    UIImage *anInputImage;
    if (anInputImage){
        theCropBoundsView.theLimitedBounds = [self displayedImageRectForImage:anInputImage fitInFrame:self.thePreviewImageView.frame];
        NSLog(@"Limited Bounds: %@", NSStringFromCGRect(theCropBoundsView.theLimitedBounds));
    }else{
        theCropBoundsView.theLimitedBounds = self.thePreviewImageView.frame;
    }
    if (currentCropMode == UBoxCropModeCustom || currentCropMode == UboxCropModeSquare)
    {
        theCropBoundsView.hidden = NO;
    }
    // init for rotating
    self.thePreviewImageView.transform = CGAffineTransformRotate(self.thePreviewImageView.transform, rotateDegree/90 * M_PI_2);
    //change the crop view bound to fit with new transform preview image view
    if ((int)rotateDegree % 180 != 0)
    {
        CGPoint center = theCropBoundsView.center;
        center = CGPointMake(CGRectGetMinX(theCropBoundsView.theLimitedBounds) + CGRectGetWidth(theCropBoundsView.theLimitedBounds) / 2,
                             CGRectGetMinY(theCropBoundsView.theLimitedBounds) + CGRectGetHeight(theCropBoundsView.theLimitedBounds) / 2);
        float newH = CGRectGetWidth(theCropBoundsView.theLimitedBounds);
        float newW = CGRectGetHeight(theCropBoundsView.theLimitedBounds);
        theCropBoundsView.theLimitedBounds = CGRectMake(center.x - newW/2, center.y - newH/2, newW, newH);
    }
    savedCropBounds = theCropBoundsView.frame;
	savedRotateDegree = rotateDegree;
}
- (void)reset
{
    theCropBoundsView.isManualMode = YES;
    theCropBoundsView.ratio = 1;
    [self manualChangeToSubFunctionViewWithTag:UBoxCropModeCustom];
}
- (UIImage *)processImage:(UIImage *)inputImage
{
    if (!inputImage)
        return nil;
    //only crop image if the cropview is visible and the input image is avalable
    UIImage *resultImage = [inputImage imageRotatedByDegrees:rotateDegree];
    if (currentCropMode == UBoxCropModeCustom || currentCropMode == UboxCropModeSquare)
    {
        CGRect cropRegion = [theCropBoundsView getRelativeFrame];
        NSLog(@"Crop rect %@", NSStringFromCGRect(cropRegion));
    }
    return resultImage;
}

#pragma settor
- (void)setThePreviewImageView:(UIImageView *)thePreviewImageView
{
    [super setThePreviewImageView:thePreviewImageView];
    currentRatio = 1;
    //Create view to control cropping
    theCropBoundsView = [[HWCropBoundView alloc] initWithFrame:self.thePreviewImageView.frame];
    theCropBoundsView.hidden = YES;
    [self insertSubview:theCropBoundsView belowSubview:theSubFunctionScrollView];
//    [self addSubview:theCropBoundsView];
    [self manualChangeToSubFunctionViewWithTag:UBoxCropModeCustom];
    [self active];
    
}

@end
