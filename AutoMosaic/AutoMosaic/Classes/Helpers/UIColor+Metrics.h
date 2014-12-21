//
//  UIColor+Metrics.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Metrics)
- (double) riemersmaDistanceTo:(UIColor *)color;
@end
