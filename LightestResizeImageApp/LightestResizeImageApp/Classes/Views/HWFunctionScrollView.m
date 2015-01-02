//
//  HWFunctionScrollView.m
//
//  Created by Hai Hw on 11/30/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//

#import "HWFunctionScrollView.h"
//#import "TBCommonConfigurator.h"
#import <QuartzCore/QuartzCore.h>
#define kFxFontSize 10

@implementation HWFunctionScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        disableFuctionTag = -1;
        _minButtonWidth = 60;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)createSubFunctionGUI
{
    if (!(_theSubFunctionTitles && _theSubFunctionOnImageNames && _theSubFunctionOffImageNames))
    {
        NSLog(@"Need init titles and image names for sub-function");
        return;
    }
    theButtonWidth = self.bounds.size.width / _theSubFunctionTitles.count;
    if (theButtonWidth < _minButtonWidth)
        theButtonWidth = _minButtonWidth;
    
    NSLog(@"Created function scroll view at frame: %@", NSStringFromCGRect(self.frame));
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setPagingEnabled:NO];
    self.contentSize = CGSizeMake(_theSubFunctionTitles.count * theButtonWidth, self.bounds.size.height);
    
    //create scroll view for main feature
    theButtonHeight = self.bounds.size.height;
    theButtonLabelHeight = 12;
    int theNumberOfFunction = _theSubFunctionTitles.count;
    theSubFunctionViews = [NSMutableArray arrayWithCapacity:theNumberOfFunction];
    theSubFunctionImageViews = [NSMutableArray arrayWithCapacity:theNumberOfFunction];
    theSubFunctionLabels = [NSMutableArray arrayWithCapacity:theNumberOfFunction];
    
    //setup view
    for (int i=0; i<theNumberOfFunction; i++)
    {
        UIView *oneSubFunctionView = [[UIView alloc] initWithFrame:CGRectMake(theButtonWidth*i, 0, theButtonWidth, theButtonHeight)];
        [theSubFunctionViews addObject:oneSubFunctionView];
        oneSubFunctionView.tag = i;
        oneSubFunctionView.backgroundColor = [UIColor clearColor];
        
        //thumbnail for function
        UIImageView *thumbnailImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, theButtonWidth, theButtonHeight - theButtonLabelHeight)];
        [theSubFunctionImageViews addObject:thumbnailImg];
        thumbnailImg.backgroundColor = [UIColor clearColor];
        thumbnailImg.contentMode = UIViewContentModeCenter;
        thumbnailImg.image = [UIImage imageNamed:_theSubFunctionOffImageNames[i]];
        thumbnailImg.tag = i;
        [oneSubFunctionView addSubview:thumbnailImg];
        //add label
        UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(oneSubFunctionView.bounds) - theButtonLabelHeight, CGRectGetWidth(oneSubFunctionView.bounds), theButtonLabelHeight-2)];
//        NSLog(@"Label :%d at frame:%@", i, NSStringFromCGRect(oneLabel.frame));
        [theSubFunctionLabels addObject:oneLabel];
        oneLabel.text = _theSubFunctionTitles[i];
        oneLabel.contentMode = UIViewContentModeBottom;
        oneLabel.backgroundColor = [UIColor clearColor];
        oneLabel.textColor = [UIColor grayColor];
        oneLabel.textAlignment = NSTextAlignmentCenter;
        oneLabel.font = [UIFont boldSystemFontOfSize:kFxFontSize];
        [oneSubFunctionView addSubview:oneLabel];
        
        [self addSubview:oneSubFunctionView];
        //add tap getsture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subFunctionTapped:)];
        [oneSubFunctionView addGestureRecognizer:tapGesture];
    }
}
- (IBAction)subFunctionTapped:(UITapGestureRecognizer*)sender
{
    NSLog(@"Subfucion tapped: %d", sender.view.tag);
    if (sender.view.tag == disableFuctionTag)
        return;
    [self manualChangeToSubFunctionViewWithTag:sender.view.tag];
}
- (void)manualChangeToSubFunctionViewWithTag:(NSInteger)tag
{
    for (UIImageView *imgView in theSubFunctionImageViews)
    {
        imgView.image = [UIImage imageNamed:_theSubFunctionOffImageNames[imgView.tag]];
    }
    for (UILabel *label in theSubFunctionLabels)
    {
        label.textColor = [UIColor grayColor];
    }
    
    ((UIImageView *) theSubFunctionImageViews[tag]).image = [UIImage imageNamed:_theSubFunctionOnImageNames[tag]];
    
    ((UILabel *) theSubFunctionLabels[tag]).textColor = [UIColor colorWithRed:38.0/255.0 green:131.0/255.0 blue:179.0/255.0 alpha:1];
    if (_functionDelegate && [_functionDelegate respondsToSelector:@selector(UBFunctionScrollView:callSubFunctionWithTag:)])
    {
        [_functionDelegate HWFunctionScrollView:self callSubFunctionWithTag:tag];
    }
    //change shadow for height-lighted
    if (_hasHeightLightBackground)
    {
        if (theCurrentSelectedTag >= 0)
        {
            UIView *view = theSubFunctionImageViews[theCurrentSelectedTag];
            view.layer.shadowColor = [UIColor clearColor].CGColor;
        }
        UIView *newView = theSubFunctionImageViews[tag];
        newView.layer.shadowColor = [UIColor blueColor].CGColor;
//        newView.layer.shadowOffset = CGSizeMake(0, 0);
        newView.layer.shadowOpacity = 1;
        newView.layer.shadowRadius = 10;

    }
    theCurrentSelectedTag = tag;
}
-(void)setEnableForFunction:(NSInteger)tag enabled:(BOOL)enabled
{
    if (!enabled)
    {
        if (!((UIView*)theSubFunctionViews[tag]).hidden)
        {
            //disappear
            disableFuctionTag = tag;
            [(UIView*)theSubFunctionViews[tag] setHidden:YES];
            //shift frame of right views
            int totalFunction = theSubFunctionViews.count;
            for (int i=tag+1; i<totalFunction; i++)
            {
                UIView *oneView = theSubFunctionViews[i];
                oneView.frame = CGRectMake(CGRectGetMinX(oneView.frame) - CGRectGetWidth(oneView.frame),
                                           CGRectGetMinY(oneView.frame),
                                           CGRectGetWidth(oneView.frame),
                                           CGRectGetHeight(oneView.frame));
            }
        }
    }
    else if (disableFuctionTag == tag && ((UIView*)theSubFunctionViews[tag]).hidden)
    {
        //appear
        [(UIView*)theSubFunctionViews[tag] setHidden:NO];
        int totalFunction = theSubFunctionViews.count;
        for (int i=tag+1; i<totalFunction; i++)
        {
            UIView *oneView = theSubFunctionViews[i];
            oneView.frame = CGRectMake(CGRectGetMinX(oneView.frame) + CGRectGetWidth(oneView.frame),
                                       CGRectGetMinY(oneView.frame),
                                       CGRectGetWidth(oneView.frame),
                                       CGRectGetHeight(oneView.frame));
        }

        disableFuctionTag = -1;
    }
}
-(void)setFunction:(NSInteger)tag withTitle:(NSString *)title
{
    ((UILabel*)theSubFunctionLabels[tag]).text = title;
}
@end
