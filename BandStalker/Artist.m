//
//  Artist.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "Artist.h"

@implementation Artist

@synthesize albums = _albums;

- (void)addToAlbums: (Album *)album {
    if (!_albums )
        _albums = [[NSMutableArray alloc] init];
    
    //find correct place and add item
    NSUInteger index = [_albums  indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(Album *)obj releaseDate] compare:album.releaseDate] == NSOrderedAscending) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        [_albums addObject:album];
    } else {
        [_albums insertObject:album atIndex:index];
    }
}

- (void)removeFromAlbums: (Album *)album {
    if (!_albums )
        return;
    if (!album || album.name == nil)
        return;
    
    for (Album * a in _albums) {
        if (a.name == album.name) {
            [_albums removeObject:a];
            return;
        }
    }
    
}

- (void)removeFromAlbumsAtIndex: (int)pos {
    if (pos < 0 || pos >= [_albums count])
        return
        
    [_albums removeObjectAtIndex:pos];
}

@end
