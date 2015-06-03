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
    
    [_albums addObject:album];
    
    _albums = (NSMutableArray *)[_albums sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = ((Album*)a).releaseDate;
        NSDate *second = ((Album*)b).releaseDate;
        return [first compare:second];
    }];
    
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
