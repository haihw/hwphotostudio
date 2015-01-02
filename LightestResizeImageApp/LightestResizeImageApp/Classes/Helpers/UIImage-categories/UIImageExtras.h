// UIImageExtras.h -- extra UIImage methods
// by allen brunson  march 29 2009


/******************************************************************************/
/*                                                                            */
/***  UIImage category                                                      ***/
/*                                                                            */
/******************************************************************************/

@interface UIImage (UIImageExtras)

-(UIImage*)rotate:(UIImageOrientation)orient;

// rotate
//  Created by Hardy Macia on 7/1/09.
//  Copyright 2009 Catamount Software. All rights reserved.
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end


/******************************************************************************/
/*                                                                            */
/***  UIImage category                                                      ***/
/*                                                                            */
/******************************************************************************

overview
--------

extra methods for UIImage

*/
