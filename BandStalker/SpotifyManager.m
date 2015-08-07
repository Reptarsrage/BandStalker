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
-(void)getDetailedAlbumInfo:(NSMutableArray *)uris withPage:(NSURLRequest *)nextPage withCallback:(SpotifyAlbumInfoCallback)callback;
-(BOOL)loginValidate;

@end

@implementation SpotifyManager {
    @private
    NSMutableArray *allArtists;
    NSMutableArray *deletedArtists;
    BOOL needsLogin;
    NSInteger loginTryCount;
    NSLock *loginLock;
}

@synthesize expires;
@synthesize artistQueue;
@synthesize SpotifyAccessToken;
@synthesize SpotifySession;
@synthesize newItems;


const NSString *client_id = @"88ac57858a2e451c95cb5334f11686db";
const NSString * client_secret = @"75a5b55e12b64fd7b82c6870beba34c3";

-(BOOL)loginValidate {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if ((long)expires <= (long)now) {
        return NO;
    }
    
    return YES;
}

-(BOOL)makeBackGroundRequest:(NSInteger)capacity withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (! [self loginValidate]) {
        NSInteger i = 0;
        while (![self login]) {
            // do in background?
            i++;
            if (i > 3) {
                completionHandler(UIBackgroundFetchResultFailed);
                return NO;
            }
        }
    }
    
    if (allArtists == nil)
        allArtists = [NSMutableArray arrayWithCapacity:1];
    if (artistQueue == nil)
        artistQueue = [NSMutableArray arrayWithCapacity:1];
    
    // get the list of uids
    int i = 0;
    NSUInteger latestLookup = 0;
    NSUInteger replaceIndex = 0;
    NSMutableArray *artistsToQuery = [NSMutableArray arrayWithCapacity:1];
    for (Artist *artist in allArtists) {
        
        // fill to capacity first off
        if (i < capacity) {
            [artistsToQuery addObject:artist];
            if (artist.latestLookup > latestLookup) {
                latestLookup = artist.latestLookup;
                replaceIndex = i;
            }
            i++;
            continue;
        }
        
        // if artists latest look happened before the latest lookup in the current set, then replace it
        // in other words, allways lookup the artist who's been waiting the longest
        if (artist.latestLookup < latestLookup) {
            // replace and find newest latest lookup
            [artistsToQuery replaceObjectAtIndex:replaceIndex withObject:artist];
            latestLookup = NSIntegerMax;
            replaceIndex = 0;
            
            for (Artist *a in artistsToQuery) {
                if (a.latestLookup < latestLookup) {
                    latestLookup = artist.latestLookup;
                    replaceIndex = [artistsToQuery indexOfObject:a];
                }
            }
            
        }
    }
    
    
    // perform lookup of all artists
    __block NSInteger finished = 0;
    __block BOOL newData = NO;
    for (Artist *a in artistsToQuery) {
        [self getAllAlbumsForArtist:a.id pageURL:nil withAlbumUris:nil withCallback:^(Album *album, NSError *error) {
            finished++;
            
            if (error != nil && finished >= artistsToQuery.count) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            
            if (album != nil) {
                newData = YES;
                // new album found!
                if ([[[UIApplication sharedApplication]  currentUserNotificationSettings] types] & UIUserNotificationTypeAlert) {
                    // send an alert
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    
                    // Date
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.timeStyle = NSDateFormatterShortStyle;
                    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    [dateFormatter setLocale:usLocale];
                    
                    
                    notification.alertTitle = [NSString stringWithFormat:@"%@ just released a new album!", album.artist];
                    notification.alertTitle = [NSString stringWithFormat:@"%@ was released on %@", album.name, [dateFormatter stringFromDate:album.releaseDate]];
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    
                }
                
                if ([[[UIApplication sharedApplication]  currentUserNotificationSettings] types] & UIUserNotificationTypeAlert) {
                    // display a badge
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            }
            
            if (finished >= artistsToQuery.count) {
                if (newData) {
                    newItems = YES;
                    completionHandler(UIBackgroundFetchResultNewData);
                } else {
                    completionHandler(UIBackgroundFetchResultNoData);
                }
            }
            
        }];
    }
    
    return YES;
}

