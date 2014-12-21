//
//  UIImage+HWMosaic.m
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "UIImage+HWMosaic.h"
#import "MetaPhoto.h"
#import "UIColor+Metrics.h"
#import "GPUImage.h"
#import "UIColor+Distance.h"
@implementation UIImage (HWMosaic)
- (void)createMosaicWithMetaPhotos:(NSArray *)metaPhotos params:(NSDictionary *)params progress: (void(^)(float percentage, UIImage *mosaicImage)) block
{
    float dx = 16; //metaPhoto.photo.size.width;
    float dy = 16; //metaPhoto.photo.size.height;
    NSString *metricsMethod = @"1";
    if (params)
    {
        dx = [[params objectForKey:@"dx"] floatValue];
        dy = [[params objectForKey:@"dy"] floatValue];
        metricsMethod = [params objectForKey:@"metric"];
    }
    int rowNum, colNum;
    rowNum = self.size.height / dy;
    colNum = self.size.width / dx;
    CGSize finalSize = CGSizeMake(colNum * dx, rowNum * dy);
    UIGraphicsBeginImageContext(finalSize);
    [self drawAtPoint:CGPointMake(0, 0)];
    NSArray *palette = [metaPhotos valueForKey:@"averageColor"];
    
    
    for (int x = 0; x < colNum; x++)
    {
        for (int y = 0; y < rowNum; y++)
        {
            float percentage = 1.0*(x*rowNum + y)/rowNum/colNum;
            block (percentage, nil);
            GPUImageCropFilter *filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(1.0*x/colNum, 1.0*y/rowNum, 1.0/colNum, 1.0/rowNum)];
            UIImage *regionImage = [filter imageByFilteringImage:self];
            MetaPhoto *matched;
            UIColor *averageColor = regionImage.mergedColor;
            if ([metricsMethod isEqualToString:@"1"]){
                matched = [self matchedPhotoOfColor:averageColor from:metaPhotos];
            } else if ([metricsMethod isEqualToString:@"2"])
            {
                UIColor *matchedColor = [averageColor closestColorInPalette:palette];
                NSInteger index = [palette indexOfObject:matchedColor];
                matched = metaPhotos[index];
            }
            CGRect drawRect = CGRectMake(x * dx, y * dy, dx, dy);
            [matched.photo drawInRect:drawRect];
        }
    }
    UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
    block (1, combined);
    UIGraphicsEndImageContext();
}
- (MetaPhoto *)matchedPhotoOfColor:(UIColor *)color from:(NSArray *)metaPhotoDB
{
    MetaPhoto *nearestMetaPhoto;
    double min = 100000000;
    for (MetaPhoto *meta in metaPhotoDB)
    {
        double distance = [color riemersmaDistanceTo:meta.averageColor];
        if (distance < min)
        {
            min = distance;
            nearestMetaPhoto = meta;
        }
    }
    return nearestMetaPhoto;
}
- (UIColor *)mergedColor
{
    // First get the image into your data buffer
    CGImageRef imageRef = [self CGImage];
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
    NSUInteger totalPixel = width * height;
    CGFloat totalRed, totalGreen, totalBlue;

    for (int i = 0 ; i < totalPixel ; i++)
    {
        totalRed += (rawData[i * bytesPerPixel]     * 1.0) / 255.0;
        totalGreen += (rawData[i * bytesPerPixel + 1] * 1.0) / 255.0;
        totalBlue += (rawData[i * bytesPerPixel + 2] * 1.0) / 255.0;
    }
    
    free(rawData);
    return [UIColor colorWithRed:totalRed/totalPixel green:totalGreen/totalPixel blue:totalBlue/totalPixel alpha:1];
}

- (UIColor *)onePixelColor
{
    CGImageRef rawImageRef = [self CGImage];
    
    // scale image to an one pixel image
    
    uint8_t  bitmapData[4];
    int bitmapByteCount;
    int bitmapBytesPerRow;
    int width = 1;
    int height = 1;
    
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    memset(bitmapData, 0, bitmapByteCount);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                                  colorspace,kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorspace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), rawImageRef);
    CGContextRelease(context);
    return [UIColor colorWithRed:bitmapData[0] / 255.0f
                           green:bitmapData[1] / 255.0f
                            blue:bitmapData[2] / 255.0f
                           alpha:1];

}
- (UIColor *)averageColor {
    CGSize size = {1, 1};
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
    [self drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
    uint8_t *data = CGBitmapContextGetData(ctx);
    UIColor *color = [UIColor colorWithRed:data[0] / 255.f green:data[1] / 255.f blue:data[2] / 255.f alpha:1];
    UIGraphicsEndImageContext();
    return color;
}

@end