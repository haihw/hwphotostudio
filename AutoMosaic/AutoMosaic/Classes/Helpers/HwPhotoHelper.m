//
//  HwPhotoHelper.m
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HwPhotoHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;
@implementation HwPhotoHelper
/**
 required to call in background
 */
+ (NSArray *)getAllThumbnailPhotosReturnWithOnePixels:(NSMutableArray *)onePixels{
    NSAssert(onePixels.count == 0 && onePixels != nil, @"Wrong onepixel input");
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
        userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];

    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny
                                                                         options:userAlbumsOptions];
    NSMutableArray *thumbnails = [NSMutableArray new];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"Album name: %@", collection.localizedTitle);
        NSMutableArray *onePixelSubset = [NSMutableArray new];
        NSArray *thumbnailsSubset = [self getAllThumbnailPhotosFromAlbum:collection onePixels:onePixelSubset];
        if (thumbnailsSubset.count > 0){
            [thumbnails addObjectsFromArray:thumbnailsSubset];
//            [onePixels addObjectsFromArray:thumbnailsSubset];
        }
    }];
    return thumbnails;
}
/**
 required to call in background
 */
+ (NSArray *)getAllThumbnailPhotosFromAlbum:(PHAssetCollection *) collection onePixels:(NSMutableArray *)onePixels{
    PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
    onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:onlyImagesOptions];
    NSMutableArray *thumbnails = [NSMutableArray new];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    options.networkAccessAllowed = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    NSMutableArray *assets = [NSMutableArray new];
    
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        [assets addObject:asset];
    }];
    for (PHAsset *asset in assets){
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(150, 150)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result == nil){
                NSLog(@"Error: asset: %@ - %@", info, asset);
            } else {
                [thumbnails addObject:result];
            }
        }];
//        [[PHImageManager defaultManager] requestImageForAsset:asset
//                                                   targetSize:CGSizeMake(1, 1)
//                                                  contentMode:PHImageContentModeAspectFill
//                                                      options:options
//                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            [onePixels addObject:result];
//        }];
    }
    return thumbnails;
}
+ (NSArray <PHAssetCollection*> *)getAllPhotoAlbums{
//    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
//    userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount != 0"];
    
    PHFetchResult *userAlbums;
    
    NSMutableArray *albums = [NSMutableArray new];
    
    //Recents - all photos
    userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                          subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                          options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"album title %@ %d", collection.localizedTitle, (int)collection.estimatedAssetCount);
        [albums addObject:collection];
    }];

    userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                          subtype:PHAssetCollectionSubtypeSmartAlbumFavorites
                                                          options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"album title %@ %d", collection.localizedTitle, (int)collection.estimatedAssetCount);
        [albums addObject:collection];
    }];
    
    userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                          subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits
                                                          options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"album title %@ %d", collection.localizedTitle, (int)collection.estimatedAssetCount);
        [albums addObject:collection];
    }];
    userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                          subtype:PHAssetCollectionSubtypeSmartAlbumGeneric
                                                          options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"album title %@ %d", collection.localizedTitle, (int)collection.estimatedAssetCount);
        [albums addObject:collection];
    }];

    //local albums
    userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
    subtype:PHAssetCollectionSubtypeAny
    options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"album title %@ %d", collection.localizedTitle, (int)collection.estimatedAssetCount);
        if (collection.estimatedAssetCount > 10){
            [albums addObject:collection];
        }
    }];
    return albums;
}
/*
#pragma mark - faster but old API
+ (void)getAllPhotoAlbumsWithResponse:(void(^)(NSArray <ALAssetsGroup*> *result)) block{
    NSMutableArray *result = [NSMutableArray new];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.ALAssetsGroupEvent
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupEvent  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!group){
            block (result);
        }else{
            NSLog(@"Group: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            [result addObject:group];
        }
    } failureBlock:^(NSError *error) {
        block(nil);
    }];
}
+ (void)getThumbnailsFromGroup:(ALAssetsGroup *)group
                      response: (void(^)(NSMutableArray *thumbnails)) block{
    NSMutableArray *thumbnails = [NSMutableArray array];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
        // The end of the enumeration is signaled by asset == nil.
        if (alAsset) {
            UIImage *thumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
            [thumbnails addObject:thumbnail];
        } else {
            block(thumbnails);
        }
    }];
}
+ (void)getAllThumbnailPhotosFromLibraryWithResponse:(void(^)(NSMutableArray *thumbnails)) block
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.ALAssetsGroupEvent
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // When the enumeration is done, 'enumerationBlock' will be called with group set to nil.
        if (!group)
        {
            block (thumbnails);
        } else {
            // Within the group enumeration block, filter to enumerate just photos.
            NSLog(@"Group: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    UIImage *thumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                    [thumbnails addObject:thumbnail];
                }
            }];
        }
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        block (nil);
        NSLog(@"No groups");
    }];
}
 */
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}
+ (UIColor *)colorAtPoint:(CGPoint)pixelPoint ofImage:(UIImage *)image
{
    if (pixelPoint.x > image.size.width ||
        pixelPoint.y > image.size.height) {
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int numberOfColorComponents = 4; // R,G,B, and A
    float x = pixelPoint.x;
    float y = pixelPoint.y;
    float w = image.size.width;
    int pixelInfo = ((w * y) + x) * numberOfColorComponents;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    // RGBA values range from 0 to 255
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:alpha/255.0];
}
@end
