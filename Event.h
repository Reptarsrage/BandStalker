//
//  Event.h
//  BandStalker
//
//  Created by Admin on 8/6/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *venue;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *ticketStatus;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) NSDate *ticketsOnSaleTime;
@property (nonatomic, retain) NSURL *ticketURL;
@property (nonatomic, retain) NSURL *venueURL;
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain)NSData *cached_image;

@property NSInteger sectionNumber;

@end
