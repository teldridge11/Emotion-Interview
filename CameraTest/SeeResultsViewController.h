//
//  SeeResultsViewController.h
//  CameraTest
//
//  Created by Tom Eldridge on 3/6/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeeResultsViewController : UIViewController

@property (strong, nonatomic) NSString *score;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@end
