//
//  customTableViewCell.h
//  BandStalker
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel2;
@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;

@end
