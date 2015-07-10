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
    UIView *errorLabel;
    UILabel *headerLabelAlbumCount;
}

@end



@implementation ArtistDrilldownTableViewController

- (void) showEmptyTableLabel {
    // show message if empty
    if (self.artist == nil || [self.artist.albums count] == 0) {
        //errorLabel.hidden = NO;
        self.tableView.backgroundView = errorLabel;
    } else {
        //    errorLabel.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}

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
    
    headerLabelAlbumCount.text = [NSString localizedStringWithFormat:@"Albums: %lu", (unsigned long)self.artist.albums.count];
    [self showEmptyTableLabel];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == alertView.cancelButtonIndex)
    { // cancelled
        
    }
    else
    {
        [[UIApplication sharedApplication] openURL:self.artist.href];
    }
}

- (void) redirect:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigation warning" message:[NSString stringWithFormat:@"Would you like to continue to %@?", self.artist.href] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void) drawHeader {
    // create header using artist info
    CGFloat w = self.tableView.frame.size.width;
    
    // create header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, (w/2.0f) + 20.0f)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, w/2.0f - 10, w/2.0f  - 10)];
    UILabel *subTitleView = [[UILabel alloc] init];
    UILabel *subTitleView1 = [[UILabel alloc] init];
    headerLabelAlbumCount = [[UILabel alloc] init];
    UIButton *subTitleView3 = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *titleView = [[UILabel alloc] init];

    // add all info
    imageView.image = [UIImage imageWithData:self.artist.cached_image];
    titleView.text = self.artist.name;
    subTitleView.text = [NSString localizedStringWithFormat:@"Popularity: %0.f", self.artist.popularity];
    subTitleView1.text = [NSString localizedStringWithFormat:@"Followers: %ld", self.artist.followers];
    headerLabelAlbumCount.text = [NSString localizedStringWithFormat:@"Albums: %lu", (unsigned long)self.artist.albums.count];
    [subTitleView3 setTitle:[NSString localizedStringWithFormat:@"Spotify"] forState:UIControlStateNormal];
    
    // title font
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24];
    
    // subtitle font
    UIFont *f2 = [UIFont fontWithName:@"Helvetica" size:14];
    
    CGSize titleSize = [titleView.text sizeWithAttributes:@{NSFontAttributeName: f1, NSForegroundColorAttributeName: [UIColor blackColor]}];
    CGSize subTitleSize = [subTitleView.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor grayColor]}];
    CGSize subTitle3Size = [subTitleView3.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    subTitleSize.height += 10;
    
    // image
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor lightGrayColor];
    
    // title
    if (titleSize.width > headerView.frame.size.width - imageView.frame.size.width - 20) {
        [titleView setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, headerView.frame.size.width - imageView.frame.size.width - 20, titleSize.height * 2.0f)];
        titleView.lineBreakMode = NSLineBreakByWordWrapping;
        titleView.numberOfLines = 2;
    } else {
        [titleView setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, headerView.frame.size.width - imageView.frame.size.width - 20, titleSize.height)];
        titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    [titleView setFont:f1];
    [titleView setTextColor:[UIColor blackColor]];
    
    // sub title - popularity
    [subTitleView setFrame:CGRectMake(titleView.frame.origin.x, titleView.frame.origin.y + titleView.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
    subTitleView.lineBreakMode = NSLineBreakByTruncatingTail;
    [subTitleView setFont:f2];
    [subTitleView setTextColor:[UIColor grayColor]];
    
    // sub title 1 - followers
    [subTitleView1 setFrame:CGRectMake(titleView.frame.origin.x, subTitleView.frame.origin.y + subTitleView.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
    subTitleView1.lineBreakMode = NSLineBreakByTruncatingTail;
    [subTitleView1 setFont:f2];
    [subTitleView1 setTextColor:[UIColor grayColor]];
    
    // sub title 2 - albums
    [headerLabelAlbumCount setFrame:CGRectMake(titleView.frame.origin.x, subTitleView1.frame.origin.y + subTitleView1.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
    headerLabelAlbumCount.lineBreakMode = NSLineBreakByTruncatingTail;
    [headerLabelAlbumCount setFont:f2];
    [headerLabelAlbumCount setTextColor:[UIColor grayColor]];
    
    // sub title 3 - href
    [subTitleView3 setFrame:CGRectMake(titleView.frame.origin.x, headerLabelAlbumCount.frame.origin.y + headerLabelAlbumCount.frame.size.height, subTitle3Size.width + 40, subTitle3Size.height + 10)];
    [subTitleView3.titleLabel setFont:f2];
    [subTitleView3.titleLabel setTextColor:[UIColor whiteColor]];
    [subTitleView3 setBackgroundColor:RGB(29, 185, 84)];
    subTitleView3.layer.cornerRadius = 10; // this value vary as per your desire
    subTitleView3.clipsToBounds = YES;
    [subTitleView3 addTarget:self action:NSSelectorFromString(@"redirect:") forControlEvents:UIControlEventTouchUpInside];
    
    
    // add to view
    [headerView addSubview:titleView];
    [headerView addSubview:imageView];
    [headerView addSubview:subTitleView];
    [headerView addSubview:subTitleView1];
    [headerView addSubview:headerLabelAlbumCount];
    [headerView addSubview:subTitleView3];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedManager = [SpotifyManager sharedManager];
    [self drawHeader];
    
    // get the common empty table error message
    errorLabel = [CommonController getErrorLabel:self.tableView.frame withTitle:@"No Information" withMsg:@"There is no information to display for this artist"];
    
    if (self.artist.albums == nil || [self.artist.albums count] == 0)
        [sharedManager getAllAlbumsForArtist:self.artist.id pageURL:nil withAlbumUris:nil  withCallback:^(Album *album, NSError *error) {
            [self albumInfoCallback:album error:error];
        }];
    nav.title = self.artist.name;
    
    [self showEmptyTableLabel];
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
        
        
        // create header using album info
        CGFloat w = self.tableView.frame.size.width;
        
        // create header
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, w/4.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, w/4.0f - 10, w/4.0f  - 10)];
        UILabel *subTitleView = [[UILabel alloc] init];
        UILabel *subTitleView1 = [[UILabel alloc] init];
        UILabel *subTitleView2 = [[UILabel alloc] init];
        UILabel *titleView = [[UILabel alloc] init];
        
        // add all info
        titleView.text = album.name;
        subTitleView.text = [NSString localizedStringWithFormat:@"Popularity: %0.f", album.popularity];
        subTitleView1.text = [NSString localizedStringWithFormat:@"Type: %@", album.type];
        subTitleView2.text = [NSString localizedStringWithFormat:@"Tracks: %lu", (unsigned long)album.tracks.count];
        
        // image (special)
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
        
        // title font
        UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:18];
        
        // subtitle font
        UIFont *f2 = [UIFont fontWithName:@"Helvetica" size:12];
        
        CGSize titleSize = [titleView.text sizeWithAttributes:@{NSFontAttributeName: f1, NSForegroundColorAttributeName: [UIColor blackColor]}];
        CGSize subTitleSize = [subTitleView.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor grayColor]}];
        
        // image
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // title
        if (titleSize.width > headerView.frame.size.width - imageView.frame.size.width - 20) {
            [titleView setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, headerView.frame.size.width - imageView.frame.size.width - 20, titleSize.height * 2.0f)];
            titleView.lineBreakMode = NSLineBreakByWordWrapping;
            titleView.numberOfLines = 2;
        } else {
            [titleView setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, headerView.frame.size.width - imageView.frame.size.width - 20, titleSize.height)];
            titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        [titleView setFont:f1];
        [titleView setTextColor:[UIColor blackColor]];
        
        // sub title - popularity
        [subTitleView setFrame:CGRectMake(titleView.frame.origin.x, titleView.frame.origin.y + titleView.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
        subTitleView.lineBreakMode = NSLineBreakByTruncatingTail;
        [subTitleView setFont:f2];
        [subTitleView setTextColor:[UIColor grayColor]];
        
        // sub title 1 - type
        [subTitleView1 setFrame:CGRectMake(titleView.frame.origin.x, subTitleView.frame.origin.y + subTitleView.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
        subTitleView1.lineBreakMode = NSLineBreakByTruncatingTail;
        [subTitleView1 setFont:f2];
        [subTitleView1 setTextColor:[UIColor grayColor]];
        
        // sub title 2 - tracks
        [subTitleView2 setFrame:CGRectMake(titleView.frame.origin.x, subTitleView1.frame.origin.y + subTitleView1.frame.size.height, titleView.frame.size.width, subTitleSize.height)];
        subTitleView2.lineBreakMode = NSLineBreakByTruncatingTail;
        [subTitleView2 setFont:f2];
        [subTitleView2 setTextColor:[UIColor grayColor]];
        
        
        // add to view
        [headerView addSubview:titleView];
        [headerView addSubview:imageView];
        [headerView addSubview:subTitleView];
        [headerView addSubview:subTitleView1];
        [headerView addSubview:subTitleView2];
        
        headerView.backgroundColor = [UIColor whiteColor];
        
        return headerView;
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
