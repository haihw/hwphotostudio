//
//  HWSetting.m
//  Mosaicify
//
//  Created by Hai Hw on 19/5/20.
//  Copyright © 2020 HW Inc. All rights reserved.
//

#import "HWSetting.h"

@implementation HWSetting
+(HWSetting *)sharedSetting
{
    // 1
    static HWSetting *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HWSetting alloc] init];
    });
    return _sharedInstance;
}
@end
