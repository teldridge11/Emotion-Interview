//
//  ViewController.h
//  CameraTest
//
//  Created by Boisy Pitre on 1/28/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Affdex/Affdex.h>

@interface ViewController : UIViewController <AFDXDetectorDelegate> {
    NSTimer *timer;
    IBOutlet UILabel *myCounterLabel;
}

@property (nonatomic, retain) UILabel *myCounterLabel;
-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;

@property (strong) AFDXDetector *detector;
@property (strong) IBOutlet UIImageView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;


@end