- (NSMutableArray *) popDeletedArtistQueue {
    NSMutableArray *queue = [NSMutableArray arrayWithCapacity:1];
    for (Artist *a in deletedArtists) {
        [queue addObject:a];
    }
    [deletedArtists removeAllObjects];
    return queue;
}

- (void) removeArtist:(Artist *)artist{
    if (artist == nil || allArtists == nil){
        return;
    }
    
    if (deletedArtists == nil)
        deletedArtists = [NSMutableArray arrayWithCapacity:1];
    
    [allArtists removeObject:artist];
    if ([artistQueue indexOfObject:artist] == NSNotFound) {
        [deletedArtists addObject:artist];
    } else {
        [artistQueue removeObject:artist];
    }
}

- (BOOL)login {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    if ([self loginValidate]) {
        return YES;
    }
    
    return [self login:(__bridge NSString *)uuidStringRef];
}

// Logs the app in using my account and credentials, expires in awhile
- (BOOL)login:(NSString *)UUID {
    [loginLock tryLock];
    
    if (loginLock.name == nil) {
        loginLock.name = UUID;
    } else if (![loginLock.name isEqualToString:UUID]) {
        [loginLock unlock];
        return NO;
    }
    
    if (!needsLogin) {
        [loginLock unlock];
        return NO;
    }
    
    loginTryCount++;
    NSLog(@"!!!!!%ld", (long)loginTryCount);
    
    if (loginTryCount == 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[NSString stringWithFormat:@"Unable to connect to the network."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    NSURL *loginUrl = [NSURL URLWithString:@"https://accounts.spotify.com/api/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginUrl
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:20];
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
        if (loginTryCount < 5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        }
        
        return NO;
    }
    
    NSMutableDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData
                                                                options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error parsing login response: %@",error);
        if (loginTryCount < 5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        }
        return NO;
    }
    
    SpotifyAccessToken = [data valueForKey:@"access_token"];
    expires = (long)[[NSDate date] timeIntervalSince1970];
    expires += [[data valueForKey:@"expires_in"] longValue];
    
    if (!SpotifyAccessToken) {
        NSLog(@"Error parsing login response: no token");
        if (loginTryCount < 5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        }
        return NO;
    }
    
    if (!expires) {
        NSLog(@"Error parsing login response: no expiration");
        if (loginTryCount < 5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self login:UUID];
            });
        }
        return NO;
    }
    
    SpotifySession = [[SPTSession alloc] initWithUserName:@"reptarsrage" accessToken:SpotifyAccessToken expirationTimeInterval:expires];
    
    needsLogin = NO;
    loginTryCount = 0;
    [loginLock unlock];
    return YES;
}

