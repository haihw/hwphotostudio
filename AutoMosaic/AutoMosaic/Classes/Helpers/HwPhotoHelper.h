//
//  HwPhotoHelper.h
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAssetCollection, ALAssetsGroup;
@interface HwPhotoHelper : NSObject
//+ (void)getAllPhotoAlbumsWithResponse:(void(^)(NSArray <ALAssetsGroup*> *albums)) block;
//+ (void)getThumbnailsFromGroup:(ALAssetsGroup *)group
//                      response: (void(^)(NSMutableArray *thumbnails)) block;
//+ (void)getAllThumbnailPhotosFromLibraryWithResponse:(void(^)(NSMutableArray *thumbnails)) block;
/**
required to call in background
 @param onePixels need to be empty array
*/
+ (NSArray *)getAllThumbnailPhotosReturnWithOnePixels:(NSMutableArray *)onePixels;
+ (NSArray <PHAssetCollection*> *)getAllPhotoAlbums;
/**
required to call in background
 @param onePixels need to be empty array
*/
+ (NSArray *)getAllThumbnailPhotosFromAlbum:(PHAssetCollection *) collection onePixels:(NSMutableArray *)onePixels;
@end
