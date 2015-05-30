//
//  ViewController.m
//  Hits
//
//  Created by John Sloan on 5/12/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import "ViewController.h"
#import "FISoundEngine.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int __block logCounter = 0;
   
    NSError *error = nil;
    FISoundEngine *engine = [FISoundEngine sharedEngine];
    sound = [engine soundNamed:@"SD0010.wav" maxPolyphony:4 error:&error];
    currentlyPlaying = NO;
    shouldCancel = YES;
    
    highestValue = 0;
    BOOL __block stopped;
    
    accelDataWindow = malloc(sizeof(float)*4);
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.deviceUpdateQueue = [NSOperationQueue new];
    _dataWindow = [NSMutableArray array];
    [self.motionManager setDeviceMotionUpdateInterval:.01];
    [self.motionManager startDeviceMotionUpdatesToQueue:self.deviceUpdateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        //NSLog(@"roll: %f, pitch: %f, yaw: %f", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw);
        //NSLog(@"acceleration is: %f", sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2)));
        
        double normalizedMotion[3];
        double mag = [self magnitude:motion];
        normalizedMotion[0] = motion.userAcceleration.x / mag;
        normalizedMotion[1] = motion.userAcceleration.y / mag;
        normalizedMotion[2] = motion.userAcceleration.z / mag;
        //NSLog(@"yaw: %f, pitch: %f, roll: %f", motion.attitude.yaw, motion.attitude.pitch, motion.attitude.roll);
        
        if (mag > 2.5) {
            
            //NSLog(@"vector: x: %f, y: %f, z: %f", normalizedMotion[0], normalizedMotion[1], normalizedMotion[2]);
            stopped = NO;
        } else if (!stopped) {
            //NSLog(@"stopped");
            NSLog(@"pitch: %f, yaw: %f", motion.attitude.pitch, motion.attitude.yaw);
            stopped = YES;
        }
        
        if (fabs(motion.attitude.roll) > 0.75 && fabs(motion.attitude.roll) < 2.4) {
            //NSLog(@"vertical");
            isVertical = YES;
        } else {
            //NSLog(@"flat");
            isVertical = NO;
        }
        
        
        accelDataWindow[3] = accelDataWindow[2];
        accelDataWindow[2] = accelDataWindow[1];
        accelDataWindow[1] = accelDataWindow[0];
        accelDataWindow[0] = mag;
        //NSLog(@"jerk: %f", accelDataWindow[0] - accelDataWindow[3]/4);
        
        logCounter++;
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)drum:(id)sender {
    [sound play];
}

- (double)magnitude:(CMDeviceMotion*)motion {
    return sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2));
}

- (void)playInstrument {
    if (!sound) {
        //NSLog(@"Failed to load sound: %@", error);
    } else {
        [sound play];
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayback  error:&err];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
