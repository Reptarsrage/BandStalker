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
#import "CommonController.h"

typedef void (^SpotifyAlbumInfoCallback) (Album *album, NSError *error);

@interface SpotifyManager : NSObject  {
    NSTimeInterval expires;
    NSString *SpotifyAccessToken;
    SPTSession *SpotifySession;
    NSMutableArray *artistQueue;
}

@property (nonatomic) NSTimeInterval expires;
@property (nonatomic, retain) NSString *SpotifyAccessToken;
@property (nonatomic, retain) NSMutableArray *artistQueue;
@property (nonatomic, retain) SPTSession *SpotifySession;
@property (nonatomic) BOOL newItems;

- (NSMutableArray *) popDeletedArtistQueue;
- (void) removeArtist:(Artist *)artist;
- (BOOL)login;
- (void)retrieveArtistInfoFromSpotify:(Artist *)artist forController:(ArtistsTableViewController *)controller;
-(void)getAllAlbumsForArtist:(NSString *)uid pageURL:(NSURLRequest *)nextPage withAlbumUris:(NSMutableArray *)uris withCallback:(SpotifyAlbumInfoCallback)callback;
-(void)getAllTracksForAlbum:(Album *)album withCallback:(SpotifyAlbumInfoCallback)callback;
-(BOOL)makeBackGroundRequest:(NSInteger)capacity withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (id)sharedManager;

@end
