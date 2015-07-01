//
//  AlbumDrilldownTableViewController.h
//  BandStalker
//
//  Created by Admin on 7/1/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "SpotifyManager.h"

@interface AlbumDrilldownTableViewController : UITableViewController
@property (nonatomic, strong) Album *album;
- (void) albumInfoCallback:(Album *)album error:(NSError *)error;
@end
