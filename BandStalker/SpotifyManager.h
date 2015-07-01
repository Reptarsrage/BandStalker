//
//  SpotifyManager.h
//  BandStalker
//
//  Created by Admin on 6/26/15.
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

typedef void (^SpotifyAlbumInfoCallback) (Album *album, NSError *error);

@interface SpotifyManager : NSObject  {
    long expires;
    NSString *SpotifyAccessToken;
    SPTSession *SpotifySession;
    NSMutableArray *artistQueue;
}

@property (nonatomic) long expires;
@property (nonatomic, retain) NSString *SpotifyAccessToken;
@property (nonatomic, retain) NSMutableArray *artistQueue;
@property (nonatomic, retain) SPTSession *SpotifySession;

- (BOOL)login;
- (void)retrieveArtistInfoFromSpotify:(Artist *)artist forController:(ArtistsTableViewController *)controller;
-(void)getAllAlbumsForArtist:(NSString *)uid pageURL:(NSURLRequest *)nextPage withAlbumUris:(NSMutableArray *)uris withCallback:(SpotifyAlbumInfoCallback)callback;
-(void)getAllTracksForAlbum:(Album *)album withCallback:(SpotifyAlbumInfoCallback)callback;


+ (id)sharedManager;

@end
