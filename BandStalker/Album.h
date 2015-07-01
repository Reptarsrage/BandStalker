//
//  Album.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

@interface Album : NSObject {
    
}

@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *id;
@property (nonatomic) double popularity;
@property (nonatomic, retain)NSString *type;
@property (nonatomic, retain)NSDate *releaseDate;
@property (nonatomic, retain)NSURL *image_url_small;
@property (nonatomic, retain)NSURL *image_url_med;
@property (nonatomic, retain)NSURL *image_url_large;
@property (nonatomic, retain)NSURL *href;
@property (nonatomic, retain)NSString *artist;
@property NSInteger sectionNumber;
@property (nonatomic, retain)NSData *cached_image;
@property (nonatomic, retain)NSURLRequest *nextTrackPageUrl;
@property (nonatomic, retain, readonly)NSMutableArray *tracks;


- (void)addToTracks: (Track *)album;

- (void)removeFromTracks: (Track *)album;

- (void)removeFromTracksAtIndex: (int)pos;
@end
