// UIImageExtras.m -- extra UIImage methods
// by allen brunson  march 29 2009

#import "UIImageExtras.h"
#import "TLGraphicsMacros.h"
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (UIImageExtras)

-(CGRect)bounds
{
    return TLRectWithSize(self.size);
}

-(void)drawCenteredInRect:(CGRect)rect
{
    const CGRect cent = TLRectCenter(rect, self.bounds);
    [self drawAtPoint:TLPointUpperLeft(cent)];
}

-(NSData*)imageJPEGData
{
    return [self imageJPEGDataWithCompression:1.0];
}

// 0.0 is most compressed, 1.0 is highest quality
    
-(NSData*)imageJPEGDataWithCompression:(CGFloat)compression
{
    return UIImageJPEGRepresentation(self, compression);
}

-(NSData*)imagePNGData
{
    return UIImagePNGRepresentation(self);
}

// rotate an image to any 90-degree orientation, with or without mirroring.
// original code by kevin lohman, heavily modified by yours truly.
// http://blog.logichigh.com/2008/06/05/uiimage-fix/

-(UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect             bnds = self.bounds;
    CGContextRef       ctxt = nil;
    const CGRect       rect = bnds;
    CGAffineTransform  tran = CGAffineTransformIdentity;

    switch (orient)
    {
        case UIImageOrientationUp:
        return self;

        case UIImageOrientationUpMirrored:
        tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
        tran = CGAffineTransformScale(tran, -1.0, 1.0);
        break;

        case UIImageOrientationDown:
        tran = CGAffineTransformMakeTranslation(rect.size.width,
         rect.size.height);
        tran = CGAffineTransformRotate(tran, TLDegreesToRadians(180.0));
        break;

        case UIImageOrientationDownMirrored:
        tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
        tran = CGAffineTransformScale(tran, 1.0, -1.0);
        break;

        case UIImageOrientationLeft:
        bnds.size = TLSizeSwap(bnds.size);
        tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
        tran = CGAffineTransformRotate(tran, TLDegreesToRadians(-90.0));
        break;

        case UIImageOrientationLeftMirrored:
        bnds.size = TLSizeSwap(bnds.size);
        tran = CGAffineTransformMakeTranslation(rect.size.height,
         rect.size.width);
        tran = CGAffineTransformScale(tran, -1.0, 1.0);
        tran = CGAffineTransformRotate(tran, TLDegreesToRadians(-90.0));
        break;

        case UIImageOrientationRight:
        bnds.size = TLSizeSwap(bnds.size);
        tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
        tran = CGAffineTransformRotate(tran, TLDegreesToRadians(90.0));
        break;

        case UIImageOrientationRightMirrored:
        bnds.size = TLSizeSwap(bnds.size);
        tran = CGAffineTransformMakeScale(-1.0, 1.0);
        tran = CGAffineTransformRotate(tran, TLDegreesToRadians(90.0));
        break;

        default:
        // orientation value supplied is invalid
        assert(FALSE);
        return nil;
    }

    ctxt = TLGraphicsBeginImageContext(bnds.size);

    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextScaleCTM(ctxt, -1.0, 1.0);
        CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
        break;

        default:
        CGContextScaleCTM(ctxt, 1.0, -1.0);
        CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
        break;
    }

    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(ctxt, rect, self.CGImage);

    return TLGraphicsEndImageContext();
}

-(UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
