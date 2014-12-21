//
//  UIColor+Metrics.m
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "UIColor+Metrics.h"

@implementation UIColor (Metrics)
- (double) riemersmaDistanceTo:(UIColor *)color
{
    CGFloat R1, R2, G1, G2, B1, B2, A1, A2, Rm, deltaR, deltaG, deltaB;
    [self getRed:&R1 green:&G1 blue:&B1 alpha:&A1];
    [color getRed:&R2 green:&G2 blue:&B2 alpha:&A2];
    R1 *=256;
    R2 *=256;
    G1 *=256;
    G2 *=256;
    B1 *=256;
    B2 *=256;
    A1 *=256;
    A2 *=256;
    

    Rm = (R1 + R2)/2;
    deltaR = R1 - R2;
    deltaG = G1 - G2;
    deltaB = B1 - B2;
    
    double value =
    (2 + Rm/256) * deltaR * deltaR +
    4 * deltaG * deltaG +
    (2 + (255 - Rm)/256) * deltaB * deltaB;
    
    return sqrt(value);
}

@end
