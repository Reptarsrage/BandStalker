//
//  customTableViewCell.m
//  BandStalker
//
//  Created by Admin on 6/4/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "customTableViewCell.h"

@implementation customTableViewCell {
    @private
    UILabel *tagLabel;
}

/*
@synthesize titleLabel = _titleLabel;
@synthesize subTitleLabel = _subTitleLabel;
@synthesize subTitleLabel2 = _subTitleLabel2;
@synthesize thumbImageView = _thumbImageView;
*/
 
- (void)awakeFromNib {
    // Initialization code
    self.subTitleLabel2 = [[UILabel alloc] init];
    self.titleLabel = [[UILabel alloc] init];
    self.subTitleLabel = [[UILabel alloc] init];
    self.thumbImageView = [[UIImageView alloc] init];
    tagLabel = [[UILabel alloc] init];
    
    
    [self addSubview:self.thumbImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
    [self addSubview:self.subTitleLabel2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:YES];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // draw body
    // number / duration font
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:18];
    
    // number / duration font
    UIFont *f2 = [UIFont fontWithName:@"Helvetica" size:12];
    
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: f1, NSForegroundColorAttributeName: [UIColor blackColor]}];
    CGSize subTitleSize = [self.subTitleLabel.text sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    // set image
    [self.thumbImageView setFrame:CGRectMake(rect.origin.x + 5, rect.origin.y + 5, rect.size.height - 10, rect.size.height - 10)];
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // title
    if (titleSize.width > rect.size.width - self.thumbImageView.frame.size.width - 20) {
        [self.titleLabel setFrame:CGRectMake(self.thumbImageView.frame.origin.x + self.thumbImageView.frame.size.width + 5, self.thumbImageView.frame.origin.y, rect.size.width - self.thumbImageView.frame.size.width - 20, titleSize.height * 2.0f)];
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLabel.numberOfLines = 2;
    } else {
        [self.titleLabel setFrame:CGRectMake(self.thumbImageView.frame.origin.x + self.thumbImageView.frame.size.width + 5, self.thumbImageView.frame.origin.y, rect.size.width - self.thumbImageView.frame.size.width - 20, titleSize.height)];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    // sub title 1
    [self.subTitleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.titleLabel.frame.size.width, subTitleSize.height)];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // sub title 2
    [self.subTitleLabel2 setFrame:CGRectMake(self.subTitleLabel.frame.origin.x, self.subTitleLabel.frame.origin.y + self.subTitleLabel.frame.size.height, self.subTitleLabel.frame.size.width, subTitleSize.height)];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // set text
    [self.titleLabel setFont:f1];
    [self.subTitleLabel setFont:f2];
    [self.subTitleLabel2 setFont:f2];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self.subTitleLabel setTextColor:[UIColor grayColor]];
    [self.subTitleLabel2 setTextColor:[UIColor grayColor]];
    
    // draw tag
    if (self.albumTag != nil) {
        UIColor *c = RGB(85, 173, 250);
        if ([self.albumTag  isEqual: @"Single"]) {
            c = RGB(250, 197, 50);
        } else if([self.albumTag  isEqual: @"Compilation"]) {
            c = RGB(243, 247, 116);
        } else if (![self.albumTag  isEqual: @"Full Album"]) {
            c = RGB(184, 116, 247);
        }
        
        
        CGSize tagLabelSize = [self.albumTag sizeWithAttributes:@{NSFontAttributeName: f2, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [tagLabel setFrame:CGRectMake(self.subTitleLabel2.frame.origin.x, self.subTitleLabel2.frame.origin.y + self.subTitleLabel2.frame.size.height + 3, tagLabelSize.width + 10, tagLabelSize.height + 4)];
        [tagLabel setFont:f2];
        [tagLabel setTextAlignment:NSTextAlignmentCenter];
        [tagLabel setTextColor:[UIColor whiteColor]];
        [tagLabel setBackgroundColor:RGB(29, 185, 84)];
        tagLabel.layer.cornerRadius = 10; // this value vary as per your desire
        tagLabel.clipsToBounds = YES;
        tagLabel.text =self.albumTag;
        [self addSubview:tagLabel];
    }
    
    // draw border
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
