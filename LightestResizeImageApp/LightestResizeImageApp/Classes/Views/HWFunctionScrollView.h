//
//  HWFunctionScrollView.h
//
//  Created by Hai Hw on 11/30/13.
//  Copyright (c) 2013 Hw Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HWFunctionScrollViewDelegate;

@interface HWFunctionScrollView : UIScrollView
{
    
    NSMutableArray *theSubFunctionViews;
    NSMutableArray *theSubFunctionImageViews;
    NSMutableArray *theSubFunctionLabels;
    
    
    NSInteger theCurrentSelectedTag;

    int theButtonHeight;
    int theButtonLabelHeight;
    int theButtonWidth;
    NSInteger disableFuctionTag;
}
@property (nonatomic, assign) NSInteger minButtonWidth;
@property (nonatomic, assign) BOOL hasHeightLightBackground;
@property (nonatomic, weak) id<HWFunctionScrollViewDelegate> functionDelegate;
@property (nonatomic, strong) NSArray *theSubFunctionTitles;
@property (nonatomic, strong) NSArray *theSubFunctionOffImageNames;
@property (nonatomic, strong) NSArray *theSubFunctionOnImageNames;
- (void)createSubFunctionGUI;
- (void)manualChangeToSubFunctionViewWithTag:(NSInteger)tag;
- (void)setEnableForFunction:(NSInteger)tag enabled:(BOOL)enabled;
- (void)setFunction:(NSInteger)tag withTitle:(NSString*)title;
@end

@protocol HWFunctionScrollViewDelegate <NSObject>

@optional
- (void)HWFunctionScrollView:(HWFunctionScrollView*)scrollView callSubFunctionWithTag:(NSInteger)tag;
@end