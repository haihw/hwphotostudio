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
#import "UIColor+Distance.h"
#import "UIImage+Resize.h"
#define GLOBAL_MIN 100
double globalMin; //to analyze which is best MIN to improve the performance search
@implementation UIImage (HWMosaic)
- (void)createMosaicWithMetaPhotos:(NSMutableArray *)metaPhotos
                            params:(NSDictionary *)params
                          progress: (void(^)(float percentage, UIImage *mosaicImage)) block
{
#if DEBUG
    NSDate *startTime = [NSDate date];
#endif
    MetaPhoto *anyMeta = metaPhotos.firstObject;
    float metaphotoWidth = anyMeta.photo.size.width;
    float metaphotoHeight = anyMeta.photo.size.height;
    NSInteger sampleWidth = 320;
    NSInteger sampleHeight = 320;
    float foregroundOpacity = 0.5f;
    NSString *metricsMethod = @"1";
    if (params)
    {
        metaphotoWidth = [[params objectForKey:@"dx"] floatValue];
        metaphotoHeight = [[params objectForKey:@"dy"] floatValue];
        
        sampleWidth = [[params objectForKey:@"width"] intValue];
        sampleHeight = [[params objectForKey:@"height"] intValue];

        metricsMethod = [params objectForKey:@"metric"];
        
        if ([params objectForKey: @"opacity"] != nil){
            foregroundOpacity = [[params objectForKey:@"opacity"] floatValue]/100;
        }
    }
    
    //resize image to sampled size
    UIImage *sampleImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(sampleWidth, sampleHeight) interpolationQuality: kCGInterpolationHigh];

    sampleWidth = sampleImage.size.width; //real image width
    sampleHeight = sampleImage.size.height; //real image height
    

    CGSize finalSize = CGSizeMake(sampleWidth * metaphotoWidth, sampleHeight * metaphotoHeight);
    
    NSLog(@"The sample size size: %@", NSStringFromCGSize(sampleImage.size));
    
    NSLog(@"The estimated output size: %@", NSStringFromCGSize(finalSize));
    
    UIGraphicsBeginImageContext(finalSize);
    
    [sampleImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
    
    //unused
    NSArray *palette = [metaPhotos valueForKey:@"averageColor"];
    
    //process
    // First get the image into your data buffer
    CGImageRef imageRef = [sampleImage CGImage];
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
    //To reduce duplicated photo, set maximum appearance number of each photo in the final photo.
    int maxNumberOfUsage = (int)totalPixel/metaPhotos.count + 1;
    //Reset usage count of metaphoto
    for (MetaPhoto *metaPhoto in metaPhotos){
        metaPhoto.usedCount = 0;
    }
//    int *flagCount = calloc(metaPhotos.count, sizeof(int));
    globalMin = 888888888;
    NSUInteger interval = MAX(totalPixel / 1000, 100);
    float red, green, blue;
    
    for (int iteration = 0 ; iteration < totalPixel ; iteration++)
    {
        if (iteration % interval == 0){
            float percentage = 1.0f * iteration / totalPixel;
            block (percentage, nil);
        }
        //get color of sample image
        red = (rawData[iteration * bytesPerPixel]     * 1.0) / 255.0;
        green = (rawData[iteration * bytesPerPixel + 1] * 1.0) / 255.0;
        blue = (rawData[iteration * bytesPerPixel + 2] * 1.0) / 255.0;
        int columnCoordinate = iteration % width;
        int rowCoordinate = iteration / width;
        UIColor *pointColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        
        //find the match meta photo with pointed color
        MetaPhoto *matched;
        if ([metricsMethod isEqualToString:@"1"]){
            matched = [self matchedPhotoOfColor:pointColor
                                           from:metaPhotos
                                   withMaxUsage:maxNumberOfUsage];
            matched.usedCount ++;
        } else if ([metricsMethod isEqualToString:@"2"]){
            UIColor *matchedColor = [pointColor closestColorInPalette:palette];
            NSInteger index = [palette indexOfObject:matchedColor];
            matched = metaPhotos[index];
        }
        
        //draw matched photo at output context
        CGRect drawRect = CGRectMake(columnCoordinate * metaphotoWidth, rowCoordinate * metaphotoHeight, metaphotoWidth, metaphotoHeight);
        [matched.photo drawInRect:drawRect
                        blendMode:kCGBlendModeNormal
                            alpha: foregroundOpacity];

    }
    NSLog(@"GLOBAL MIN: %f", globalMin);
    free(rawData);
    
    UIImage *combined = UIGraphicsGetImageFromCurrentImageContext();
    block (1, combined);
    UIGraphicsEndImageContext();
#if DEBUG
    NSLog(@"Process Time: %f s", -[startTime timeIntervalSinceNow]);
#endif
}
- (MetaPhoto *)matchedPhotoOfColor:(UIColor *)color
                              from:(NSArray *)metaPhotoDB
                      withMaxUsage:(int)maxUsage
{
    MetaPhoto *nearestMetaPhoto;
    double min = 100000000;
    for (MetaPhoto *meta in metaPhotoDB)
    {
        if (meta.usedCount <= maxUsage){
            double distance = [color riemersmaDistanceTo:meta.averageColor];
            if (distance < min)
            {
                min = distance;
                nearestMetaPhoto = meta;
            }
            if (distance < GLOBAL_MIN){
                break;
            }
        }
    }
    if (min < globalMin){
        globalMin = min; //for analytic
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
    CGFloat totalRed = 0;
    CGFloat totalGreen = 0;
    CGFloat totalBlue = 0;
    
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
