//
//  ViewController.m
//  CameraTest
//
//  Created by Boisy Pitre on 1/28/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

#import "ViewController.h"
#import "SeeResultsViewController.h"

#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\":\"a8c57b8c92b490acd0459596818b971afd73f46d89c9f34e4357779fae5434eb\",\"licensor\":\"Affectiva Inc.\",\"expires\":\"2016-04-18\",\"developerId\":\"tom.eldridge@hotmail.com\",\"software\":\"Affdex SDK\"}"
#ifndef YOUR_AFFDEX_LICENSE_STRING_GOES_HERE
#endif

@interface ViewController()


@end

@implementation ViewController
@synthesize myCounterLabel;

int hours, minutes, seconds;
int secondsLeft;
float leadershipScore = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    secondsLeft = 10;
    [self countdownTimer];
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 ) {
        secondsLeft -- ;
        hours = secondsLeft / 3600;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft %3600) % 60;
        myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        self.timerLabel.text = [NSString stringWithFormat:@"%i",secondsLeft];
        if(secondsLeft > 5) {
            self.timerLabel.textColor = [UIColor greenColor];
        }
        else {
            self.timerLabel.textColor = [UIColor redColor];
        }
    }
}

-(void)countdownTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

// Pass leadership score to SeeResultsViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"seeResultsSegue"]){
        SeeResultsViewController *controller = (SeeResultsViewController *)segue.destinationViewController;
        controller.score = [NSString stringWithFormat:@"%.2f", leadershipScore];
    }
}

#pragma mark -
#pragma mark Convenience Methods

// This is a convenience method that is called by the detector:hasResults:forImage:atTime: delegate method below.
// You will want to do something with the face (or faces) found.
- (void)processedImageReady:(AFDXDetector *)detector image:(UIImage *)image faces:(NSDictionary *)faces atTime:(NSTimeInterval)time;
{
    float leadershipScoreAgg = 0;
    int frames = 0;
    
    // iterate on the values of the faces dictionary
    for (AFDXFace *face in [faces allValues])
    {
        frames++;
        
        // Emotion variables
        float anger = face.emotions.anger;
        float sadness = face.emotions.sadness;
        float joy = face.emotions.joy;
        
        if (anger == 0 && joy == 0 && sadness == 0) {
            leadershipScoreAgg += 0;
        }
        else {
            leadershipScoreAgg += (anger+joy+sadness)/3;
        }
        
        // Stop detector when timer runs out, and segue to results view
        if (secondsLeft == 0 && timer != nil) {
            [timer invalidate];
            timer = nil;
            [self destroyDetector];
            leadershipScore = leadershipScoreAgg/frames;
            NSLog(@"Leadership Final: %f",leadershipScore);
            if (leadershipScore > 33) {
                leadershipScore = 100;
            }
            else {
                leadershipScore = 100*(leadershipScore/33);
            }
            [self performSegueWithIdentifier:@"seeResultsSegue" sender:self];
        }
    }
}

// This is a convenience method that is called by the detector:hasResults:forImage:atTime: delegate method below.
// It handles all UNPROCESSED images from the detector. Here I am displaying those images on the camera view.
- (void)unprocessedImageReady:(AFDXDetector *)detector image:(UIImage *)image atTime:(NSTimeInterval)time;
{
    __block ViewController *weakSelf = self;
    
    // UI work must be done on the main thread, so dispatch it there.
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.cameraView setImage:image];
    });
}

- (void)destroyDetector;
{
    [self.detector stop];
}

- (void)createDetector;
{
    // ensure the detector has stopped
    [self destroyDetector];
    
    // create a new detector, set the processing frame rate in frames per second, and set the license string
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingCamera:AFDX_CAMERA_FRONT maximumFaces:1];
    self.detector.maxProcessRate = 3;
    self.detector.licenseString = YOUR_AFFDEX_LICENSE_STRING_GOES_HERE;
    
    // turn on all classifiers (emotions, expressions, and emojis)
    [self.detector setDetectAllEmotions:YES];
    [self.detector setDetectAllExpressions:YES];
    [self.detector setDetectEmojis:YES];
    
    // turn on gender and glasses
    self.detector.gender = TRUE;
    self.detector.glasses = TRUE;
    
    // start the detector and check for failure
    NSError *error = [self.detector start];
    
    if (nil != error)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Detector Error"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:
         ^{}
         ];
        
        return;
    }
}


#pragma mark -
#pragma mark AFDXDetectorDelegate Methods

// This is the delegate method of the AFDXDetectorDelegate protocol. This method gets called for:
// - Every frame coming in from the camera. In this case, faces is nil
// - Every PROCESSED frame that the detector
- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(UIImage *)image atTime:(NSTimeInterval)time;
{
    if (nil == faces)
    {
        [self unprocessedImageReady:detector image:image atTime:time];
    }
    else
    {
        [self processedImageReady:detector image:image faces:faces atTime:time];
    }
}


#pragma mark -
#pragma mark View Methods

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self createDetector]; // create the dector just before the view appears
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [self destroyDetector]; // destroy the detector before the view disappears
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
}

@end
