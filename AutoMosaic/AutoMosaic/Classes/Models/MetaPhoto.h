//
//  MetaPhoto.h
//  AutoMosaic
//
//  Created by Hai Hw on 21/12/14.
//  Copyright (c) 2014 HW Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaPhoto : NSObject
@property (strong) UIImage *photo;
/**
 Everage color of the meta photo
 */
@property (strong) UIColor *averageColor;
/**
 Count number of usage
 */
@property (assign) int usedCount;
@end