// gets uid for one artist
- (void)retrieveArtistInfoFromSpotify:(Artist *)artist forController:(ArtistsTableViewController *)controller {
    if (![self login]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self retrieveArtistInfoFromSpotify:artist forController:controller];
        });
        return;
    }
    
    if (allArtists == nil)
        allArtists = [NSMutableArray arrayWithCapacity:1];
    if (artistQueue == nil)
        artistQueue = [NSMutableArray arrayWithCapacity:1];
    
    NSError *error;
    NSURLRequest *req = [SPTSearch createRequestForSearchWithQuery:artist.name queryType:SPTQueryTypeArtist accessToken:SpotifyAccessToken error:&error];
    if (error != nil) {
        NSLog(@"Error creating request for artist %@: %@", artist.name, error);
        return;
    }
    
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = connectionError;
        if (error != nil) {
                NSLog(@"Error retrieving artist info for artist %@: %@", artist.name, error);
                [controller artistInfoCallback:NO artist:artist error:error];
        } else {
            NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers error:&error];
            if (error != nil) {
                NSLog(@"Error parsing response for artist %@: %@", artist.name, error);
                return;
            }
            
            if (JSONdata[@"error"] != nil) {
                if ([JSONdata[@"error"][@"status"] longValue] == 429) {
                    NSLog(@"Rate limiting applied.");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self retrieveArtistInfoFromSpotify:artist forController:controller];
                    });
                }else {
                    NSLog(@"Error retrieving artist %@: %@ %@", artist.name, JSONdata[@"error"][@"status"], JSONdata[@"error"][@"message"]);
                }
                return;
            }
            
            SPTListPage *page = [SPTListPage listPageFromDecodedJSON:JSONdata[@"artists"] expectingPartialChildren:NO rootObjectKey:nil error:&error];
            
            if ([page.items count] <= 0) {
                NSLog(@"No results found for artist %@.", artist.name);
                [controller artistInfoCallback:NO artist:artist error:[NSError errorWithDomain:@"No results found" code:404 userInfo:nil]];
            } else {
                
                SPTPartialArtist *o = [page.items firstObject];
                artist.name = o.name;
                artist.id = (NSString *)o.uri ;
                artist.href = o.sharingURL;
                artist.latestLookup = 0;
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
    if (![self login]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAllArtistInfo:artistUIds forController:controller];
        });
        return;
    }
    
    NSError *error;
    NSURLRequest *req = [SPTArtist createRequestForArtists:artistUIds withAccessToken:SpotifyAccessToken error:&error];
    if (error != nil) {
        NSLog(@"Error creating request for artists: %@", error);
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            NSLog(@"Error retrieving artist info for artists: %@", error);
            return;
        }
        
        NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers error:&error];
        if (error != nil) {
            NSLog(@"Error parsing response for artists: %@", error);
            return;
        }
        
        
        if (JSONdata[@"error"] != nil) {
            if ([JSONdata[@"error"][@"status"] longValue] == 429) {
                NSLog(@"Rate limiting applied.");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getAllArtistInfo:artistUIds forController:controller];
                });
            } else {
                NSLog(@"Error retrieving artists: %@ %@", JSONdata[@"error"][@"status"], JSONdata[@"error"][@"message"]);
            }
            return;
        }
        
        
        NSArray *results = JSONdata[@"artists"];
        
        if ([results count] != [artistUIds count]) {
            NSLog(@"Error retrieving artist info : %@", @"No results found");
            return;
        }
        
        for (NSMutableDictionary *a in results) {
            Artist *a1 = nil;
            NSUInteger index;
            index = [allArtists indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([[(Artist *)obj name] isEqualToString:a[@"name"]]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (index != NSNotFound && a[@"uri"] != nil) {
                a1 = [allArtists objectAtIndex:index];
                a1.image_url_large = [NSURL URLWithString:a[@"images"][0][@"url"]];
                a1.image_url_small = [NSURL URLWithString:a[@"images"][2][@"url"]];
                a1.image_url_med = [NSURL URLWithString:a[@"images"][1][@"url"]];
                a1.popularity = [a[@"popularity"] doubleValue];
                a1.followers = [a[@"followers"][@"total"] longValue];
                a1.image_aspect_ratio = [a[@"images"][0][@"width"] doubleValue] / [a[@"images"][0][@"height"] doubleValue];
                
                //update in table
                [controller artistInfoCallback:YES artist:a1 error:nil];
                
            } else {
                NSLog(@"Error updating artist info for %@: %@", a[@"name"], @"Artist not found in table");
            }
        }
    }];
}


