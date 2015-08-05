//
//  customTableViewCell.h
//  BandStalker
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonController.h"

@interface customTableViewCell : UITableViewCell

@property (nonatomic, retain)  UILabel *titleLabel;
@property (nonatomic, retain)  UILabel *subTitleLabel;
@property (nonatomic, retain)  UILabel *subTitleLabel2;
@property (nonatomic, retain)  UIImageView *thumbImageView;
@property (nonatomic, retain)  NSString *albumTag;

@end
