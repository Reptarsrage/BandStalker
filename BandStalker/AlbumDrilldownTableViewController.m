//
//  AlbumDrilldownTableViewController.m
//  BandStalker
//
//  Created by Admin on 7/1/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AlbumDrilldownTableViewController.h"

@interface AlbumDrilldownTableViewController () {
    __weak IBOutlet UINavigationItem *nav;
@private SpotifyManager *sharedManager;
}

@end

@implementation AlbumDrilldownTableViewController

- (void) albumInfoCallback:(Album *)album error:(NSError *)error {
    if (error == nil && album != nil) {
        [self.tableView reloadData];
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
    imageView.image = [UIImage imageWithData:self.album.cached_image];
    labelView.text = self.album.name;
    
    if (self.album.tracks == nil || self.album.nextTrackPageUrl != nil)
        [sharedManager getAllTracksForAlbum:self.album  withCallback:^(Album *album, NSError *error) {
            [self albumInfoCallback:album error:error];
        }];
    nav.title = self.album.name;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.album.tracks count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TrackTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    TrackTableViewCell *oCell = (TrackTableViewCell *)cell;
    Track *a = [self.album.tracks objectAtIndex:indexPath.row];
    if (a == nil || a.name == nil) {
        oCell.trackName.text = @"Unkown track";
        oCell.trackLength.text = [NSString stringWithFormat:@"0:00"];
        oCell.trackNumber.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    } else {
        oCell.trackName.text = a.name;
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