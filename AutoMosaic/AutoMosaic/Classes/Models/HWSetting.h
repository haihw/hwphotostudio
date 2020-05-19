//
//  HWSetting.h
//  Mosaicify
//
//  Created by Hai Hw on 19/5/20.
//  Copyright © 2020 HW Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
NS_ASSUME_NONNULL_BEGIN

@interface HWSetting : NSObject
@property (strong, nonatomic) PHAssetCollection *selectedCollection;
+(HWSetting *)sharedSetting;
@end

NS_ASSUME_NONNULL_END
