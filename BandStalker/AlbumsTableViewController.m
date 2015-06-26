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

@interface AlbumsTableViewController ()
@property NSMutableArray *albums;
@end

@implementation AlbumsTableViewController


-(void)getDetailedAlbumInfo:(NSMutableArray *)uris withPage:(NSURLRequest *)nextPage {
    NSError *error;
    NSURLRequest *req;
    
    if (nextPage == nil) {
        req = [SPTAlbum createRequestForAlbums:uris withAccessToken:SpotifyAccessToken market:nil error:&error];
    } else {
        req = nextPage;
    }
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) {
                [self getDetailedAlbumInfo:uris withPage:nextPage];
            } else {
                NSLog(@"Error retrieving detailed album info for multiple albums: %@", error);
            }
            
            return;
        }
        
        //SPTListPage *page = [SPTListPage  listPageFromData:data withResponse:response expectingPartialChildren:NO rootObjectKey:nil error:&error];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error != nil) {
                NSLog(@"Error parsing JSON data for albums.");
                return;
            }
            NSArray *albums = [SPTAlbum albumsFromDecodedJSON:json error:&error];
            
            
            
        if (error != nil) {
            NSLog(@"Error parsing detailed album data for multiple albums: %@", error);
            return;
        }
        
        for (SPTAlbum *album in albums) {
            Album *a = [[Album alloc] init];
            a.name = album.name;
            a.id = (NSString *)album.uri;
            a.releaseDate = album.releaseDate;
            a.sectionNumber = [self getAlbumSection:a.releaseDate];
            a.artist = [(SPTArtist *)[album.artists firstObject] name];
            a.image_url_large = album.largestCover.imageURL;
            a.image_url_small = album.smallestCover.imageURL;
            a.image_url_med = nil;
            a.href = album.sharingURL;
            
            //remove object if it exists in the unclassified section
            /*for (Album *aOld in [self.albums objectAtIndex:[self getAlbumSection:nil]]) {
                if ([aOld.id isEqualToString:a.id]) {
                    [[self.albums objectAtIndex:[self getAlbumSection:nil]] removeObject:aOld];
                    break;
                }
            }*/
            
            // find correct place and add object
            if (a.sectionNumber < 0) {
                continue;
            }
            
            NSUInteger index = [[self.albums objectAtIndex:a.sectionNumber] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([[(Album *)obj name] caseInsensitiveCompare:a.name] == NSOrderedDescending) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (index == NSNotFound) {
                [[self.albums objectAtIndex:a.sectionNumber] addObject:a];
            } else {
                [[self.albums objectAtIndex:a.sectionNumber] insertObject:a atIndex:index];
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:a.sectionNumber] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        /*if (page.nextPageURL != nil) {
            NSURLRequest *nextRequest = [page createRequestForNextPageWithAccessToken:SpotifyAccessToken error:&error];
            
            if (error != nil) {
                [self getDetailedAlbumInfo:uris withPage:nextRequest];
            } else {
                NSLog(@"Error retrieving the next page. Failed to create request: %@", error);
            }
        }*/
        
    }];
}

-(void)getAllAlbumsForArtist:(NSString *)uid pageURL:(NSURLRequest *)nextPage withAlbumUris:(NSMutableArray *)uris{
    NSError *error;
    NSURLRequest *req ;
    if (nextPage == nil) {
        req = [SPTArtist createRequestForAlbumsByArtist:(NSURL *)uid ofType:SPTAlbumTypeAlbum|SPTAlbumTypeSingle withAccessToken:SpotifyAccessToken market:nil error:&error];
    } else {
        req = nextPage;
    }
    
    if (uris == nil) {
        uris = [NSMutableArray arrayWithCapacity:1];
    }
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error != nil) {
            if ([error code] == 1001) {
                [self getAllAlbumsForArtist:uid pageURL:nextPage withAlbumUris:uris];
            } else {
                NSLog(@"Error retrieving album info for artist with id %@: %@", uid, error);
            }
            
            return;
        }
        
        SPTListPage *page = [SPTListPage  listPageFromData:data withResponse:response expectingPartialChildren:NO rootObjectKey:nil error:&error];
        
            if (error != nil) {
                NSLog(@"Error parsing albums data for artist with id %@: %@", uid, error);
                return;
            }
        
            for (SPTAlbum *album in page.items) {
                [uris addObject:(NSString *)album.uri];

            }
            
        if (page.nextPageURL != nil) {
            NSURLRequest *nextRequest = [page createRequestForNextPageWithAccessToken:SpotifyAccessToken error:&error];

            if (error != nil) {
                [self getAllAlbumsForArtist:uid pageURL:nextRequest withAlbumUris:uris];
            } else {
                NSLog(@"Error retrieving the next page. Failed to create request: %@", error);
            }
        } else {
            if ([uris count] != page.totalListLength) {
                NSLog(@"Error retrieving albums. %lu albums parsed does not equal %luld total albums in list.", (unsigned long)[uris count], page.totalListLength);
            }
            [self getDetailedAlbumInfo:uris withPage:nil];
        }
    }];
}

- (NSMutableArray *)getAlbums {
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    Album *a1 = [[Album alloc] init];
    a1.name = @"The Moon and Anarctica";
    [albums addObject:a1];
    
    Album *a2 = [[Album alloc] init];
    a2.name = @"Best of Beck";
    [albums addObject:a2];
    
    Album *a3 = [[Album alloc] init];
    a3.name = @"Asylum";
    [albums addObject:a3];
    
    for (MPMediaItemCollection *collection in [[MPMediaQuery albumsQuery] collections]) {
        a1 = [[Album alloc] init];
        a1.name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
        //MPMediaItemPropertyReleaseDate
        [albums addObject:a1];
    }
    
    for (NSString *uid in artistIDs) {
        [self getAllAlbumsForArtist:uid pageURL:nil withAlbumUris:nil];
    }
    [artistIDs removeAllObjects];
    
    return albums;
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
        return 6; // default before info from Spotify arrives
    
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
        return -1;
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
    
    for (NSString *uid in artistIDs) {
        [self getAllAlbumsForArtist:uid pageURL:nil withAlbumUris:nil];
    }
    [artistIDs removeAllObjects];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    }
    // (4)
    self.albums = [NSMutableArray arrayWithCapacity:1];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSMutableArray *sortedSection = [NSMutableArray arrayWithArray:[col sortedArrayFromArray:sectionArray
                                                                         collationStringSelector:@selector(name)]];
        [self.albums addObject:sortedSection];
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
    if ([[self.albums objectAtIndex:section] count] > 0) {
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
    return [self.albums count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.albums objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    customTableViewCell *oCell = (customTableViewCell *)cell;
    Album *a = [[self.albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (a.id == nil || a.image_url_small == nil) {
        oCell.titleLabel.text = a.name;
        oCell.subTitleLabel.text = @"Error retrieving data";
        oCell.subTitleLabel2.text = @"";
        oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
        
        
    } else {
        oCell.titleLabel.text = a.name;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:a.image_url_large] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            oCell.thumbImageView.image = [UIImage imageWithData:data];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[self.albums objectAtIndex:section] count] > 0) {
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
    if ([[self.albums objectAtIndex:section] count] > 0) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
