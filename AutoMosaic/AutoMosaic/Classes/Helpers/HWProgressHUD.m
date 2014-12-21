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
    HWProgressHUD *hud = [[super alloc] initWithView:view];
    hud.detailsLabelText = title;
    hud.color = [UIColor colorWithWhite:0.5f alpha:0.5f];
    hud.detailsLabelColor = [UIColor greenColor];
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}

+ (HWProgressHUD *)showHUDAddedTo:(UIView *)view dimBackground:(BOOL) shouldDim animated:(BOOL)animated withTitle:(NSString*) title {
    HWProgressHUD *hud = [[super alloc] initWithView:view];
    hud.color = [UIColor colorWithWhite:0.5f alpha:0.5f];
    hud.detailsLabelColor = [UIColor greenColor];
    hud.dimBackground = shouldDim;
    hud.detailsLabelText = title;
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}
@end
