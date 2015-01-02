//
//  HWRotateView.m
//  UboxPhotoFilter
//
//  Created by Hai Hw on 9/12/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//

#import "HWRotateView.h"
#import "UIImageExtras.h"
@implementation HWRotateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createGUI];
    }
    return self;
}

- (void)createGUI
{
    int theButtonHeight = 44;
    int theButtonLabelHeight = 15;
    int theButtonWidth = 80;
    int theAddingSpace = 0;
    
    NSArray *theFunctionTitles = @[@"Left",
                                   @"Right",
                                   @"HFlip",
                                   @"VFlip",
                                   ];
    NSArray *theButtonImageNameOn = @[@"UboxPhotoEditorResources.bundle/img_btn_edit_rotate_left_on",
                                      @"UboxPhotoEditorResources.bundle/img_btn_edit_rotate_right_on",
                                      @"UboxPhotoEditorResources.bundle/img_btn_edit_flip_horizontal_on",
                                      @"UboxPhotoEditorResources.bundle/img_btn_edit_flip_vertical_on",
                                      ];
    NSArray *theButtonImageNameOff = @[@"UboxPhotoEditorResources.bundle/img_btn_edit_rotate_left_off",
                                       @"UboxPhotoEditorResources.bundle/img_btn_edit_rotate_right_off",
                                       @"UboxPhotoEditorResources.bundle/img_btn_edit_flip_horizontal_off",
                                       @"UboxPhotoEditorResources.bundle/img_btn_edit_flip_vertical_off",
                                       ];
    int theNumberOfFunction = theFunctionTitles.count;
    int theButtonOriginY = (self.bounds.size.height - theButtonHeight - theButtonLabelHeight)/2;
    for (int i=0; i<theNumberOfFunction; i++)
    {
        UIButton *oneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        oneButton.frame = CGRectMake(theAddingSpace + (theAddingSpace+theButtonWidth)*i, theButtonOriginY, theButtonWidth, theButtonHeight);
        oneButton.tag = i;
        oneButton.contentMode = UIViewContentModeTop;
        [oneButton setImage:[UIImage imageNamed:theButtonImageNameOff[i]] forState:UIControlStateNormal];
        [oneButton setImage:[UIImage imageNamed:theButtonImageNameOn[i]] forState:UIControlStateHighlighted];
        [oneButton addTarget:self action:@selector(btnActionTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(theAddingSpace + (theAddingSpace+theButtonWidth)*i, theButtonOriginY + theButtonHeight, theButtonWidth, theButtonLabelHeight)];
        oneLabel.text = theFunctionTitles[i];
        oneLabel.contentMode = UIViewContentModeBottom;
        oneLabel.backgroundColor = [UIColor clearColor];
        oneLabel.textColor = [UIColor whiteColor];
        oneLabel.textAlignment = NSTextAlignmentCenter;
        oneLabel.font = [UIFont boldSystemFontOfSize:11];
        [self insertSubview:oneLabel belowSubview:oneButton];
        [self addSubview:oneButton];
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)btnActionTapped:(UIButton*)sender
{
    CGAffineTransform theNewTransform;
    switch (sender.tag) {
        case UBoxRotateLeft:
        {
            int turnLookups[] = {7, 6, 5, 4, 0, 1, 2, 3};
            currentOrientationState = turnLookups[currentOrientationState];
            theNewTransform = CGAffineTransformRotate(theRotateImageView.transform, -M_PI_2);
            break;
        }
        case UBoxRotateRight:
        {
            int turnLookups[] = {4, 5, 6, 7, 3, 2, 1, 0};
            currentOrientationState = turnLookups[currentOrientationState];
            theNewTransform = CGAffineTransformRotate(theRotateImageView.transform, M_PI_2);
            break;
        }
        case UBoxRotateHozirotalFlip:
        {
            int turnLookups[] = {1, 0, 3, 2, 6, 7, 4, 5};
            currentOrientationState = turnLookups[currentOrientationState];
            theNewTransform = CGAffineTransformScale(theRotateImageView.transform, -1, 1);
            break;
        }
        case UBoxRotateVerticalFlip:
        {
            int turnLookups[] = {2, 3, 0, 1, 5, 4, 7, 6};
            currentOrientationState = turnLookups[currentOrientationState];
            theNewTransform = CGAffineTransformScale(theRotateImageView.transform, 1, -1);
            break;
        }
        default:
            break;
    }
    
    //animatino
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        theRotateImageView.transform = theNewTransform;
    } completion:^(BOOL finished) {
        
    }];
}
-(UIImage *) getRotationAndFlipImage:(int)stage from:(UIImage*)inputImage
{
    UIImage *output = inputImage;
    switch (stage) {
        case 0:
            output =  [inputImage rotate:UIImageOrientationUp];
            break;
        case 1: // HF
            output =  [inputImage rotate:UIImageOrientationUpMirrored];
            break;
        case 2: // VF
            output =  [inputImage rotate:UIImageOrientationDownMirrored];
            break;
        case 3: // RR ( down)
            output =  [inputImage rotate:UIImageOrientationDown];
            break;
        case 4:
            output =  [inputImage rotate:UIImageOrientationRight];
            break;
        case 5:
            output =  [inputImage rotate:UIImageOrientationLeftMirrored];
            break;
        case 6:
            output =  [inputImage rotate:UIImageOrientationRightMirrored];
            break;
        case 7:
            output =  [inputImage rotate:UIImageOrientationLeft];
            break;
        default:
            output =  inputImage;
    }
    return output;
}
#pragma mark - overide methods
- (void)didCancelFeature
{
    theRotateImageView.hidden = YES;
}
- (void)didApplyFeature
{
    NSLog(@"Save effect");
    UIImage *anInputImage;
//    if (anInputImage)
//        [HWCommonConfigurator sharedInstance].theEditingResultImage = [self getRotationAndFlipImage:currentOrientationState from:anInputImage];
//    else
    {
        NSLog(@"No Filter Available");
    }
    theRotateImageView.hidden = YES;
}
- (void)active
{
    theRotateImageView.hidden = NO;
    [self reset];
}
- (void)reset
{
    currentOrientationState = 0;
//    theRotateImageView.image = [HWCommonConfigurator sharedInstance].theEditingResultImage;
    theRotateImageView.transform = CGAffineTransformIdentity;
    NSLog(@"orientation: %d", theRotateImageView.image.imageOrientation);
}
#pragma settor
- (void)setThePreviewView:(UIView *)thePreviewView
{
//    [super setThePreviewView:thePreviewView];
    theRotateImageView = [[UIImageView alloc] initWithFrame:thePreviewView.bounds];
    theRotateImageView.contentMode = UIViewContentModeScaleAspectFit;
//    theRotateImageView.image = [HWCommonConfigurator sharedInstance].theEditingResultImage;
    [thePreviewView addSubview:theRotateImageView];
}
@end
