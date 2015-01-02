//
//  HWCropBoundView.m
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/12/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//

#import "HWCropBoundView.h"
#define kPointSize 44;
@implementation HWCropBoundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //Add gesture to interaction with image layer
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(panHandler:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        [self addControlPoint];
        self.isManualMode = YES;
    }
    return self;
}
- (void)addControlPoint
{
    //add 4 control point view
    //1.
    theTopLeftPoint = [[UIView alloc] init];
    theTopLeftPoint.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UboxPhotoEditorResources.bundle/img_bg_crop_topleft"]];
    theTopLeftPoint.tag = UboxCropControlPointTopLeft;
    
    [self addSubview:theTopLeftPoint];
    
    //2.
    theTopRightPoint = [[UIView alloc] init];
    theTopRightPoint.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UboxPhotoEditorResources.bundle/img_bg_crop_topright"]];
    theTopRightPoint.tag = UboxCropControlPointTopRight;
    [self addSubview:theTopRightPoint];
    
    //3.
    theBotLeftPoint = [[UIView alloc] init];
    theBotLeftPoint.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UboxPhotoEditorResources.bundle/img_bg_crop_botleft"]];
    theBotLeftPoint.tag = UboxCropControlPointBotLeft;
    [self addSubview:theBotLeftPoint];
    
    //4.
    theBotRightPoint = [[UIView alloc] init];
    theBotRightPoint.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UboxPhotoEditorResources.bundle/img_bg_crop_botright"]];
    theBotRightPoint.tag = UboxCropControlPointBotRight;
    [self addSubview:theBotRightPoint];

}
#pragma mark - Gesture Handler
- (void) controlTheCropViewWithTranslation2:(CGPoint)translation
{
    float dx = translation.x; //change for origin X
    float dy = translation.y; //change for origin Y
    float dw = translation.x; //change for width
    float dh = translation.y; //change for height
    
    switch (theActiveControlPoint) {
        case UboxCropControlPointTopLeft: //X min, Y min
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, translation.x * self.ratio);
            }
            dx = translation.x;
            dy = translation.y;
            dw = -translation.x;
            dh = -translation.y;
            
            //check max and min
            
            break;
        case UboxCropControlPointTopRight: // X max, Y min
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, -translation.x * self.ratio);
            }
            dx = 0;
            dy = translation.y;
            dw = translation.x;
            dh = -translation.y;
            break;
        case UboxCropControlPointBotLeft: //X min, Y max
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, -translation.x * self.ratio);
            }
            dx = translation.x;
            dy = 0;
            dw = -translation.x;
            dh = translation.y;
            break;
        case UboxCropControlPointBotRight: //X max, Y Max
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, translation.x * self.ratio);
            }
            dx = 0;
            dy = 0;
            dw = translation.x;
            dh = translation.y;
            break;
        default:
            break;
    }
    float newOriginX = CGRectGetMinX(theOriginalFrame) + dx;
    float newOriginY = CGRectGetMinY(theOriginalFrame) + dy;
    float newWidth = CGRectGetWidth(theOriginalFrame) + dw;
    float newHeight = CGRectGetHeight(theOriginalFrame) + dh;
    
    CGRect newFrame = CGRectMake(newOriginX, newOriginY, newWidth, newHeight);
    
    CGRect innerRect = CGRectMake(newFrame.origin.x, newFrame.origin.y, 72, 72);
    newFrame = CGRectUnion(newFrame, innerRect);
    newFrame = CGRectIntersection(newFrame, _theLimitedBounds);
    self.frame = newFrame;
}
- (CGRect)getSquareInsizeRect:(CGRect)rect withControlPoint:(enum UboxCropControlPoint)controlPoint
{
    float size = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    switch (theActiveControlPoint) {
        case UboxCropControlPointTopLeft:
            return CGRectMake(CGRectGetMaxX(rect) - size, CGRectGetMaxY(rect) - size, size, size);
        case UboxCropControlPointBotLeft:
            return CGRectMake(CGRectGetMaxX(rect) - size, CGRectGetMinY(rect), size, size);
        case UboxCropControlPointTopRight:
            return CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - size, size, size);
        case UboxCropControlPointBotRight:
            return CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), size, size);
            
        default:
            break;
    }
    return rect;
}
- (void) controlTheCropViewWithTranslation:(CGPoint)translation
{
    float minSize = 72;
    CGRect newFrame, maxFrame, minFrame;
    switch (theActiveControlPoint) {
        case UboxCropControlPointTopLeft: //X min, Y min
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, translation.x * self.ratio);
            }
            newFrame = CGRectMake(CGRectGetMinX(theOriginalFrame) + translation.x,
                                  CGRectGetMinY(theOriginalFrame) + translation.y,
                                  CGRectGetWidth(theOriginalFrame) - translation.x,
                                  CGRectGetHeight(theOriginalFrame) - translation.y);
            maxFrame = CGRectMake(CGRectGetMinX(_theLimitedBounds),
                                  CGRectGetMinY(_theLimitedBounds),
                                  CGRectGetMaxX(theOriginalFrame) - CGRectGetMinX(_theLimitedBounds),
                                  CGRectGetMaxY(theOriginalFrame) - CGRectGetMinY(_theLimitedBounds));
            minFrame = CGRectMake(CGRectGetMaxX(theOriginalFrame) - minSize,
                                  CGRectGetMaxY(theOriginalFrame) - minSize,
                                  minSize,
                                  minSize);
            break;
        case UboxCropControlPointTopRight: // X max, Y min
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, -translation.x * self.ratio);
            }
            newFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMinY(theOriginalFrame) + translation.y,
                                  CGRectGetWidth(theOriginalFrame) + translation.x,
                                  CGRectGetHeight(theOriginalFrame) - translation.y);
            maxFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMinY(_theLimitedBounds),
                                  CGRectGetMaxX(_theLimitedBounds) - CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMaxY(theOriginalFrame) - CGRectGetMinY(_theLimitedBounds));
            minFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMaxY(theOriginalFrame) - minSize,
                                  minSize,
                                  minSize);
            break;
        case UboxCropControlPointBotLeft: //X min, Y max
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, -translation.x * self.ratio);
            }
            newFrame = CGRectMake(CGRectGetMinX(theOriginalFrame) + translation.x,
                                  CGRectGetMinY(theOriginalFrame),
                                  CGRectGetWidth(theOriginalFrame) - translation.x,
                                  CGRectGetHeight(theOriginalFrame) + translation.y);
            maxFrame = CGRectMake(CGRectGetMinX(_theLimitedBounds),
                                  CGRectGetMinY(theOriginalFrame),
                                  CGRectGetMaxX(theOriginalFrame) - CGRectGetMinX(_theLimitedBounds),
                                  CGRectGetMaxY(_theLimitedBounds) - CGRectGetMinY(theOriginalFrame));
            minFrame = CGRectMake(CGRectGetMaxX(theOriginalFrame) - minSize,
                                  CGRectGetMinY(theOriginalFrame),
                                  minSize,
                                  minSize);
            break;
        case UboxCropControlPointBotRight: //X max, Y Max
            if (!self.isManualMode) {
                translation = CGPointMake(translation.x, translation.x * self.ratio);
            }
            newFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMinY(theOriginalFrame),
                                  CGRectGetWidth(theOriginalFrame) + translation.x,
                                  CGRectGetHeight(theOriginalFrame) + translation.y);
            maxFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMinY(theOriginalFrame),
                                  CGRectGetMaxX(_theLimitedBounds) - CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMaxY(_theLimitedBounds) - CGRectGetMinY(theOriginalFrame));
            minFrame = CGRectMake(CGRectGetMinX(theOriginalFrame),
                                  CGRectGetMinY(theOriginalFrame),
                                  minSize,
                                  minSize);
            break;
        default:
            break;
    }
    if (!self.isManualMode)
    {
        maxFrame = [self getSquareInsizeRect:maxFrame withControlPoint:theActiveControlPoint];
    }
    newFrame = CGRectUnion(newFrame, minFrame);
    newFrame = CGRectIntersection(newFrame, maxFrame);
    self.frame = newFrame;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    theFirstTouch= touch;
    return YES;
}
- (void)panHandler:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:sender.view.superview];
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        theOriginalCenter = sender.view.center;
        theOriginalFrame = self.frame;
        CGPoint touchPosition = [theFirstTouch locationInView:self];
        theActiveControlPoint = UboxCropControlPointNone;
        if (touchPosition.x < CGRectGetMaxX(theTopLeftPoint.frame)
            && touchPosition.y < CGRectGetMaxY(theTopLeftPoint.frame))
        {
            theActiveControlPoint = UboxCropControlPointTopLeft;
        }else if (touchPosition.x > CGRectGetMinX(theTopRightPoint.frame)
                  && touchPosition.y < CGRectGetMaxY(theTopRightPoint.frame))
        {
            theActiveControlPoint = UboxCropControlPointTopRight;
        }else if (touchPosition.x < CGRectGetMaxX(theBotLeftPoint.frame)
                  && touchPosition.y > CGRectGetMinY(theBotLeftPoint.frame))
        {
            theActiveControlPoint = UboxCropControlPointBotLeft;
        }else if (touchPosition.x > CGRectGetMinX(theBotRightPoint.frame)
                  && touchPosition.y > CGRectGetMinY(theBotRightPoint.frame))
        {
            theActiveControlPoint = UboxCropControlPointBotRight;
        }
        return;
    }
    float translationX = translation.x;
    float translationY = translation.y;
    switch (theActiveControlPoint) {
        case UboxCropControlPointNone:
            //drag the crop view
            translationX = MIN(CGRectGetWidth(_theLimitedBounds) - CGRectGetMaxX(theOriginalFrame) + CGRectGetMinX(_theLimitedBounds),
                               MAX(CGRectGetMinX(_theLimitedBounds)-CGRectGetMinX(theOriginalFrame), translation.x));
            translationY = MIN(CGRectGetHeight(_theLimitedBounds) - CGRectGetMaxY(theOriginalFrame) + CGRectGetMinY(_theLimitedBounds),
                               MAX(CGRectGetMinY(_theLimitedBounds)-CGRectGetMinY(theOriginalFrame), translation.y));

            sender.view.center = CGPointMake(theOriginalCenter.x + translationX, theOriginalCenter.y + translationY);
            break;

        default:
            [self controlTheCropViewWithTranslation:translation];
            break;
    }
    
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void) updateControlPoint
{
    float pointSize = kPointSize;
    theTopLeftPoint.frame = CGRectMake(0, 0, pointSize, pointSize);
    theTopRightPoint.frame = CGRectMake(CGRectGetWidth(self.bounds) - pointSize, 0, pointSize, pointSize);
    theBotLeftPoint.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - pointSize, pointSize, pointSize);
    theBotRightPoint.frame = CGRectMake(CGRectGetWidth(self.bounds) - pointSize, CGRectGetHeight(self.bounds) - pointSize, pointSize, pointSize);

}
-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //add 4 control point view
    [self updateControlPoint];
}
-(void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    //add 4 control point view
    [self updateControlPoint];
}
- (void)setRatio:(float)ratio
{
    _ratio = ratio;
    _isManualMode = NO;
}
-(void) drawGridOnBorder:(CGContextRef) context
{
    float theCropControlButtonSize = 0;
    // Draw vertical the bounding box 1.
    CGRect rect1 = CGRectMake(theCropControlButtonSize/2 + (self.bounds.size.width-theCropControlButtonSize)/3,
                              theCropControlButtonSize/2,
                              (self.bounds.size.width-theCropControlButtonSize)/3,
                              self.bounds.size.height-theCropControlButtonSize);
    
    // Draw hozirontal the bounding box 1
    CGRect horizontalRect1 = CGRectMake(theCropControlButtonSize/2,
                                        theCropControlButtonSize/2 + (self.bounds.size.height-theCropControlButtonSize)/3,
                                        self.bounds.size.width - theCropControlButtonSize,
                                        (self.bounds.size.height-theCropControlButtonSize)/3);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    CGContextAddRect(context, rect1);
    
    CGContextAddRect(context, horizontalRect1);
    // draw
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawGridOnBorder:context];

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:1].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetLineWidth(context, 1.2);
    CGRect pathRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:0].CGPath;
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathEOFillStroke);
}
- (CGRect)getRelativeFrame
{
    float parentWidth = CGRectGetWidth(_theLimitedBounds);
    float parentHeight = CGRectGetHeight(_theLimitedBounds);
    float originX = (CGRectGetMinX(self.frame) - CGRectGetMinX(_theLimitedBounds))/parentWidth;
    float originY = (CGRectGetMinY(self.frame) - CGRectGetMinY(_theLimitedBounds))/parentHeight;
    float cropWidth = self.frame.size.width/parentWidth;
    float cropHeight = self.frame.size.height/parentHeight;
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    if (originX < 0)
    {
        cropWidth = cropWidth + originX;
        originX = 0;
    }
    if (originY < 0)
    {
        cropHeight = cropHeight + originY;
        originY = 0;
    }
    
    originX = MIN(0.95f, originX);
    originY = MIN(0.95f, originY);
    cropHeight = MAX(0.05f, MIN(1, cropHeight));
    cropWidth = MAX(0.05f, MIN(1, cropWidth));
    
    CGRect cropRect = CGRectMake(originX, originY, cropWidth, cropHeight);
    return cropRect;
}
@end
