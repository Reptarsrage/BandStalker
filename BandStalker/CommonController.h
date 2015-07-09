//
//  CommonController.h
//  BandStalker
//
//  Created by Admin on 7/8/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonController : NSObject

+ (UIView *)getErrorLabel:(CGRect)frame withTitle:(NSString *) title withMsg:(NSString *) msg;

@end
