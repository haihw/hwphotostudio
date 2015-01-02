//
//  HWCropBoundView.h
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/12/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//
enum UboxCropControlPoint{
    UboxCropControlPointTopLeft = 0,
    UboxCropControlPointTopRight,
    UboxCropControlPointBotLeft,
    UboxCropControlPointBotRight,
    UboxCropControlPointNone,
};

@interface HWCropBoundView : UIView <UIGestureRecognizerDelegate>
{
    //For gesturerecognizer
    CGPoint theOriginalCenter;
    CGRect theOriginalBound;
    CGRect theOriginalFrame;
    float theMaxScaleRate;
    
    // 4 control points
    UIView *theTopLeftPoint;
    UIView *theTopRightPoint;
    UIView *theBotLeftPoint;
    UIView *theBotRightPoint;

    enum UboxCropControlPoint theActiveControlPoint;
    UITouch *theFirstTouch;
}
@property (nonatomic, assign) CGRect theLimitedBounds;
@property (nonatomic, assign) float ratio;
@property (nonatomic, assign) BOOL isManualMode;
- (CGRect)getRelativeFrame;
@end