-(void)getAllAlbumsForArtist:(NSString *)uid pageURL:(NSURLRequest *)nextPage withAlbumUris:(NSMutableArray *)uris withCallback:(SpotifyAlbumInfoCallback)callback {
    if (![self login]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris withCallback:callback];
        });
        return;
    }
    
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
    
    if (error != nil) {
        NSLog(@"Error creating request for albums: %@", error);
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) { // TIMEOUT
                [self getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris withCallback:callback];
            } else {
                NSLog(@"Error retrieving album info for artist with id %@: %@", uid, error);
            }
            return;
        }
        
        NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing albums data for artist with id %@: %@", uid, error);
            return;
        }
        
        if (JSONdata[@"error"] != nil) {
            if ([JSONdata[@"error"][@"status"] longValue] == 429) {
                NSLog(@"Rate limiting applied.");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris withCallback:callback];
                });
            } else {
                NSLog(@"Error retrieving album info for artist with id %@: %@ %@", uid, JSONdata[@"error"][@"status"], JSONdata[@"error"][@"message"]);
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
            
            if (error == nil || error == NULL) {
                [self getAllAlbumsForArtist:uid pageURL:nextRequest withAlbumUris:uris withCallback:callback];
            } else {
                NSLog(@"Error retrieving the next page. Failed to create request: %@", error);
            }
        } else {
            if ([uris count] != page.totalListLength) {
                NSLog(@"Error retrieving albums. %lu albums parsed does not equal %luld total albums in list.", (unsigned long)[uris count], (unsigned long)page.totalListLength);
                [self  getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris withCallback:callback];
            }
            [self getDetailedAlbumInfo:uris withPage:nil withCallback:callback];
        }
    }];
}


-(void)getDetailedAlbumInfo:(NSMutableArray *)uris withPage:(NSURLRequest *)nextPage withCallback:(SpotifyAlbumInfoCallback)callback {
    if (![self login]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDetailedAlbumInfo:uris withPage:nextPage withCallback:callback];
        });
        return;
    }
    
    if (uris.count == 0) {
        return;
    }
    
    if (uris.count > 20) {
        NSMutableArray *uris1 = [NSMutableArray arrayWithArray:[uris subarrayWithRange:NSMakeRange(0, 20)]];
        NSMutableArray *uris2 = [NSMutableArray arrayWithArray:[uris subarrayWithRange:NSMakeRange(20, uris.count - 20)]];
        [self getDetailedAlbumInfo:uris1 withPage:nextPage withCallback:callback];
        [self getDetailedAlbumInfo:uris2 withPage:nextPage withCallback:callback];
        return;
    }
    
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
                [self getDetailedAlbumInfo:uris withPage:nextPage withCallback:callback];
            } else {
                NSLog(@"Error retrieving detailed album info for multiple albums: %@", error);
                callback (nil, error);
            }
            
            return;
        }

        NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers error:&error];
   
        if (error != nil) {
            NSLog(@"Error parsing JSON data for albums.");
            callback (nil, error);
            return;
        }
        
        if (JSONdata[@"error"] != nil) {
            if ([JSONdata[@"error"][@"status"] longValue] == 429) {
                NSLog(@"Rate limiting applied.");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getDetailedAlbumInfo:uris withPage:nextPage withCallback:callback];
                });
            } else {
                NSLog(@"Error retrieving album info for albums (%lu): %@ %@", (unsigned long)uris.count,JSONdata[@"error"][@"status"] , JSONdata[@"error"][@"message"]);
            }
            return;
        }
        
        NSArray *albums = [SPTAlbum albumsFromDecodedJSON:JSONdata error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing detailed album data for multiple albums: %@", error);
            callback (nil, error);
            return;
        }
        
        for (SPTAlbum *album in albums) {
            Album *a = [[Album alloc] init];
            a.name = album.name;
            a.id = [album.uri absoluteString];
            a.releaseDate = album.releaseDate;
            //a.sectionNumber = [controller getAlbumSection:a.releaseDate];
            a.artist = [(SPTArtist *)[album.artists firstObject] name];
            a.image_url_large = album.largestCover.imageURL;
            a.image_url_small = album.smallestCover.imageURL;
            a.image_url_med = nil;
            a.href = album.sharingURL;
            a.popularity = album.popularity;
            a.image_aspect_ratio = album.largestCover.size.width / album.largestCover.size.height;
            
            if (a.releaseDate == nil) {
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                [components setYear:album.releaseYear];
                [components setMonth:1];
                [components setDay:1];
                a.releaseDate = [calendar dateFromComponents:components];
            }
            
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
            
            if (album.firstTrackPage.nextPageURL != nil) {
                a.nextTrackPageUrl = [(SPTListPage *)album.firstTrackPage createRequestForNextPageWithAccessToken:SpotifyAccessToken error:&error];
                if (error != nil) {
                    NSLog(@"Error creating request for next page of tacks for album %@: %@", a.name, error);
                    a.nextTrackPageUrl = nil;
                }
            } else {
                a.nextTrackPageUrl = nil;
            }
            
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
                ((Artist *)[allArtists objectAtIndex:index]).latestLookup = [[NSDate date] timeIntervalSince1970];
                
                // check if duplicate
                NSUInteger aindex;
                
                if (((Artist *)[allArtists objectAtIndex:index]).albums == nil) {
                    aindex = NSNotFound;
                } else {
                    aindex = [((Artist *)[allArtists objectAtIndex:index]).albums  indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                        if ([((Album *)obj).name isEqualToString:a.name]) { // don't compare ids, you will get duplicates
                            *stop = YES;
                            return YES;
                        }
                        return NO;
                    }];
                }
                
                if (aindex != NSNotFound) {
                    callback (nil, nil);
                    return; // already in ablums
                }
                
                // not a duplicate, so add it
                [[allArtists objectAtIndex:index] addToAlbums:a];
            }
            
            
            // AFTER adding to artist (not before)
            callback (a, nil);
        }
    }];
}

