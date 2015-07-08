//
//  ArtistsTableViewController.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

@import MediaPlayer;
#import <Spotify/Spotify.h>
#import "ArtistsTableViewController.h"
#import "AppDelegate.h"
#import "ArtistDrilldownTableViewController.h"
#import "customTableViewCell.h"
#import "AlbumsTableViewController.h"

@interface ArtistsTableViewController () {
    @private
    SpotifyManager *sharedManager;
    NSMutableArray *artists;
}
@end


@implementation ArtistsTableViewController


- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddArtistViewController *src = [segue sourceViewController];
    Artist *a = src.artist;
    
    if (a == nil) {
        return;
    }
    
    
    /*The data source enumerates the array of model objects and sends sectionForObject:collationStringSelector: to the collation manager on each iteration. This method takes as arguments a model object and a property or method of the object that it uses in collation. Each call returns the index of the section array to which the model object belongs, and that value is assigned to the sectionNumber property.*/
    /*UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
    NSInteger sect = [col sectionForObject:a collationStringSelector:@selector(name)];
    a.sectionNumber = sect;
    
    //find correct place and add item
    NSUInteger index = [[artists objectAtIndex:sect] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(Artist *)obj name] caseInsensitiveCompare:a.name] == NSOrderedDescending) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        [[artists objectAtIndex:sect] addObject:a];
    } else {
        [[artists objectAtIndex:sect] insertObject:a atIndex:index];
    }*/
    [sharedManager retrieveArtistInfoFromSpotify:a forController:self];
    //[self.tableView reloadData];

}

- (void) addAlbum:(Album *)album toArtist:(NSString *)artistName {
    if (album == nil || artistName == nil || [artistName length] == 0)
        return;
    
    
    NSInteger sect = ((int)[[artistName uppercaseString] characterAtIndex:0]) - 65;
    
    //find correct place and add item
    NSUInteger index = [[artists objectAtIndex:sect] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(Artist *)obj name] caseInsensitiveCompare:artistName] == NSOrderedSame) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    
    [[[artists objectAtIndex:sect] objectAtIndex:index] addToAlbums:album];
}

- (void) artistInfoCallback:(BOOL)success artist:(Artist *)artist error:(NSError *)error {
    if (success) {
         //find correct artist and update info
        UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
        NSInteger sect = [col sectionForObject:artist collationStringSelector:@selector(name)];
        artist.sectionNumber = sect;
        
        //find correct place and add item
        NSUInteger index = [[artists objectAtIndex:sect] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(Artist *)obj name] caseInsensitiveCompare:artist.name] == NSOrderedDescending) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound) {
            [[artists objectAtIndex:sect] addObject:artist];
        } else {
            [[artists objectAtIndex:sect] insertObject:artist atIndex:index];
        }
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:sect], nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        NSLog(@"Error retrieving artist info for %@: %@", artist.name, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Found" message:[NSString stringWithFormat:@"No info found for artist \"%@\"", artist.name ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [[artists objectAtIndex:artist.sectionNumber ] removeObject:artist];
        [self.tableView reloadData];
    }
}



- (void)loadInitialData:(NSMutableArray *)artistInitial {
    // Getting the uri for each artist
    for (Artist *artist in artistInitial) {
        [sharedManager retrieveArtistInfoFromSpotify:artist forController:self];
    }
}

- (NSMutableArray *)getArtists {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    
    Artist *a1 = [[Artist alloc] init];
    a1.name = @"Modest Mouse";
    [ret addObject:a1];
    
    Artist *a2 = [[Artist alloc] init];
    a2.name = @"Ninja Sex Party";
    [ret addObject:a2];
    
    Artist *a3 = [[Artist alloc] init];
    a3.name = @"Disturbed";
    [ret addObject:a3];
    
    for (MPMediaItemCollection *collection in [[MPMediaQuery artistsQuery] collections]) {
        a1 = [[Artist alloc] init];
        a1.name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        //[ret addObject:a1];
    }
    
    return ret;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Artist *a = [[artists objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ArtistDrilldownSegue" sender:a];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    sharedManager = [SpotifyManager sharedManager];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.rowHeight = 80.0f;
    
    NSMutableArray *artistsTemp = [self getArtists];
    
    /*The data source enumerates the array of model objects and sends sectionForObject:collationStringSelector: to the collation manager on each iteration. This method takes as arguments a model object and a property or method of the object that it uses in collation. Each call returns the index of the section array to which the model object belongs, and that value is assigned to the sectionNumber property.*/
    UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
    for (Artist *a in artistsTemp) {
        NSInteger sect = [col sectionForObject:a collationStringSelector:@selector(name)];
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
    //for (Artist *a in artistsTemp) {
    //   [(NSMutableArray *)[sectionArrays objectAtIndex:a.sectionNumber] addObject:a];
    //}
    // (4)
    artists = [NSMutableArray arrayWithCapacity:1];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSMutableArray *sortedSection = [NSMutableArray arrayWithArray:[col sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)]];
        [artists addObject:sortedSection];
    }
    
    // start retrieving data for artists
    [self loadInitialData:artistsTemp];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[artists objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [sharedManager removeArtist:[[artists objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [[artists objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [artists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[artists objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    customTableViewCell *oCell = (customTableViewCell *)cell;
    Artist *a = [[artists objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (a.id == nil || a.image_url_small == nil) {
        oCell.titleLabel.text = a.name;
        oCell.subTitleLabel.text = @"Error retrieving data";
        oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
        
        
    } else {
        oCell.titleLabel.text = a.name;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:a.image_url_large] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (connectionError == nil) {
                a.cached_image = data;
                oCell.thumbImageView.image = [UIImage imageWithData:data];
            } else {
                NSLog(@"Error retrieving album art for album %@: %@", a.name, connectionError);
                oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
            }
        }];

        oCell.subTitleLabel.text = [NSString stringWithFormat:@"popularity: %.0f", a.popularity];
        oCell.subTitleLabel2.text = [NSString stringWithFormat:@"followers: %ld", a.followers];
        
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[artists objectAtIndex:section] count] > 0) {
        UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        customTitleView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
        
        titleLabel.text = [NSString stringWithFormat: @"%c", (char)(section + 65)];
        
        titleLabel.textColor = [UIColor grayColor];
        
        titleLabel.backgroundColor = [UIColor whiteColor];
        
        [customTitleView addSubview:titleLabel];

        
        return customTitleView;
    } else {
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[artists objectAtIndex:section] count] > 0) {
        return 30;
    } else {
        return 0;
    }
}


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
    // Pass the  object to the new view controller.
    if ([segue.identifier isEqualToString:@"ArtistDrilldownSegue"]) {
        Artist *a = (Artist *)sender;
        UINavigationController *navController = [segue destinationViewController];
        ArtistDrilldownTableViewController *SITViewController = (ArtistDrilldownTableViewController *)([navController viewControllers][0]);
        SITViewController.artist = a;
    }
}


@end
