//
//  bandsInTownManager.h
//  BandStalker
//
//  Created by Admin on 8/6/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import "Artist.h"
#import "Album.h"
#import "Track.h"
#import "ArtistsTableViewController.h"
#import "AlbumsTableViewController.h"
#import "ArtistDrilldownTableViewController.h"
#import "CommonController.h"
#import "Event.h"

typedef void (^BandsInTownEventInfoCallback) (Event *album, NSError *error);

@interface bandsInTownManager : NSObject  {
    NSString *app_id;
    NSMutableArray *artistQueue;
    NSMutableArray *deletedArtistQueue;
    BOOL newItems;
}

@property (nonatomic, retain) NSString *app_id;
@property (nonatomic, retain) NSMutableArray *artistQueue;
@property (nonatomic, retain) NSMutableArray *deletedArtistQueue;
@property (nonatomic) BOOL newItems;

- (NSMutableArray *) popDeletedArtistQueue;
- (void) removeArtist:(Artist *)artist;
- (void) getUpcomingEventForArtist:(Artist *)artist withCallback:(BandsInTownEventInfoCallback)callback;

+ (id)sharedManager;

@end
