//
//  SpotifyManager.m
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SpotifyManager.h"

@interface SpotifyManager()
//private methods
- (void)getAllArtistInfo:(NSMutableArray *)artistUIds forController:(ArtistsTableViewController *)controller;
-(void)getDetailedAlbumInfo:(NSMutableArray *)uris withPage:(NSURLRequest *)nextPage withController:(AlbumsTableViewController *)controller;
@end

@implementation SpotifyManager {
    @private
    NSMutableArray *allArtists;
}

@synthesize expires;
@synthesize artistQueue;
@synthesize SpotifyAccessToken;
@synthesize SpotifySession;


const NSString *client_id = @"88ac57858a2e451c95cb5334f11686db";
const NSString * client_secret = @"75a5b55e12b64fd7b82c6870beba34c3";

// Logs the app in using my account and credentials, expires in awhile
- (BOOL)login {
    NSURL *loginUrl = [NSURL URLWithString:@"https://accounts.spotify.com/api/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginUrl
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // add the correct headers
    NSString *base_str = [NSString stringWithFormat:@"%@:%@", client_id, client_secret];
    NSData *base_bits = [base_str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encoded_str = [base_bits base64EncodedStringWithOptions:0];
    NSString *header = [NSString stringWithFormat:@"Basic %@", encoded_str];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    
    // add the body
    NSData *body = [@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *body_length = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:body_length forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error logging in: %@",error);
        return NO;
    }
    
    NSMutableDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData
                                                                options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error parsing login response: %@",error);
        return NO;
    }
    
    SpotifyAccessToken = [data valueForKey:@"access_token"];
    expires = [[data valueForKey:@"expires_in"] longValue];
    
    if (!SpotifyAccessToken) {
        NSLog(@"Error parsing login response: no token");
        return NO;
    }
    
    if (!expires) {
        NSLog(@"Error parsing login response: no expiration");
        return NO;
    }
    
    SpotifySession = [[SPTSession alloc] initWithUserName:@"reptarsrage" accessToken:SpotifyAccessToken expirationTimeInterval:expires];
    
    return YES;
}

// gets uid for one artist
- (void)retrieveArtistInfoFromSpotify:(Artist *)artist forController:(ArtistsTableViewController *)controller {
    if (allArtists == nil)
        allArtists = [NSMutableArray arrayWithCapacity:1];
    if (artistQueue == nil)
        artistQueue = [NSMutableArray arrayWithCapacity:1];
    
    [SPTSearch performSearchWithQuery:artist.name queryType:SPTQueryTypeArtist accessToken:SpotifyAccessToken callback:^(NSError *error, id object) {
        if (error != nil) {
            [controller artistInfoCallback:NO artist:artist error:error];
        } else {
            SPTListPage *page = object;
            
            if ([page.items count] <= 0) {
                [controller artistInfoCallback:NO artist:artist error:[NSError errorWithDomain:@"No results found" code:404 userInfo:nil]];
            } else {
                
                SPTPartialArtist *o = [page.items firstObject];
                artist.name = o.name;
                artist.id = (NSString *)o.uri ;
                artist.href = o.sharingURL;
                [allArtists addObject:artist]; //artistIDs
                [artistQueue addObject:artist];
                
                // get detailed info for each artist
                //TODO make one bulk call instead of many calls
                [self getAllArtistInfo:[NSMutableArray arrayWithObjects:artist.id, nil] forController:controller];
            }
        }
    }];
}


- (void)getAllArtistInfo:(NSMutableArray *)artistUIds forController:(ArtistsTableViewController *)controller{
    [SPTArtist artistsWithURIs:artistUIds session:SpotifySession callback:^(NSError *error, id object) {
        if (error != nil) {
            NSLog(@"Error retrieving artist info for artists: %@", error);
            return;
        }
        
        NSArray *results = object;
        
        if ([results count] != [artistUIds count]) {
            NSLog(@"Error retrieving artist info : %@", @"No results found");
            return;
        }
        
        for (SPTArtist *a in results) {
            Artist *a1 = nil;
            NSUInteger index;
            index = [allArtists indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([[(Artist *)obj name] isEqualToString:a.name]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (index != NSNotFound && a.uri != nil) {
                a1 = [allArtists objectAtIndex:index];
                a1.image_url_large = a.largestImage.imageURL;
                a1.image_url_small = a.smallestImage.imageURL;
                a1.image_url_med = nil;
                a1.popularity = a.popularity;
                a1.followers = a.followerCount;
                
                //update in table
                [controller artistInfoCallback:YES artist:a1 error:nil];
                
            } else {
                NSLog(@"Error updating artist info for %@: %@", a.name, @"Artist not found in table");
            }
        }
    }];
}


-(void)getAllAlbumsForArtist:(NSString *)uid pageURL:(NSURLRequest *)nextPage withAlbumUris:(NSMutableArray *)uris withController:(AlbumsTableViewController *)controller {
    NSError *error = nil;
    NSURLRequest *req ;
    if (nextPage == nil) {
        req = [SPTArtist createRequestForAlbumsByArtist:(NSURL *)uid ofType:SPTAlbumTypeAlbum withAccessToken:SpotifyAccessToken market:[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] error:&error];
    } else {
        req = nextPage;
    }
    
    if (uris == nil) {
        uris = [NSMutableArray arrayWithCapacity:1];
    }
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) { // TIMEOUT
                [self getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris withController:controller];
            } else {
                NSLog(@"Error retrieving album info for artist with id %@: %@", uid, error);
            }
            
            return;
        }
        
        SPTListPage *page = [SPTListPage  listPageFromData:data withResponse:response expectingPartialChildren:NO rootObjectKey:nil error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing albums data for artist with id %@: %@", uid, error);
            return;
        }
        
        for (SPTAlbum *album in page.items) {
            [uris addObject:(NSString *)album.uri];
            
        }
        
        if (page.nextPageURL != nil) {
            NSURLRequest *nextRequest = [page createRequestForNextPageWithAccessToken:SpotifyAccessToken error:&error];
            
            if (error != nil || error == NULL) {
                [self getAllAlbumsForArtist:uid pageURL:nextRequest withAlbumUris:uris withController:controller];
            } else {
                NSLog(@"Error retrieving the next page. Failed to create request: %@", error);
            }
        } else {
            if ([uris count] != page.totalListLength) {
                NSLog(@"Error retrieving albums. %lu albums parsed does not equal %luld total albums in list.", (unsigned long)[uris count], page.totalListLength);
            }
            [self getDetailedAlbumInfo:uris withPage:nil withController:controller];
        }
    }];
}


