//
//  TrackTableViewCell.m
//  BandStalker
//
//  Created by Admin on 6/26/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TrackTableViewCell.h"

@implementation TrackTableViewCell


- (void)awakeFromNib {
    // Initialization code
    self.trackName = [[UILabel alloc] init];
    self.trackLength = [[UILabel alloc] init];
    self.trackNumber = [[UILabel alloc] init];
    [self addSubview:self.trackName];
    [self addSubview:self.trackLength];
    [self addSubview:self.trackNumber];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // number / duration font
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:16];
    
    // number / duration font
    UIFont *f2 = [UIFont fontWithName:@"Helvetica" size:16];
    
    CGSize numSize = [self.trackNumber.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor grayColor]}];
    CGSize durSize = [self.trackLength.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor grayColor]}];
    CGSize trackSize = [self.trackName.text sizeWithAttributes:@{NSFontAttributeName: f1, NSForegroundColorAttributeName: [UIColor blackColor]}];
    numSize.width = 20;
    
    // set track number
    [self.trackNumber setFrame:CGRectMake(rect.origin.x + 40 - numSize.width, rect.origin.y + (rect.size.height - numSize.height) / 2.f, numSize.width, numSize.height)];
    
    // set track length
    [self.trackLength setFrame:CGRectMake(rect.origin.x + rect.size.width - durSize.width - 10, rect.origin.y + (rect.size.height - durSize.height) / 2.f, durSize.width, durSize.height)];
    
    // set track number
    [self.trackName setFrame:CGRectMake(50, rect.origin.y + (rect.size.height - trackSize.height) / 2.f, rect.size.width - 70 - self.trackLength.frame.size.width, trackSize.height)];
    
    [self.trackName setFont:f1];
    [self.trackNumber setFont:f2];
    [self.trackLength setFont:f2];
    [self.trackName setTextColor:[UIColor blackColor]];
    [self.trackLength setTextColor:[UIColor grayColor]];
    [self.trackNumber setTextColor:[UIColor grayColor]];
}

@end
