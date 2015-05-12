//
//  ViewController.m
//  Hits
//
//  Created by John Sloan on 5/12/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [NSString stringWithFormat:@"%@/SD0010.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
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
        if (mag > 4 && !exceededThreshold) {
            exceededThreshold = YES;
        }
        
        if (exceededThreshold) {
            if (mag < 4) {
                exceededThreshold = NO;
                if ([self didHit]) {
                    NSLog(@"WAS A HIT");
                    [self playInstrument];
                } else {
                    NSLog(@"WAS NOT A HIT");
                }
                [accelDataWindow removeAllObjects];
            } else {
                [accelDataWindow addObject:[NSNumber numberWithDouble:[self magnitude:motion]]];
            }
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)didHit {
    return YES;
    //if ([self magnitude:motion]);
}

- (double)magnitude:(CMDeviceMotion*)motion {
    return sqrt(pow(motion.userAcceleration.x,2)+pow(motion.userAcceleration.y,2)+pow(motion.userAcceleration.z,2));
}

- (void)playInstrument {
    [self.audioPlayer stop];
    [self.audioPlayer play];
}

@end
