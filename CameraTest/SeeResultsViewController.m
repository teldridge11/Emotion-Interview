//
//  SeeResultsViewController.m
//  CameraTest
//
//  Created by Tom Eldridge on 3/6/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

#import "SeeResultsViewController.h"

@interface SeeResultsViewController ()

@end

@implementation SeeResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scoreLabel.text = self.score;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

@end
