//
//  CommonController.m
//  BandStalker
//
//  Created by Admin on 7/8/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CommonController.h"

@implementation CommonController

+ (UIView *)getErrorLabel:(CGRect)frame withTitle:(NSString *) title withMsg:(NSString *) msg; {
    if (CGRectIsEmpty(frame))
        return nil;
    
    UIView *errorLabel = [[UIView alloc] init];
    [errorLabel setFrame: CGRectMake(20, 0, frame.size.width - 40.f, frame.size.height) ];
    
    UILabel *errorLabelTitle = [[UILabel alloc] init];
    [errorLabelTitle setFrame:errorLabel.frame];
    errorLabelTitle.textColor = [UIColor grayColor];
    errorLabelTitle.textAlignment = NSTextAlignmentCenter;
    [errorLabelTitle setFont:[UIFont systemFontOfSize:36.0f]];
    errorLabelTitle.text = title;
    
    UILabel *errorLabelMsg= [[UILabel alloc] init];
    [errorLabelMsg setFrame:errorLabel.frame];
    errorLabelMsg.textColor = [UIColor grayColor];
    errorLabelMsg.lineBreakMode = NSLineBreakByWordWrapping;
    errorLabelMsg.numberOfLines = 3;
    errorLabelMsg.textAlignment = NSTextAlignmentCenter;
    [errorLabelMsg setFont:[UIFont systemFontOfSize:14.0f]];
    errorLabelMsg.transform = CGAffineTransformMakeTranslation(0, 35);
    errorLabelMsg.text = msg;
    
    [errorLabel addSubview:errorLabelTitle];
    [errorLabel addSubview:errorLabelMsg];
    
    return errorLabel;
}

@end
