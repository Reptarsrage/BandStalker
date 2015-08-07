//
//  EventsTableViewController.h
//  BandStalker
//
//  Created by Admin on 8/6/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"


@interface EventsTableViewController : UITableViewController

- (void) eventInfoCallback:(Event *)event error:(NSError *)error;

@end
