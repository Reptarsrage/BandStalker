//
//  AlbumsTableViewController.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumsTableViewController : UITableViewController

- (void) albumInfoCallback:(Album *)album error:(NSError *)error;

@end
