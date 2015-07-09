//
//  AlbumsTableViewController.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

@import MediaPlayer;

#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "customTableViewCell.h"
#import "ArtistsTableViewController.h"
#import "AlbumsTableViewController.h"
#import "AlbumDrilldownTableViewController.h"

@interface AlbumsTableViewController () {
@private
    SpotifyManager *sharedManager;
    UIView *errorLabel;
    NSInteger albumCount;
    NSMutableArray *albums;
}

@end
@implementation AlbumsTableViewController

- (void) showEmptyTableLabel {
    // show message if empty
    if (albums == nil || albumCount == 0) {
        //errorLabel.hidden = NO;
        self.tableView.backgroundView = errorLabel;
    } else {
        //    errorLabel.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}

- (void) albumInfoCallback:(Album *)album error:(NSError *)error {
    if (error == nil && album != nil) {
        // find correct place and add object
        album.sectionNumber = [self getAlbumSection:album.releaseDate];
        
        if (album.sectionNumber < 0) {
            return;
        }
        
        NSUInteger index = [[albums objectAtIndex:album.sectionNumber] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(Album *)obj releaseDate] compare:album.releaseDate] == NSOrderedAscending) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound) {
            [[albums objectAtIndex:album.sectionNumber] addObject:album];
            albumCount++;
        } else {
            [[albums objectAtIndex:album.sectionNumber] insertObject:album atIndex:index];
            albumCount++;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:album.sectionNumber] withRowAnimation:UITableViewRowAnimationNone];
        
        [sharedManager getAllTracksForAlbum:album withCallback:^(Album *album, NSError *error) {
            [self albumInfoCallback:album error:error];
        }];
        
    } else {
        // failure
    }
    
    [self showEmptyTableLabel];
}

- (NSMutableArray *)getAlbums {
    NSMutableArray *retAlbums = [[NSMutableArray alloc] init];
    
    
    for (MPMediaItemCollection *collection in [[MPMediaQuery albumsQuery] collections]) {
        Album *a1 = [[Album alloc] init];
        a1.name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
        a1.artist = [[collection representativeItem] valueForProperty:MPMediaItemPropertyAlbumArtist];
        //MPMediaItemPropertyReleaseDate
        //[retAlbums addObject:a1];
    }
    
    return retAlbums;
}


-(NSInteger) getAlbumSection:(NSDate *)releaseDate {
    /*
     0: Today
     1: This Week
     2: This Month
     3: Past 6 Months
     4. This Year
     5: This Decade
     6: Unknown
     */
    
    if (releaseDate == nil)
        return 7; // default before info from Spotify arrives
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:releaseDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *diff = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                         fromDate:otherDate
                                                 toDate:today
                                                options:0];
    
    if(diff.year > 10) {
        //ignore
        return 6;
    } else if (diff.year > 1) {
        return 5;
    }else if (diff.month > 6) {
        return 4;
    }else if (diff.month > 1) {
        return 3;
    }else if (diff.day > 7) {
        return 2;
    }else if (diff.day > 1) {
        return 1;
    }else {
        return 0;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (sharedManager.newItems == NO) {
        // Delay execution of my block for 3 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UITabBarController *tbc = self.tabBarController;
            UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:1];
            [tbi setBadgeValue:nil];
        });
    } else {
        sharedManager.newItems = NO;
    }
    
    while ([sharedManager.artistQueue count] > 0) {
        Artist *artist = [sharedManager.artistQueue lastObject];
        [sharedManager.artistQueue removeLastObject];
        if (artist && ![artist.name isEqualToString:@""])
            //no lookup required, albums have already been fetched
            if (artist.albums != nil && [artist.albums count] > 0) {
                for (Album *album in artist.albums) {
                    [self albumInfoCallback:album error:nil];
                }
            } else {
                // need lookup
                [sharedManager getAllAlbumsForArtist:artist.id pageURL:nil withAlbumUris:nil withCallback:^(Album *album, NSError *error) {
                    [self albumInfoCallback:album error:error];
                }];
            }
    }
    
    for (Artist *artist in [sharedManager popDeletedArtistQueue]) {
        for (Album *album in artist.albums) {
            NSInteger sect = [self getAlbumSection:album.releaseDate];
            if (sect >= 0 && [[albums  objectAtIndex:sect] indexOfObject:album] != NSNotFound) {
                [[albums objectAtIndex:sect] removeObject:album];
                albumCount--;
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
    errorLabel = [CommonController getErrorLabel:self.tableView.frame withTitle:@"No Albums" withMsg:@"There are no albums found for the current artists"];
    
    sharedManager = [SpotifyManager sharedManager];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.rowHeight = 80.0f;
    
    NSMutableArray *albumsTemp = [self getAlbums];
    //NSInteger count = [albumsTemp count];
    
    
    UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
    for (Album *a in albumsTemp) {
        NSInteger sect = [self getAlbumSection:a.releaseDate];
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
    for (Album *a in albumsTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:a.sectionNumber] addObject:a];
        albumCount++;
    }
    // (4)
    albums = [NSMutableArray arrayWithCapacity:1];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSMutableArray *sortedSection = [NSMutableArray arrayWithArray:[col sortedArrayFromArray:sectionArray
                                                                         collationStringSelector:@selector(name)]];
        [albums addObject:sortedSection];
    }
    
    // start retrieving data for albums
    //[self loadInitialData];
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
    if ([[albums objectAtIndex:section] count] > 0) {
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
    return [albums count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[albums objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    customTableViewCell *oCell = (customTableViewCell *)cell;
    Album *a = [[albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (a.id == nil || a.image_url_small == nil) {
        oCell.titleLabel.text = [NSString stringWithFormat:@"%@ [Unkonwn type]", a.name];
        oCell.subTitleLabel.text = @"Error retrieving data";
        oCell.subTitleLabel2.text = @"";
        oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
        
        
    } else {
        oCell.titleLabel.text = [NSString stringWithFormat:@"%@ [%@]", a.name, a.type];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:a.image_url_large] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                a.cached_image = data;
                oCell.thumbImageView.image = [UIImage imageWithData:data];
            } else {
                NSLog(@"Error retrieving album art for album %@: %@", a.name, connectionError);
                oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
            }
        }];
    
        oCell.subTitleLabel.text = [NSString stringWithFormat:@"Artist: %.@", a.artist];
        
        
        // Date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        oCell.subTitleLabel2.text = [NSString stringWithFormat:@"Release Date: %@", [dateFormatter stringFromDate:a.releaseDate]];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Album *a = [[albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"AlbumDrilldownSegue" sender:a];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[albums objectAtIndex:section] count] > 0) {
        UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        customTitleView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
        
        switch (section) {
            case 0:
                titleLabel.text = @"Today";
                break;
            case 1:
                titleLabel.text = @"This Week";
                break;
            case 2:
                titleLabel.text = @"This Month";
                break;
            case 3:
                titleLabel.text = @"Past 6 Months";
                break;
            case 4:
                titleLabel.text = @"This Year";
                break;
            case 5:
                titleLabel.text = @"This Decade";
                break;
            case 6:
                titleLabel.text = @"This Century";
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
    if ([[albums objectAtIndex:section] count] > 0) {
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
    if ([segue.identifier isEqualToString:@"AlbumDrilldownSegue"]) {
        Album *a = (Album *)sender;
        UINavigationController *navController = [segue destinationViewController];
        AlbumDrilldownTableViewController *SITViewController = (AlbumDrilldownTableViewController *)([navController viewControllers][0]);
        SITViewController.album = a;
    }
}

@end
