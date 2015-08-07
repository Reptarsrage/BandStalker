//
//  Artist.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"
#import "Event.h"

@interface Artist : NSObject {
    NSMutableArray * _albums;
}

@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *id;
@property (nonatomic) double popularity;
@property (nonatomic) long followers;
@property (nonatomic, retain)NSURL *image_url_small;
@property (nonatomic, retain)NSURL *image_url_med;
@property (nonatomic, retain)NSURL *image_url_large;
@property (nonatomic, retain)NSURL *href;
@property (nonatomic, retain, readonly) NSMutableArray *albums;
@property (nonatomic, retain, readonly) NSMutableArray *events;
@property NSInteger sectionNumber;
@property (nonatomic, retain)NSData *cached_image;
@property long latestLookup;
@property double image_aspect_ratio;

- (void)addToAlbums: (Album *)album;
- (void)removeFromAlbums: (Album *)album;
- (void)removeFromAlbumsAtIndex: (int)pos;

- (void)addToEvents: (Event *)album;
- (void)removeFromEvents: (Event *)album;
- (void)removeFromEventsAtIndex: (int)pos;

@end

