//
//  TrackTableViewCell.h
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *trackNumber;
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (weak, nonatomic) IBOutlet UILabel *trackLength;

@end
