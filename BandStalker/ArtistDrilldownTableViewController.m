//
//  ArtistDrilldownTableViewController.m
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ArtistDrilldownTableViewController.h"
#import "TrackTableViewCell.h"
#import "SpotifyManager.h"

@interface ArtistDrilldownTableViewController () {
    __weak IBOutlet UINavigationItem *nav;
    @private
    SpotifyManager *sharedManager;
}

@end



@implementation ArtistDrilldownTableViewController

- (void) albumInfoCallback:(Album *)album error:(NSError *)error {
    if (error == nil && album != nil) {
        sharedManager.newItems = NO;
        UITabBarController *tbc = self.tabBarController;
        UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:1];
        [tbi setBadgeValue:@"New"];
        
        [self.tableView reloadData];
        [sharedManager getAllTracksForAlbum:album withCallback:^(Album *album, NSError *error) {
            [self albumInfoCallback:album error:error];
        }];
    } else {
        // failure
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create header using artist info
    CGFloat w = self.tableView.frame.size.width;
    //CGFloat h = self.tableView.frame.size.height;
    sharedManager = [SpotifyManager sharedManager];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, (w/2.0f) + 20.0f)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, w/2.0f - 20, w/2.0f  - 20)];
    [headerView addSubview:imageView];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(w/2.0f, 10, w/2.0f - 10, headerView.frame.size.height / 4.0f)];
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    
    
    // add all info
    imageView.image = [UIImage imageWithData:self.artist.cached_image];
    labelView.text = self.artist.name;
    
    if (self.artist.albums == nil || [self.artist.albums count] == 0)
        [sharedManager getAllAlbumsForArtist:self.artist.id pageURL:nil withAlbumUris:nil  withCallback:^(Album *album, NSError *error) {
            [self albumInfoCallback:album error:error];
        }];
    nav.title = self.artist.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.artist.albums count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self.artist.albums objectAtIndex:section] tracks] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TrackTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    TrackTableViewCell *oCell = (TrackTableViewCell *)cell;
    Track *a = [[[self.artist.albums objectAtIndex:indexPath.section] tracks] objectAtIndex:indexPath.row];
    if (a == nil || a.name == nil) {
        oCell.trackName.text = @"Unkown track";
        oCell.trackLength.text = [NSString stringWithFormat:@"0:00"];
        oCell.trackNumber.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    } else {
        
        
        if (a.name.length > 30) {
            oCell.trackName.text = [NSString stringWithFormat:@"%@...", [a.name substringToIndex:30]];
        } else {
            oCell.trackName.text = a.name;
        }
        
        oCell.trackNumber.text = [NSString stringWithFormat:@"%ld", (long)a.trackNumber ];
        
        NSInteger ti = (NSInteger)a.duration;
        NSInteger seconds = ti % 60;
        NSInteger minutes = (ti / 60) % 60;
        NSInteger hours = (ti / 3600);
        
        if (hours > 0) {
            oCell.trackLength.text = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        } else if (minutes > 0) {
            oCell.trackLength.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
        } else if (seconds > 0){
            oCell.trackLength.text = [NSString stringWithFormat:@"0:%02ld", (long)seconds];
        } else {
            oCell.trackLength.text = [NSString stringWithFormat:@"0:00"];
        }
        
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[[self.artist.albums objectAtIndex:section] tracks ]count] > 0) {
        Album *album = [self.artist.albums objectAtIndex:section];
        
        CGFloat w = self.tableView.frame.size.width;
        
        UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, w, w/4.0f)];
        customTitleView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, w/4.0f - 20, w/4.0f  - 20)];
        if (album.cached_image == nil) {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:album.image_url_large] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError == nil) {
                    album.cached_image = data;
                    imageView.image = [UIImage imageWithData:album.cached_image];
                } else {
                    NSLog(@"Error retrieving album art for album %@: %@", album.name, connectionError);
                    imageView.image = [UIImage imageNamed:@"profile_default.jpg"];
                }
            }];
        } else {
            imageView.image = [UIImage imageWithData:album.cached_image];
        }
        
        
        
        [customTitleView addSubview:imageView];
        
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(w/4.0f, 10, w, 30)];
        titleLabel.text = album.name;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [customTitleView addSubview:titleLabel];
        
        return customTitleView;
    } else {
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[[self.artist.albums objectAtIndex:section] tracks ]count] > 0) {
        return self.tableView.frame.size.width/4.0f;
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
