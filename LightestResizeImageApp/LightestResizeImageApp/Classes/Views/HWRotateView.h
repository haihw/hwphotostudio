//
//  HWRotateView.h
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/12/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//
/*
 ther are 8 orientation state;
 0: up
 1: up mirror   (HF)
 2: down mirror (VF)
 3: down        (RR)
 4: right       (R)
 5: left mirror (R, VF)
 6: right mirror (L, VF)
 7: left        (L)
 
 int lookupTable[][4] = {
 {7, 4, 1, 2},
 {6, 5, 0, 3},
 {5, 6, 3, 0},
 {4, 7, 2, 1},
 {0, 3, 6, 5},
 {1, 2, 7, 4},
 {2, 1, 4, 7},
 {3, 0, 5, 6},
 };
 */

#import "HWEditorFeatureView.h"
enum {
    UBoxRotateLeft = 0,
    UBoxRotateRight,
    UBoxRotateHozirotalFlip,
    UBoxRotateVerticalFlip,
};
@interface HWRotateView : HWEditorFeatureView
{
    int currentOrientationState;
    UIImageView *theRotateImageView;
}
@end
