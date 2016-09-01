//
//  bandsInTownManager.m
//  BandStalker
//
//  Created by Admin on 8/6/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "bandsInTownManager.h"

@implementation bandsInTownManager

@synthesize app_id;
@synthesize artistQueue;
@synthesize newItems;
@synthesize deletedArtistQueue;

- (NSMutableArray *) popDeletedArtistQueue {
    NSMutableArray *queue = [NSMutableArray arrayWithCapacity:1];
    for (Artist *a in deletedArtistQueue) {
        [queue addObject:a];
    }
    [deletedArtistQueue removeAllObjects];
    return queue;
}

- (void) removeArtist:(Artist *)artist{
    if (artist == nil ){
        return;
    }
    
    if (deletedArtistQueue == nil)
        deletedArtistQueue = [NSMutableArray arrayWithCapacity:1];
    
    if ([artistQueue indexOfObject:artist] == NSNotFound) {
        [deletedArtistQueue addObject:artist];
    } else {
        [artistQueue removeObject:artist];
    }
}

- (void) getUpcomingEventForArtist:(Artist *)artist withCallback:(BandsInTownEventInfoCallback)callback{
    NSString *name = [artist.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.bandsintown.com/artists/%@/events/search.json?api_version=2.0&location=%@&radius=%@&page=%@&per_page=%@&app_id=%@",name, @"Seattle,WA", @"50", @"1", @"50", app_id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // make synchronous request
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving artist concerts from bandsintown: %@",error);
            return;
        }
        
        NSMutableDictionary *JSONdata = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"Error parsing response from bandsintown: %@",error);
            return;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        for (NSMutableDictionary *eventJSON in JSONdata) {
            Event *event = [[Event alloc]  init];
            event.imageURL = artist.image_url_med;
            event.artist = artist.name;
            event.city = eventJSON[@"venue"][@"city"];
            event.region = eventJSON[@"venue"][@"region"];
            event.venue = eventJSON[@"venue"][@"name"];
            event.venueURL = eventJSON[@"venue"][@"url"];
            event.country = eventJSON[@"venue"][@"country"];
            event.ticketStatus= eventJSON[@"ticket_status"];
            event.ticketURL = eventJSON[@"ticket_url"];
            if (eventJSON[@"on_sale_datetime"] != (id)[NSNull null] && ((NSString *)eventJSON[@"on_sale_datetime"]).length > 0) {
                event.ticketsOnSaleTime = [dateFormatter dateFromString:eventJSON[@"on_sale_datetime"]];
            }
            if (eventJSON[@"datetime"] != (id)[NSNull null] && ((NSString *)eventJSON[@"datetime"]).length > 0) {
                event.time = [dateFormatter dateFromString:eventJSON[@"datetime"]];
            }
            [artist addToEvents:event];
            callback (event, nil);
            newItems = YES;
            NSLog(@"Event returned.");
        }
    }];
}


#pragma mark Singleton Methods

+ (id)sharedManager {
    static bandsInTownManager *sharedMyManager = nil;
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
        app_id = @"bandStalker";
        artistQueue = [NSMutableArray array];
        newItems = NO;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
