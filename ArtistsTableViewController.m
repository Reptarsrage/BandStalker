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
#import "customTableViewCell.h"

@interface ArtistsTableViewController ()
    @property NSMutableArray *artists;
    @property (nonatomic, strong) SPTSession *session;
@end

@implementation ArtistsTableViewController


- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    AddArtistViewController *src = [segue sourceViewController];
    Artist *a = src.artist;
    
    if (a == nil) {
        return;
    }
    
    /*The data source enumerates the array of model objects and sends sectionForObject:collationStringSelector: to the collation manager on each iteration. This method takes as arguments a model object and a property or method of the object that it uses in collation. Each call returns the index of the section array to which the model object belongs, and that value is assigned to the sectionNumber property.*/
    UILocalizedIndexedCollation *col = [UILocalizedIndexedCollation currentCollation];
    NSInteger sect = [col sectionForObject:a collationStringSelector:@selector(name)];
    a.sectionNumber = sect;
    
    //find correct place and add item
    NSUInteger index = [[self.artists objectAtIndex:sect] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(Artist *)obj name] caseInsensitiveCompare:a.name] == NSOrderedDescending) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound) {
        [[self.artists objectAtIndex:sect] addObject:a];
    } else {
        [[self.artists objectAtIndex:sect] insertObject:a atIndex:index];
    }
    [self retrieveArtistInfoFromSpotify:a];
    [self.tableView reloadData];

}

- (void)retrieveArtistInfoFromSpotify:(Artist *)artist {
    [SPTSearch performSearchWithQuery:artist.name queryType:SPTQueryTypeArtist accessToken:SpotifyAccessToken callback:^(NSError *error, id object) {
        if (error != nil) {
            NSLog(@"Error retrieving artist infor for %@: %@", artist.name, error);
        } else {
            SPTListPage *page = object;
            
            if ([page.items count] <= 0) {
                NSLog(@"Error retrieving artist infor for %@: %@", artist.name, @"No results found");
            } else {
                
                SPTPartialArtist *o = [page.items firstObject];
                artist.name = o.name;
                artist.id = (NSString *)o.uri ;
                artist.href = o.sharingURL;
                
                // get detailed info for each artist
                [self getAllArtistInfo:[NSMutableArray arrayWithObjects:artist.id, nil]];
            }
        }
    }];
}


- (void)getAllArtistInfo:(NSMutableArray *)artistIds {
    [SPTArtist artistsWithURIs:artistIds session:SpotifySession callback:^(NSError *error1, id object1) {
        if (error1 != nil) {
            NSLog(@"Error retrieving artist info for artists: %@", error1);
            return;
        }
        
        NSArray *page1 = object1;
        
        if ([page1 count] != [artistIds count]) {
            NSLog(@"Error retrieving artist info : %@", @"No results found");
            return;
        }
        
        for (SPTArtist *a in page1) {
            Artist *a1 = nil;
            NSString *fChar = [[a.name substringToIndex:1] uppercaseString];
            //find correct artist and update info
            NSUInteger section = [self.artists indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableArray *arr = (NSMutableArray *)obj;
                if (arr && [arr count] > 0 && [[[[(Artist *)[arr firstObject] name] substringToIndex:1] uppercaseString] isEqualToString:fChar]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            NSUInteger index;
            if (section != NSNotFound) {
                index = [[self.artists objectAtIndex:section] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    if ([[(Artist *)obj name] isEqualToString:a.name]) {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                }];
            } else {
                index = NSNotFound;
            }
        
            if (index != NSNotFound && a.uri != nil) {
                a1 = [[self.artists objectAtIndex:section] objectAtIndex:index];
                a1.image_url_large = a.largestImage.imageURL;
                a1.image_url_small = a.smallestImage.imageURL;
                a1.image_url_med = nil;
                a1.popularity = a.popularity;
                a1.followers = a.followerCount;
                
                //update in table
                 NSIndexPath *iPath = [NSIndexPath indexPathForRow:index inSection:section];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:iPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            
            } else {
                NSLog(@"Error updating artist info for %@: %@", a.name, @"Artist not found in table");
            }
        }
    }];
}

- (void)loadInitialData:(NSInteger)count {
    // Getting the uri for each artist
    NSMutableArray *artistIds = [[NSMutableArray alloc] init];
    for (NSMutableArray *section in self.artists){
        for (Artist *artist in section) {
            [SPTSearch performSearchWithQuery:artist.name queryType:SPTQueryTypeArtist accessToken:SpotifyAccessToken callback:^(NSError *error, id object) {
                if (error != nil) {
                    NSLog(@"Error retrieving artist infor for %@: %@", artist.name, error);
                    [artistIds addObject:nil];
                } else {
                    SPTListPage *page = object;
                    
                    if ([page.items count] <= 0) {
                        NSLog(@"Error retrieving artist infor for %@: %@", artist.name, @"No results found");
                        [artistIds addObject:nil];
                    } else {
                        
                        SPTPartialArtist *o = [page.items firstObject];
                        artist.name = o.name;
                        artist.id = (NSString *)o.uri ;
                        artist.href = o.sharingURL;
                        
                        // get detailed info for each artist
                        [artistIds addObject:artist.id];
                        if (artistIds && [artistIds count] == count) {
                            [self getAllArtistInfo:artistIds];
                        }
                    }
                }
            }];
        }
    }
}

- (NSMutableArray *)getArtists {
    NSMutableArray *artists = [[NSMutableArray alloc] init];
    
    Artist *a1 = [[Artist alloc] init];
    a1.name = @"Modest Mouse";
    [artists addObject:a1];
    
    Artist *a2 = [[Artist alloc] init];
    a2.name = @"Beck";
    [artists addObject:a2];
    
    Artist *a3 = [[Artist alloc] init];
    a3.name = @"Disturbed";
    [artists addObject:a3];
    
    for (MPMediaItemCollection *collection in [[MPMediaQuery artistsQuery] collections]) {
        a1 = [[Artist alloc] init];
        a1.name = [[collection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        [artists addObject:a1];
    }
    
    return artists;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.rowHeight = 80.0f;
    
    NSMutableArray *artistsTemp = [self getArtists];
    NSInteger count = [artistsTemp count];
    
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
    for (Artist *a in artistsTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:a.sectionNumber] addObject:a];
    }
    // (4)
    self.artists = [NSMutableArray arrayWithCapacity:1];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSMutableArray *sortedSection = [NSMutableArray arrayWithArray:[col sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)]];
        [self.artists addObject:sortedSection];
    }
    
    // start retrieving data for artists
    [self loadInitialData:count];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.artists objectAtIndex:section] count] > 0) {
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
        [[self.artists objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
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
    return [self.artists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.artists objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    customTableViewCell *oCell = (customTableViewCell *)cell;
    Artist *a = [[self.artists objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (a.id == nil || a.image_url_small == nil) {
        oCell.titleLabel.text = a.name;
        oCell.subTitleLabel.text = @"Error retrieving data";
        oCell.thumbImageView.image = [UIImage imageNamed:@"profile_default.jpg"];
        
        
    } else {
        oCell.titleLabel.text = a.name;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:a.image_url_large] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             oCell.thumbImageView.image = [UIImage imageWithData:data];
        }];

        oCell.subTitleLabel.text = [NSString stringWithFormat:@"id: %@ popularity: %f followers: %ld", a.id, a.popularity, a.followers];
        
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([[self.artists objectAtIndex:section] count] > 0) {
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
    if ([[self.artists objectAtIndex:section] count] > 0) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
