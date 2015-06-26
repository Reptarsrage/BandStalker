//
//  ArtistsTableViewController.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"
#import "Album.h"
#import "AddArtistViewController.h"

@interface ArtistsTableViewController : UITableViewController

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

- (void) addAlbum:(Album *)album toArtist:(NSString *)artistName;

- (void) artistInfoCallback:(BOOL)success artist:(Artist *)artist error:(NSError *)error;

@end
