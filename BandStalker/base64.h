//
//  base64.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface base64 : NSObject
+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
+ (NSData *) base64DataFromString:(NSString *)string;
+ (NSString *)toBase64String:(NSString *)string;
+ (NSString *)fromBase64String:(NSString *)string;
@end
