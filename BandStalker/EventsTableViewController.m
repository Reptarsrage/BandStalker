//
//  eventsTableViewController.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

@import MediaPlayer;

#import "AppDelegate.h"
#import "customTableViewCell.h"
#import "EventsTableViewController.h"
#import "bandsInTownManager.h"

@interface EventsTableViewController () {
@private
    bandsInTownManager *sharedBandsManager;
    UIView *errorLabel;
    NSInteger eventCount;
    NSMutableArray *events;
}

@end
@implementation EventsTableViewController

- (void) showEmptyTableLabel {
    // show message if empty
    if (events == nil || eventCount == 0) {
        //errorLabel.hidden = NO;
        self.tableView.backgroundView = errorLabel;
    } else {
        //    errorLabel.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}

- (void) eventInfoCallback:(Event *)event error:(NSError *)error {
    if (error == nil && event != nil) {
        // find correct place and add object
        event.sectionNumber = [self getEventSection:event.time];
        
        if (event.sectionNumber < 0) {
            return;
        }
        
        NSUInteger index = [[events objectAtIndex:event.sectionNumber] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(Event *)obj time] compare:event.time] == NSOrderedAscending) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound) {
            [[events objectAtIndex:event.sectionNumber] addObject:event];
            eventCount++;
        } else {
            [[events objectAtIndex:event.sectionNumber] insertObject:event atIndex:index];
            eventCount++;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:event.sectionNumber] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        // failure
    }
    
    [self showEmptyTableLabel];
}


-(NSInteger) getEventSection:(NSDate *)time {
    /*
     0: Today
     1: This Week
     2: This Month
     3: Upcoming 6 Months
     4. Upcoming Year
     5: Upcoming Decade
     6: Unknown
     */
    
    if (time == nil)
        return 7; // default before info from BandsInTown arrives
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:time];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *diff = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                         fromDate:today
                                           toDate:otherDate
                                          options:0];
    
    if(diff.year > 10) {
        //ignore
        return 6;
    } else if (diff.year > 0) {
        return 5;
    }else if (diff.month > 6) {
        return 4;
    }else if (diff.month > 0) {
        return 3;
    }else if (diff.day > 7) {
        return 2;
    }else if (diff.day > 0) {
        return 1;
    }else {
        return 0;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (sharedBandsManager.newItems == NO) {
        // Delay execution of my block for 3 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UITabBarController *tbc = self.tabBarController;
            UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:2];
            [tbi setBadgeValue:nil];
        });
    } else {
        sharedBandsManager.newItems = NO;
    }
    
    while ([sharedBandsManager.artistQueue count] > 0) {
        Artist *artist = [sharedBandsManager.artistQueue lastObject];
        [sharedBandsManager.artistQueue removeLastObject];
        if (artist && ![artist.name isEqualToString:@""]) {
            //no lookup required, events have already been fetched
            if (artist.events != nil && [artist.events count] > 0) {
                for (Event *event in artist.events) {
                    [self eventInfoCallback:event error:nil];
                }
            } else {
                // need lookup
                [sharedBandsManager getUpcomingEventForArtist:artist withCallback:^(Event *event, NSError *error) {
                    [self eventInfoCallback:event error:error];
                }];
            }
        }
    }
    
    for (Artist *artist in [sharedBandsManager popDeletedArtistQueue]) {
        for (Event *event in artist.events) {
            NSInteger sect = [self getEventSection:event.time];
            if (sect >= 0 && [[events  objectAtIndex:sect] indexOfObject:event] != NSNotFound) {
                [[events objectAtIndex:sect] removeObject:event];
                eventCount--;
            }
        }
    }
    [self.tableView reloadData];
    [self showEmptyTableLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // get the common empty table error message
    errorLabel = [CommonController getErrorLabel:self.tableView.frame withTitle:@"No events" withMsg:@"There are no events found for the current artists"];
    
    sharedBandsManager = [bandsInTownManager sharedManager];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    //self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.rowHeight = 80.0f;
    
    NSMutableArray *eventsTemp = [NSMutableArray array];
    
    UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
    for (Event *a in eventsTemp) {
        NSInteger sect = [self getEventSection:a.time];
        a.sectionNumber = sect;
    }
    
    // (2)
    NSInteger highSection = [[col sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    // (3)
    for (Event *a in eventsTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:a.sectionNumber] addObject:a];
        eventCount++;
    }
    // (4)
    events = [NSMutableArray arrayWithCapacity:1];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSMutableArray *sortedSection = [NSMutableArray arrayWithArray:[col sortedArrayFromArray:sectionArray
                                                                         collationStringSelector:@selector(name)]];
        [events addObject:sortedSection];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 if ([[events objectAtIndex:section] count] > 0) {
 return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
 }
 return nil;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
 {
 return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
 } */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[events objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    customTableViewCell *oCell = (customTableViewCell *)cell;
    Event *a = [[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (a.venue == nil || a.time == nil) {
        oCell.titleLabel.text = [NSString stringWithFormat:@"%@ At An Unknown Venue", a.artist];
        oCell.subTitleLabel.text = @"Error retrieving data";
        oCell.subTitleLabel2.text = @"";
        oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
        
        
    } else {
        oCell.titleLabel.text = [NSString stringWithFormat:@"%@ At %@", a.artist, a.venue];
        oCell.albumTag = [NSString stringWithFormat:@"%@, %@", a.city, a.region];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:a.imageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                a.cached_image = data;
                oCell.thumbImageView.image = [UIImage imageWithData:data];
            } else {
                NSLog(@"Error retrieving event art for event %@ %@: %@", a.artist ,a.venue, connectionError);
                oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
            }
        }];
        oCell.subTitleLabel.text = [NSString stringWithFormat:@"Tickets: %.@", a.ticketStatus];
        
        
        // Date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        oCell.subTitleLabel2.text = [NSString stringWithFormat:@"Date: %@", [dateFormatter stringFromDate:a.time]];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //Album *a = [[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //[self performSegueWithIdentifier:@"AlbumDrilldownSegue" sender:a];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[events objectAtIndex:section] count] > 0) {
        UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        customTitleView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
        
        switch (section) {
            case 0:
                titleLabel.text = @"Today";
                break;
            case 1:
                titleLabel.text = @"Upcoming Week";
                break;
            case 2:
                titleLabel.text = @"Upcoming Month";
                break;
            case 3:
                titleLabel.text = @"Upcoming 6 Months";
                break;
            case 4:
                titleLabel.text = @"Upcoming Year";
                break;
            case 5:
                titleLabel.text = @"Upcoming Decade";
                break;
            case 6:
                titleLabel.text = @"Upcoming Century";
                break;
            default:
                titleLabel.text = @"Sometime";
                break;
        }
        
        titleLabel.textColor = [UIColor grayColor];
        
        titleLabel.backgroundColor = [UIColor whiteColor];
        
        [customTitleView addSubview:titleLabel];
        
        
        return customTitleView;
    } else {
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[events objectAtIndex:section] count] > 0) {
        return 30;
    } else {
        return 0;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*if ([segue.identifier isEqualToString:@"AlbumDrilldownSegue"]) {
        Album *a = (Album *)sender;
        UINavigationController *navController = [segue destinationViewController];
        AlbumDrilldownTableViewController *SITViewController = (AlbumDrilldownTableViewController *)([navController viewControllers][0]);
        SITViewController.album = a;
    }*/
}

@end