-(void)getAllTracksForAlbum:(Album *)album withCallback:(SpotifyAlbumInfoCallback)callback {
    if (![self login]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAllTracksForAlbum:album withCallback:callback];
        });
        return;
    }
    
    NSURLRequest *req;
    
    if (album.nextTrackPageUrl != nil) {
        req = album.nextTrackPageUrl;
    } else {
        return;
    }
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) {
                [self getAllTracksForAlbum:album withCallback:callback];
            } else {
                NSLog(@"Error retrieving tack info for album %@: %@", album.name, error);
            }
            return;
        }
        
        NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON data for tracks: %@", error);
            callback (nil, error);
            return;
        }
        
        if (JSONdata[@"error"] != nil) {
            if ([JSONdata[@"error"][@"status"] longValue] == 429) {
                NSLog(@"Rate limiting applied.");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getAllTracksForAlbum:album withCallback:callback];
                });
            } else {
                NSLog(@"Error retrieving track info for album: %@ %@", JSONdata[@"error"][@"status"], JSONdata[@"error"][@"message"]);
            }
            return;
        }
        
        SPTListPage *page = [SPTListPage listPageFromData:data withResponse:response expectingPartialChildren:NO rootObjectKey:nil error:&error];
        
        
        if (error != nil) {
            NSLog(@"Error parsing track data for album %@: %@", album.name, error);
            return;
        }
        
        for (SPTTrack *track in page.items) {
            Track *t = [album.tracks objectAtIndex:track.trackNumber - 1];
            t.id = (NSString *)track.uri;
            t.discNumber = track.discNumber;
            t.href = track.sharingURL;
            t.preview = track.previewURL;
            t.duration = track.duration;
            t.flaggedExplicit = track.flaggedExplicit;
            t.name = track.name;
        }
            
        if (page.nextPageURL != nil) {
            album.nextTrackPageUrl = [page createRequestForNextPageWithAccessToken:SpotifyAccessToken error:&error];
            
            if (error == nil){
                [self getAllTracksForAlbum:album withCallback:callback];
            } else {
                NSLog(@"Error creating request for tracks for album %@: %@", album.name, error);
            }
        } else {
            album.nextTrackPageUrl = nil;
        }
        
        // AFTER adding to artist (not before)
        callback (album, nil);
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
        needsLogin = YES;
        loginTryCount = 0;
        loginLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
