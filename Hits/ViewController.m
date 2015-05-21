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
    
    highestValue = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.deviceUpdateQueue = [NSOperationQueue new];
    accelDataWindow = [NSMutableArray array];
    [self.motionManager setDeviceMotionUpdateInterval:.01];
    [self.motionManager startDeviceMotionUpdatesToQueue:self.deviceUpdateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        //NSLog(@"roll: %f, pitch: %f, yaw: %f", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw);
        //NSLog(@"acceleration is: %f", sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2)));
        if (fabs(motion.attitude.roll) > 0.75 && fabs(motion.attitude.roll) < 2.4) {
            //NSLog(@"vertical");
            isVertical = YES;
        } else {
            //NSLog(@"flat");
            isVertical = NO;
        }
        
        
        double mag = [self magnitude:motion];
        NSLog(@"mag: %f", mag);
        NSLog(@"currently playing? %d", currentlyPlaying);
        if (mag > 2.5 && !currentlyPlaying) {
            if (highestValue < mag) {
                highestValue = mag;
            } else {
                currentlyPlaying = YES;
                NSLog(@"playing sound %d", currentlyPlaying);
                [sound play];
                NSLog(@"duraion: %f", sound.duration);
                dispatch_time_t playTime = dispatch_time(DISPATCH_TIME_NOW, sound.duration * NSEC_PER_SEC);
                dispatch_after(playTime, dispatch_get_main_queue(), ^(void) {
                    currentlyPlaying = NO;
                    NSLog(@"currently playing? %d", currentlyPlaying);
                    highestValue = 0;
                });
            }
        }
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)didHit {
    if ([accelDataWindow count] > 1) {
        if ([self magnitude:[accelDataWindow lastObject]] < 4) {
            //[accelDataWindow removeAllObjects];
            exceededThreshold = NO;
            return YES;
        }
    }
    return NO;
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
