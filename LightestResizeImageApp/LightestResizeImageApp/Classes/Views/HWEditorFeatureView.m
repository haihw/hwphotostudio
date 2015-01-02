//
//  HWEditorFeatureView.m
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/6/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//

#import "HWEditorFeatureView.h"

@interface HWEditorFeatureView() <HWFunctionScrollViewDelegate>
{
    NSInteger theCurrentSelectedTag;
    
    NSMutableArray *theSubFunctionViews;
    NSMutableArray *theSubFunctionImageViews;
    NSMutableArray *theSubFunctionLabels;

}
@end
@implementation HWEditorFeatureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _hasMoveUpHightLightStatus = NO;
        theCurrentSelectedTag = -1;
        self.clipsToBounds = NO;
        contentRect = self.bounds;
    }
    return self;
}

- (void)createSubFunctionGUI
{
    if (!(theSubFunctionTitles && theSubFunctionOnImageNames && theSubFunctionOffImageNames))
    {
        NSLog(@"Need init titles and image names for sub-function");
        return;
    }
    theButtonWidth = self.bounds.size.width / theSubFunctionTitles.count;
    if (theButtonWidth < 60)
        theButtonWidth = 60;
    theButtonHeight = 48;
    int scrollHeight = 48;
    theSubFunctionScrollView = [[HWFunctionScrollView alloc] initWithFrame:CGRectMake(0, contentRect.size.height - scrollHeight, contentRect.size.width, scrollHeight)];
    theSubFunctionScrollView.functionDelegate = self;
    theSubFunctionScrollView.theSubFunctionOffImageNames = theSubFunctionOffImageNames;
    theSubFunctionScrollView.theSubFunctionOnImageNames = theSubFunctionOnImageNames;
    theSubFunctionScrollView.theSubFunctionTitles = theSubFunctionTitles;
    [theSubFunctionScrollView createSubFunctionGUI];
    
    [self addSubview:theSubFunctionScrollView];
//    NSLog(@"Created function scroll view at frame: %@", NSStringFromCGRect(theSubFunctionScrollView.frame));

}
- (void)HWFunctionScrollView:(HWFunctionScrollView *)scrollView callSubFunctionWithTag:(NSInteger)tag
{
    [self callSubFunctionWithTag:tag];
}
- (IBAction)subFunctionTapped:(UITapGestureRecognizer*)sender
{
    NSLog(@"Subfucion tapped: %d", sender.view.tag);
}
- (void)manualChangeToSubFunctionViewWithTag:(NSInteger)tag
{
    [theSubFunctionScrollView manualChangeToSubFunctionViewWithTag:tag];
}
- (void)callSubFunctionWithTag:(NSInteger)tag
{
    NSLog(@"Need overide this method callSubFunctionWithTag");
    
}
-(void)setHasMoveUpHightLightStatus:(BOOL)hasMoveUpHightLightStatus
{
    _hasMoveUpHightLightStatus = hasMoveUpHightLightStatus;
    theSubFunctionScrollView.hasHeightLightBackground = hasMoveUpHightLightStatus;
}
- (void)didApplyFeature
{
    NSLog(@"Need overide this method didApplyFeature");
}
- (BOOL)shouldCancelFeature
{
    return YES;
}
- (BOOL)shouldApplyFeature
{
    return YES;
}
- (void)didCancelFeature
{
    NSLog(@"Need overide this method didCancelFeature");
}
- (void)reset
{
    NSLog(@"Need overide this method reset");
}
- (void)active
{
    NSLog(@"Need overide this method active");
}
- (UIImage*)processImage:(UIImage*)inputImage
{
    return inputImage;
}
@end
