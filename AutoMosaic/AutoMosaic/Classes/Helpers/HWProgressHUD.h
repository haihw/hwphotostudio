//
//  HWProgressHUD.h
//  AutoMosaic
//
//  Created by Hai Hw on 20/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import "MBProgressHUD.h"

@interface HWProgressHUD : MBProgressHUD
+ (HWProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated withTitle:(NSString*) title;
+ (HWProgressHUD *)showHUDAddedTo:(UIView *)view dimBackground:(BOOL) shouldDim animated:(BOOL)animated withTitle:(NSString*) title;
@end
