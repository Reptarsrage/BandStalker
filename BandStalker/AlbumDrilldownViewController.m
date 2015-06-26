//AlbumDrilldownViewController
//  AlbumDrilldownViewController.m
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AlbumDrilldownViewController.h"

@interface AlbumDrilldownViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;

@property (weak, nonatomic) IBOutlet UILabel *subLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *thumbMain;
@property (weak, nonatomic) IBOutlet UILabel *subLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subLabel3;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation AlbumDrilldownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.album != nil) {
        self.nav.title = self.album.name;
        self.thumbMain.image = [UIImage imageWithData:self.album.cached_image];
        self.titleLabel.text = self.album.name;
        self.subLabel1.text = [NSString stringWithFormat:@"Artist: %@", self.album.artist];
        self.subLabel2.text = [NSString stringWithFormat:@"Popularity: %0.f", self.album.popularity];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        self.subLabel3.text = [NSString stringWithFormat:@"Release Date: %@", [dateFormatter stringFromDate:self.album.releaseDate]];
    } else {
        // TODO
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
