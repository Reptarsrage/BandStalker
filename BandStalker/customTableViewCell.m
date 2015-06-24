//
//  customTableViewCell.m
//  BandStalker
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "customTableViewCell.h"

@implementation customTableViewCell

@synthesize titleLabel = _titleLabel;
@synthesize subTitleLabel = _subTitleLabel;
@synthesize thumbImageView = _thumbImageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, 0.0f, rect.size.height - 1.0f);//start at this point
    
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0f); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
