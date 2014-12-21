//
//  HwPhotoHelper.h
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HwPhotoHelper : NSObject
+ (void)getAllThumbnailPhotosFromLibraryWithResponse:(void(^)(NSMutableArray *thumbnails)) block;
+ (UIColor *)averageColorOfImage:(UIImage *)image;

@end
