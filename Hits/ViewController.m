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

/*

- (CMAcceleration)userAccelerationInWorldRefFrame:(CMAcceleration)acc {
{
    CMRotationMatrix rot = frame.rotationMatrix;
    
    CMAcceleration accRef;
    accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
    accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
    accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
    
    return accRef;
}
 */

- (IBAction)buttonPushed:(id)sender {
    referenceFrame = lastFrame;
}

- (double)angleBetweenV1:(CMAcceleration)v1 andV2:(CMAcceleration)v2 {
    CMAcceleration cross;
    cross.x = v1.y*v2.z - v1.z*v2.y;
    cross.y = v1.z*v2.x - v1.x*v2.z;
    cross.z = v1.x*v2.y - v1.y*v2.x;
    double crossMag = [self magnitude:cross];
    double dot = v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
    return atan2(crossMag, dot);
}

- (CMAcceleration)correctedAcceleration:(CMAcceleration)acc forCurrentAttitude:(CMAttitude*)attitude {
    CMRotationMatrix rot = attitude.rotationMatrix;
    CMAcceleration correctedAcc;
    correctedAcc.x = acc.x*rot.m11 + acc.y*rot.m21 + acc.z*rot.m31;
    correctedAcc.y = acc.x*rot.m12 + acc.y*rot.m22 + acc.z*rot.m32;
    correctedAcc.z = acc.x*rot.m13 + acc.y*rot.m23 + acc.z*rot.m33;
    return correctedAcc;
}

- (double)magnitude:(CMAcceleration)acceleration {
    return sqrt(pow(acceleration.x,2)+pow(acceleration.y,2)+pow(acceleration.z, 2));
}

- (double)averageXValues {
    double total = 0;
    for (NSNumber *x in xValuesArray) {
        total += x.doubleValue;
    }
    NSLog(@"count: %lu", (unsigned long)xValuesArray.count);
    return total/xValuesArray.count;
}

- (void)logAcceleation:(CMAcceleration)acceleration {
    NSLog(@"x: %f, y: %f, z: %f", acceleration.x, acceleration.y, acceleration.z);
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    currentPosition = 0;
    NSError *error = nil;
    FISoundEngine *engine = [FISoundEngine sharedEngine];
    hihat = [engine soundNamed:@"hihat22.wav" maxPolyphony:4 error:&error];
    if (!hihat) {
        NSLog(@"Failed to load sound: %@", error);
    }
    kick = [engine soundNamed:@"kick2.wav" maxPolyphony:4 error:&error];
    if (!kick) {
        NSLog(@"Failed to load sound: %@", error);
    }
    snare = [engine soundNamed:@"SD0010.wav" maxPolyphony:4 error:&error];
    if (!snare) {
        NSLog(@"Failed to load sound: %@", error);
    }
    crash = [engine soundNamed:@"openhat2.wav" maxPolyphony:4 error:&error];
    if (!crash) {
        NSLog(@"Failed to load sound: %@", error);
    }
    tom = [engine soundNamed:@"perc1.wav" maxPolyphony:4 error:&error];
    if (!tom) {
        NSLog(@"Failed to load sound: %@", error);
    }
    tom2 = [engine soundNamed:@"perc2.wav" maxPolyphony:4 error:&error];
    if (!tom2) {
        NSLog(@"Failed to load sound: %@", error);
    }
    
    
    xValuesArray = [NSMutableArray array];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.deviceUpdateQueue = [NSOperationQueue new];
    _dataWindow = [NSMutableArray array];
    [self.motionManager setDeviceMotionUpdateInterval:.01];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:self.deviceUpdateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        lastFrame = motion.attitude;
        CMAttitude *attitude = motion.attitude;
        if (referenceFrame) {
            [attitude multiplyByInverseOfAttitude:referenceFrame];
        }
        CMAcceleration acceleration = [self correctedAcceleration:motion.userAcceleration forCurrentAttitude:attitude];
        double magnitude = [self magnitude:acceleration];
        if (magnitude < 1.2) {
            lowMagCounter++;
            if (lowMagCounter >= 6) {
                didAccelerate = NO;
            }
        }
        
        if (magnitude > 2.0 && acceleration.z > 0) {
            if (lastAcceleration.z == 0) {
                lastAcceleration = acceleration;
            }
            didAccelerate = YES;
            lowMagCounter = 0;
        } else if (didAccelerate && magnitude > 2.2) {
            didAccelerate = NO;
            double angleInDegrees = [self angleBetweenV1:acceleration andV2:lastAcceleration] * 180/M_PI;
            if (angleInDegrees > 80) {
                
                NSLog(@"yaw: %f", attitude.yaw);
                NSLog(@"pitch: %f", attitude.pitch);
                //NSLog(@"magnet: %f", motion.magneticField)
                
                CMCalibratedMagneticField
                
                if (attitude.pitch > .50) {
                    if (attitude.yaw < -.8) {
                        NSLog(@"upper right");
                        [tom2 play];
                    } else if (attitude.yaw > .45) {
                        NSLog(@"upper left");
                        [crash play];
                    } else {
                        NSLog(@"upper center");
                        [tom play];
                    }
                } else {
                    if (attitude.yaw < -.8) {
                        NSLog(@"lower right");
                        [kick play];
                    } else if (attitude.yaw > .45) {
                        NSLog(@"lower left");
                        [hihat play];
                    } else {
                        NSLog(@"lower center");
                        [snare play];
                    }
                }
            }
            lastAcceleration.z = 0;
            stopUpdatingXValues = NO;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
