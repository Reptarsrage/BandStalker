//
//  AddArtistViewController.h
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Artist.h"
#import "AddArtist.h"

@interface AddArtistViewController : UIViewController <UITextFieldDelegate>
@property Artist *artist;

@end
