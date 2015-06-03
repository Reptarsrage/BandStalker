//
//  Artist.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface Artist : NSObject {
    NSMutableArray * _albums;
}

@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *id;
@property (nonatomic, retain)NSString *image_url_small;
@property (nonatomic, retain)NSString *image_url_med;
@property (nonatomic, retain)NSString *image_url_large;
@property (nonatomic, retain)NSString *href;
@property (nonatomic, retain, readonly) NSMutableArray *albums;

- (void)addToAlbums: (Album *)album;

- (void)removeFromAlbums: (Album *)album;

- (void)removeFromAlbumsAtIndex: (int)pos;

@end

