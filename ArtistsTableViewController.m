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
#import "bandsInTownManager.h"

@interface ArtistsTableViewController () {
    @private
    SpotifyManager *sharedManager;
    bandsInTownManager * bandSharedManager;
    NSMutableArray *artists;
    UIView *errorLabel;
    NSInteger artistCount;
}
@end


@implementation ArtistsTableViewController

- (void) showEmptyTableLabel {
    // show message if empty
    if (artists == nil || artistCount == 0) {
        //errorLabel.hidden = NO;
        self.tableView.backgroundView = errorLabel;
    } else {
    //    errorLabel.hidden = YES;
        self.tableView.backgroundView = nil;
    }
}

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
            artistCount++;
        } else {
            [[artists objectAtIndex:sect] insertObject:artist atIndex:index];
            artistCount++;
        }
        
        [self showEmptyTableLabel];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sect] withRowAnimation:UITableViewRowAnimationNone];
        
        [bandSharedManager.artistQueue addObject:artist];
        
    } else {
        NSLog(@"Error retrieving artist info for %@: %@", artist.name, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Found" message:[NSString stringWithFormat:@"No info found for artist \"%@\"", artist.name ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [[artists objectAtIndex:artist.sectionNumber ] removeObject:artist];
        artistCount--;
        [self showEmptyTableLabel];
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
    NSArray *testArtists = [NSArray arrayWithObjects:@"Future"  ,@"Taylor Swift"  ,@"The Weeknd"  ,@"Fetty Wap"  ,@"Ed Sheeran"  ,@"OMI"  ,@"Meek Mill"  ,@"Maroon 5"  ,@"Luke Bryan"  ,@"Drake"  ,@"Sam Hunt"  ,@"Nicki Minaj"  ,@"5 Seconds Of Summer"  ,@"Tyrese"  ,@"Silento"  ,@"Fall Out Boy"  ,@"Tame Impala"  ,@"Rachel Platten"  ,@"Jason Isbell"  ,@"Alan Jackson"  ,@"Meghan Trainor"  ,@"WALK THE MOON"  ,@"Andy Grammer"  ,@"Wiz Khalifa"  ,@"Selena Gomez"  ,@"Kendrick Lamar"  ,@"Jason Derulo"  ,@"Zac Brown Band"  ,@"Demi Lovato"  ,@"Sam Smith"  ,@"Fifth Harmony"  ,@"Bruno Mars"  ,@"Little Big Town"  ,@"Chris Brown"  ,@"Ariana Grande"  ,@"Justin Bieber"  ,@"Florida Georgia Line"  ,@"Eminem"  ,@"Rihanna"  ,@"Pitbull"  ,@"Eric Church"  ,@"Imagine Dragons"  ,@"Katy Perry"  ,@"Blake Shelton"  ,@"Kidz Bop Kids"  ,@"Jason Aldean"  ,@"Shawn Mendes"  ,@"Rae Sremmurd"  ,@"Sia"  ,@"David Guetta"  ,@"twenty one pilots"  ,@"DJ Snake"  ,@"Tove Lo"  ,@"Big Sean"  ,@"J. Cole"  ,@"Ellie Goulding"  ,@"A$AP Rocky"  ,@"Charlie Puth"  ,@"Brantley Gilbert"  ,@"Kid Ink"  ,@"Joan Sebastian"  ,@"Mark Ronson"  ,@"Rich Homie Quan"  ,@"One Direction"  ,@"Anthony Brown and; group therAPy"  ,@"Beyonce"  ,@"Thomas Rhett"  ,@"X Ambassadors"  ,@"Trey Songz"  ,@"Flo Rida"  ,@"Calvin Harris"  ,@"Kenny Chesney"  ,@"Keith Urban"  ,@"Mumford and; Sons"  ,@"Hozier"  ,@"Metallica"  ,@"Major Lazer"  ,@"Omarion"  ,@"Kid Rock"  ,@"Monty"  ,@"Skrillex"  ,@"Miley Cyrus"  ,@"Karen Clark-Sheard"  ,@"Chris Janson"  ,@"Jidenna"  ,@"Jeremih"  ,@"Michael Jackson"  ,@"Nick Jonas"  ,@"Miguel"  ,@"Diplo"  ,@"Canaan Smith"  ,@"George Ezra"  ,@"Kelly Clarkson"  ,@"Tori Kelly"  ,@"Cole Swindell"  ,@"Carrie Underwood"  ,@"T-Wayne"  ,@"Miranda Lambert"  ,@"Brett Eldredge"  ,@"Adam Lambert"  ,nil];
    
    for (NSString * a in testArtists) {
        Artist *a1 = [[Artist alloc] init];
        a1.name = a;
        [ret addObject:a1];
        
    }
    
    for (MPMediaItemCollection *collection in [[MPMediaQuery artistsQuery] collections]) {
        Artist *a1 = [[Artist alloc] init];
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
    
    [self showEmptyTableLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    sharedManager = [SpotifyManager sharedManager];
    bandSharedManager = [bandsInTownManager sharedManager];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    //self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.rowHeight = 80.0f;
    
    NSMutableArray *artistsTemp = [self getArtists];
    artistCount = 0;
    
    // get the common empty table error message
    errorLabel = [CommonController getErrorLabel:self.tableView.frame withTitle:@"No Artists" withMsg:@"Use the + icon in the upper right to add artists"];
    
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
        [bandSharedManager removeArtist:[[artists objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        
        [[artists objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        artistCount--;
        [self showEmptyTableLabel];
        [self.tableView reloadData];
        
        if ([[sharedManager artistQueue] count] == 0) {
            sharedManager.newItems = NO;
            UITabBarController *tbc = self.tabBarController;
            UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:1];
            [tbi setBadgeValue:nil];
        }
        
        if ([[bandSharedManager artistQueue] count] == 0) {
            bandSharedManager.newItems = NO;
            UITabBarController *tbc = self.tabBarController;
            UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:2];
            [tbi setBadgeValue:nil];
        }
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
        oCell.subTitleLabel2.text = [NSString localizedStringWithFormat:@"followers: %ld", a.followers];
        
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