-(void)getDetailedAlbumInfo:(NSMutableArray *)uris withPage:(NSURLRequest *)nextPage withController:(AlbumsTableViewController *)controller {
    NSError *error;
    NSURLRequest *req;
    
    if (nextPage == nil) {
        req = [SPTAlbum createRequestForAlbums:uris withAccessToken:SpotifyAccessToken market:[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] error:&error];
    } else {
        req = nextPage;
    }
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) {
                [self getDetailedAlbumInfo:uris withPage:nextPage withController:controller];
            } else {
                NSLog(@"Error retrieving detailed album info for multiple albums: %@", error);
            }
            
            return;
        }
        
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error != nil) {
            NSLog(@"Error parsing JSON data for albums.");
            return;
        }
        NSArray *albums = [SPTAlbum albumsFromDecodedJSON:json error:&error];
        
        
        
        if (error != nil) {
            NSLog(@"Error parsing detailed album data for multiple albums: %@", error);
            return;
        }
        
        for (SPTAlbum *album in albums) {
            Album *a = [[Album alloc] init];
            a.name = album.name;
            a.id = (NSString *)album.uri;
            a.releaseDate = album.releaseDate;
            //a.sectionNumber = [controller getAlbumSection:a.releaseDate];
            a.artist = [(SPTArtist *)[album.artists firstObject] name];
            a.image_url_large = album.largestCover.imageURL;
            a.image_url_small = album.smallestCover.imageURL;
            a.image_url_med = nil;
            a.href = album.sharingURL;
            a.popularity = album.popularity;
            
            switch (album.type) {
                case SPTAlbumTypeAlbum:
                    a.type = @"Full Album";
                    break;
                case SPTAlbumTypeSingle:
                    a.type = @"Single";
                    break;
                case SPTAlbumTypeCompilation:
                    a.type = @"Compilation";
                    break;
                case SPTAlbumTypeAppearsOn:
                    a.type = @"Appears on";
                    break;
                default:
                    break;
            }
            
            NSInteger length = [(SPTListPage *)album.firstTrackPage totalListLength];
            for (int i=0; i < length; i++) {
                Track *t = [[Track alloc] init];
                t.trackNumber = i + 1;
                t.name = @"Unkown";
                [a addToTracks:t];
            }
            
            for (SPTPartialTrack *track in [(SPTListPage *)album.firstTrackPage items]) {
                Track *t = [a.tracks objectAtIndex:track.trackNumber - 1];
                t.id = (NSString *)track.uri;
                t.discNumber = track.discNumber;
                t.href = track.sharingURL;
                t.preview = track.previewURL;
                t.duration = track.duration;
                t.flaggedExplicit = track.flaggedExplicit;
                t.name = track.name;
            }
            
            a.nextTrackPageUrl = [(SPTListPage *)album.firstTrackPage nextPageURL];
            
            [controller albumInfoCallback:YES album:a error:nil];
            
            // add to artist
            NSUInteger index;
            index = [allArtists indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([[(Artist *)obj name] isEqualToString:a.artist]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (index != NSNotFound) {
                [[allArtists objectAtIndex:index] addToAlbums:a];
            }
        }
    }];
}

#pragma mark Singleton Methods

+ (id)sharedManager {
    static SpotifyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // default values
        //someProperty = @"Default Property Value";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
