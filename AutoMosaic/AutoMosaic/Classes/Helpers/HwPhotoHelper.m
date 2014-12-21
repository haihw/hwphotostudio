//
//  HwPhotoHelper.m
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HwPhotoHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
@implementation HwPhotoHelper
+ (void)getAllThumbnailPhotosFromLibraryWithResponse:(void(^)(NSMutableArray *thumbnails)) block
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSMutableArray *thumbnails = [NSMutableArray array];
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // When the enumeration is done, 'enumerationBlock' will be called with group set to nil.
        if (!group)
        {
            block (thumbnails);
        } else {
            // Within the group enumeration block, filter to enumerate just photos.
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
