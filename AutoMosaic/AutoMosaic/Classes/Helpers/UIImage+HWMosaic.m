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
#import "UIImage+Resize.h"
@implementation UIImage (HWMosaic)
- (void)createMosaic2WithMetaPhotos:(NSArray *)metaPhotos params:(NSDictionary *)params progress: (void(^)(float percentage, UIImage *mosaicImage)) block
{
    NSDate *startTime = [NSDate date];
    float dw = 16; //metaPhoto.photo.size.width;
    float dh = 16; //metaPhoto.photo.size.height;
    
    NSInteger sampleWidth, sampleHeight;
    sampleWidth = 320;
    sampleHeight = 320;

    NSString *metricsMethod = @"1";
    if (params)
    {
        dw = [[params objectForKey:@"dx"] floatValue];
        dh = [[params objectForKey:@"dy"] floatValue];
        
        sampleWidth = [[params objectForKey:@"width"] intValue];
        sampleHeight = [[params objectForKey:@"height"] intValue];
        
        metricsMethod = [params objectForKey:@"metric"];
    }
    //resize image to desired size
    UIImage *sampleImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(sampleWidth, sampleHeight) interpolationQuality: kCGInterpolationHigh];
//    UIImageWriteToSavedPhotosAlbum(sampleImage, nil, nil, nil);
    sampleWidth = sampleImage.size.width;
    sampleHeight = sampleImage.size.height;

    //calculate the final image size
    CGSize finalSize = CGSizeMake(sampleWidth * dw, sampleHeight * dh);
    //create context
    UIGraphicsBeginImageContext(finalSize);
    //draw input image as background
    [self drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    //prepare pallete for method number 2
    NSArray *palette = [metaPhotos valueForKey:@"averageColor"];
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * sampleWidth;
    unsigned char * rawData = [sampleImage rawDataWith:bytesPerPixel];
    for (NSInteger h = 0; h < sampleHeight; h++)
    {
        for (NSInteger w = 0; w < sampleWidth; w++)
        {
            NSInteger location = h * sampleWidth + w;
            float percentage = 1.0 * location / sampleWidth / sampleHeight;
            block (percentage, nil);
            
            MetaPhoto *matched;
            
            //get color value
            NSUInteger byteIndex = (bytesPerRow * h) + w * bytesPerPixel;

            CGFloat red   = (1.0f * rawData[byteIndex]) / 255.0f;
            CGFloat green = (1.0f * rawData[byteIndex + 1]) / 255.0f;
            CGFloat blue  = (1.0f * rawData[byteIndex + 2]) / 255.0f;
            CGFloat alpha = (1.0f * rawData[byteIndex + 3]) / 255.0f;
            UIColor *averageColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            if ([metricsMethod isEqualToString:@"1"]){
                matched = [self matchedPhotoOfColor:averageColor from:metaPhotos];
            } else if ([metricsMethod isEqualToString:@"2"])
            {
                UIColor *matchedColor = [averageColor closestColorInPalette:palette];
                NSInteger index = [palette indexOfObject:matchedColor];
                matched = metaPhotos[index];
            }
            CGRect drawRect = CGRectMake(w * dw, h * dh, dw, dh);
            [matched.photo drawInRect:drawRect];
        }
    }
    free(rawData);
    UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"Process Time: %f", [startTime timeIntervalSinceNow]);
    block (1, combined);
    UIGraphicsEndImageContext();
    
}

/*
 Method 1:
  - replace a part of image with closest image in library
 */
- (void)createMosaicWithMetaPhotos:(NSArray *)metaPhotos params:(NSDictionary *)params progress: (void(^)(float percentage, UIImage *mosaicImage)) block
{
    NSDate *startTime = [NSDate date];
    float dx = 16; //metaPhoto.photo.size.width;
    float dy = 16; //metaPhoto.photo.size.height;
    NSString *metricsMethod = @"1";
    if (params)
    {
        dx = [[params objectForKey:@"dx"] floatValue];
        dy = [[params objectForKey:@"dy"] floatValue];
        metricsMethod = [params objectForKey:@"metric"];
    }
    NSInteger rowNum, colNum;
    rowNum = self.size.height / dy;
    colNum = self.size.width / dx;
    CGSize finalSize = CGSizeMake(colNum * dx, rowNum * dy);
    UIGraphicsBeginImageContext(finalSize);
    [self drawAtPoint:CGPointMake(0, 0)];
    NSArray *palette = [metaPhotos valueForKey:@"averageColor"];
    
    
    for (NSInteger x = 0; x < colNum; x++)
    {
        for (NSInteger y = 0; y < rowNum; y++)
        {
            float percentage = 1.0*(x*rowNum + y)/rowNum/colNum;
            block (percentage, nil);
            GPUImageCropFilter *filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(1.0f * x/colNum, 1.0f *y/rowNum, 1.0f /colNum, 1.0f /rowNum)];
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
    NSLog(@"Process Time: %f", [startTime timeIntervalSinceNow]);
    block (1, combined);
    UIGraphicsEndImageContext();
    
}
- (MetaPhoto *)matchedPhotoOfColor:(UIColor *)color from:(NSArray *)metaPhotoDB
{
    MetaPhoto *nearestMetaPhoto;
    nearestMetaPhoto = metaPhotoDB.firstObject;
    double min = [color riemersmaDistanceTo:nearestMetaPhoto.averageColor];
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
- (unsigned char *)rawDataWith:(NSUInteger)bytesPerPixel
{
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 CGImageGetBytesPerRow(imageRef),
                                                 CGImageGetColorSpace(imageRef),
                                                 CGImageGetBitmapInfo(imageRef));
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return rawData;
}
- (UIColor *)mergedColor
{
    NSUInteger bytesPerPixel = 4;
    // First get the image into your data buffer
    unsigned char *rawData = [self rawDataWith: bytesPerPixel];
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger totalPixel = self.size.width * self.size.height;
    CGFloat totalRed = 0;
    CGFloat totalGreen = 0;
    CGFloat totalBlue = 0;

    for (NSInteger i = 0 ; i < totalPixel ; i++)
    {
        totalRed   += 1.0f * (rawData[i * bytesPerPixel]   )  / 255.0f;
        totalGreen += 1.0f * (rawData[i * bytesPerPixel + 1]) / 255.0f;
        totalBlue  += 1.0f * (rawData[i * bytesPerPixel + 2]) / 255.0f;
    }
    
    free(rawData);
    return [UIColor colorWithRed:totalRed/totalPixel green:totalGreen/totalPixel blue:totalBlue/totalPixel alpha:1];
}

- (UIColor *)onePixelColor
{
    CGImageRef rawImageRef = [self CGImage];
    
    // scale image to an one pixel image
    
    uint8_t  bitmapData[4];
    NSInteger bitmapByteCount;
    NSInteger bitmapBytesPerRow;
    NSInteger width = 1;
    NSInteger height = 1;
    
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    memset(bitmapData, 0, bitmapByteCount);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(bitmapData,
                                                 width,
                                                 height,
                                                 CGImageGetBitsPerComponent(rawImageRef),
                                                 CGImageGetBytesPerRow(rawImageRef),
                                                 CGImageGetColorSpace(rawImageRef),
                                                 CGImageGetBitmapInfo(rawImageRef));
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
@end
