//
//  Album.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject {
    
}

@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *id;
@property (nonatomic, retain)NSDate *releaseDate;
@property (nonatomic, retain)NSString *image_url_small;
@property (nonatomic, retain)NSString *image_url_med;
@property (nonatomic, retain)NSString *image_url_large;
@property (nonatomic, retain)NSString *href;
@property (nonatomic, retain)NSString *artist;


@end
