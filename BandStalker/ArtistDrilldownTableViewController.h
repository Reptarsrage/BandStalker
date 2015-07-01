//
//  ArtistDrilldownTableViewController.h
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"
#import "TrackTableViewCell.h"

@interface ArtistDrilldownTableViewController : UITableViewController
@property (nonatomic, strong) Artist *artist;
- (void) albumInfoCallback:(Album *)album error:(NSError *)error;
@end
