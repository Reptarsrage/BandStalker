//
//  Album.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize tracks = _tracks;

- (void)addToTracks: (Track *)track {
    if (!_tracks )
        _tracks = [NSMutableArray arrayWithObjects:nil];
    
    //find correct place and add item
    NSUInteger index = [_tracks  indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(Track *)obj trackNumber] > track.trackNumber) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        [_tracks addObject:track];
    } else {
        [_tracks insertObject:track atIndex:index];
    }
    
}

- (void)removeFromTracks: (Track *)track {
    if (!_tracks )
        return;
    if (!track || track.name == nil)
        return;
    
    for (Track * a in _tracks) {
        if (a.name == track.name) {
            [_tracks removeObject:a];
            return;
        }
    }
    
}

- (void)removeFromTracksAtIndex: (int)pos {
    if (!_tracks || pos < 0 || pos >= [_tracks count])
        return
        
        [_tracks removeObjectAtIndex:pos];
}

@end
