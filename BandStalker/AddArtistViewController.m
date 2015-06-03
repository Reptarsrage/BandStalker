//
//  AddArtistViewController.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AddArtistViewController.h"

@interface AddArtistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *text_field;
@property (weak, nonatomic) IBOutlet UIButton *go_button;

@end

@implementation AddArtistViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.artist = [[Artist alloc] init];
    self.artist.name = textField.text;
    [self performSegueWithIdentifier:@"DisplaySearchResults" sender:self];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.text_field.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (self.text_field.text != nil) {
        self.artist = [[Artist alloc] init];
        self.artist.name = self.text_field.text;
    }
}


@end
