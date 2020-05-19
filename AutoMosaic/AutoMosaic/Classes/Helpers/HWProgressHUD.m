//
//  HWProgressHUD.m
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "HWProgressHUD.h"
@implementation HWProgressHUD

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (HWProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated withTitle:(NSString*) title {
    return [self showHUDAddedTo:view dimBackground:NO animated:animated withTitle:title];
}

+ (HWProgressHUD *)showHUDAddedTo:(UIView *)view dimBackground:(BOOL) shouldDim animated:(BOOL)animated withTitle:(NSString*) title {
    HWProgressHUD *hud = [[super alloc] initWithView:view];
    hud.detailsLabel.text = title;
    hud.label.textColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
    hud.detailsLabel.textColor = [UIColor greenColor];
    if (shouldDim){
        hud.backgroundView.alpha = 0.5f;
    }
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}
@end
