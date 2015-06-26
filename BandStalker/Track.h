//
//  Track.h
//  BandStalker
//
//  Created by Admin on 6/25/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *id;
@property (nonatomic, retain)NSURL *href; //sharingURL
@property (nonatomic, retain)NSURL *preview; //previewURL
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSInteger discNumber;
@property (nonatomic) BOOL flaggedExplicit;
@property (nonatomic) NSInteger trackNumber;

@end
