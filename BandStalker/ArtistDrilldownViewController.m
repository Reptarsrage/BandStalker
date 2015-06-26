//
//  ArtistDrilldownViewController.m
//  BandStalker
//
//  Created by Admin on 6/25/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ArtistDrilldownViewController.h"

@interface ArtistDrilldownViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;

@property (weak, nonatomic) IBOutlet UIImageView *thumbMain;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel1;
@property (weak, nonatomic) IBOutlet UILabel *subLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subLabel3;

@end

@implementation ArtistDrilldownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.artist != nil) {
        self.nav.title = self.artist.name;
        self.thumbMain.image = [UIImage imageWithData:self.artist.cached_image];
        self.titleLabel.text = self.artist.name;
        self.subLabel1.text = [NSString stringWithFormat:@"Followers: %ld", self.artist.followers];
        self.subLabel2.text = [NSString stringWithFormat:@"Popularity: %0.f", self.artist.popularity];
        self.subLabel3.text = [NSString stringWithFormat:@"%lu Albums", (unsigned long)[self.artist.albums count]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
