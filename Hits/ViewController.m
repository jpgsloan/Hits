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
   
    NSError *error = nil;
    FISoundEngine *engine = [FISoundEngine sharedEngine];
    sound = [engine soundNamed:@"SD0010.wav" maxPolyphony:4 error:&error];
    currentlyPlaying = NO;
    shouldCancel = YES;
    BOOL __block stopped;
    accelDataWindow = malloc(sizeof(float)*4);
    for (int i = 0; i < 4; i++) {
        accelDataWindow[i] = 0.0;
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.deviceUpdateQueue = [NSOperationQueue new];
    _dataWindow = [NSMutableArray array];
    [self.motionManager setDeviceMotionUpdateInterval:.01];
    [self.motionManager startDeviceMotionUpdatesToQueue:self.deviceUpdateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        //NSLog(@"roll: %f, pitch: %f, yaw: %f", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw);
        //NSLog(@"acceleration is: %f", sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2)));
        
        if (shouldGetCenterYaw) {
            centerYaw = motion.attitude.yaw;
        }
        
        double mag = [self magnitude:motion];
        double normalizedMotion[3];
        normalizedMotion[0] = motion.userAcceleration.x / mag;
        normalizedMotion[1] = motion.userAcceleration.y / mag;
        normalizedMotion[2] = motion.userAcceleration.z / mag;
        float jerk = (accelDataWindow[0] - accelDataWindow[3])/4;
        
        if (jerk > 0.7) {
            //NSLog(@"vector: x: %f, y: %f, z: %f", normalizedMotion[0], normalizedMotion[1], normalizedMotion[2]);
            stopped = NO;
        } else if (!stopped) {
            //NSLog(@"stopped");
            NSLog(@"pitch: %f, yaw: %f", motion.attitude.pitch, motion.attitude.yaw);
            stopped = YES;
            [self playInstrumentWithPitch:motion.attitude.pitch andYaw:motion.attitude.yaw];
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
        //NSLog(@"jerk: %f", (accelDataWindow[0] - accelDataWindow[3])/4);
        }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double)magnitude:(CMDeviceMotion*)motion {
    return sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2));
}

- (void)playInstrumentWithPitch:(double)pitch andYaw:(double)yaw {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayback  error:&err];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if (pitch < 0.7) {
        float distanceFromCenter = fabs(centerYaw - yaw);
        if (distanceFromCenter < 0.3) {
            //play sound lower center
            NSLog(@"Played lower center");
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw < 0.0) {
            NSLog(@"Played lower left");
            //play sound lower left
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw > 0.0) {
            NSLog(@"Played lower right");
            //play sound lower right
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        }
    } else {
        float distanceFromCenter = fabs(centerYaw - yaw);
        if (distanceFromCenter < 0.3) {
            NSLog(@"Played upper center");
            //play sound upper center
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw < 0.0) {
            NSLog(@"Played upper left");
            //play sound upper left
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw > 0.0) {
            NSLog(@"Played upper right");
            //play sound upper right
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        }
    }
}

@end
