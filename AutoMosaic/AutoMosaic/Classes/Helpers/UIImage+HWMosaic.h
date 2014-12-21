//
//  UIImage+HWMosaic.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HWMosaic)
- (void)createMosaicWithMetaPhotos:(NSArray *)metaPhotos params:(NSDictionary *)params progress: (void(^)(float percentage, UIImage *mosaicImage)) block;
- (UIColor *)mergedColor;
- (UIColor *)onePixelColor;
- (UIColor *)averageColor;
@end
