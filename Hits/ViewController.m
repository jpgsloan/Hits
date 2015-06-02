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
#import "SoundObject.h"
#import "PlayView.h"

@interface ViewController (){
    BOOL isVertical;
    BOOL exceededThreshold;
    BOOL shouldCancel;
    BOOL currentlyPlaying;
    BOOL shouldGetCenterYaw;
    double centerYaw;
    float *accelDataWindow;
}

@property (weak, nonatomic) IBOutlet PlayView *playView;


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
    NSArray *colors = @[[UIColor redColor],[UIColor blueColor],[UIColor yellowColor],[UIColor greenColor],[UIColor purpleColor],[UIColor orangeColor]];
    
    _sounds = [NSMutableArray array];
    NSError *error = nil;
    FISoundEngine *engine = [FISoundEngine sharedEngine];

    for (int i = 0; i < 6; i++) {
        SoundObject *soundObj = [[SoundObject alloc] init];
        soundObj.color = colors[i];
        soundObj.sound = [engine soundNamed:@"SD0010.wav" maxPolyphony:4 error:&error];
        [_sounds addObject:soundObj];
    }
    
    currentlyPlaying = NO;
    shouldCancel = YES;
    shouldGetCenterYaw = YES;
    BOOL __block stopped;
    accelDataWindow = malloc(sizeof(float)*4);
    for (int i = 0; i < 4; i++) {
        accelDataWindow[i] = 0.0;
    }
    /*
    snare = [engine soundNamed:@"SD0010.wav" maxPolyphony:4 error:&error];
    if (!snare) {
        NSLog(@"Failed to load sound: %@", error);
    }
    hihat = [engine soundNamed:@"hihat.wav" maxPolyphony:4 error:&error];
    if (!hihat) {
        NSLog(@"Failed to load sound: %@", error);
    }
    ride = [engine soundNamed:@"ride1.wav" maxPolyphony:4 error:&error];
    if (!ride) {
        NSLog(@"Failed to load sound: %@", error);
    }
    tom = [engine soundNamed:@"tom.wav" maxPolyphony:4 error:&error];
    if (!tom) {
        NSLog(@"Failed to load sound: %@", error);
    }
    crash = [engine soundNamed:@"crash.mp3" maxPolyphony:4 error:&error];
    if (!crash) {
        NSLog(@"Failed to load sound: %@", error);
    }
    kick = [engine soundNamed:@"siren.mp3" maxPolyphony:4 error:&error];
    if (!kick) {
        NSLog(@"Failed to load sound: %@", error);
    }
    */
    
    xValuesArray = [NSMutableArray array];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.deviceUpdateQueue = [NSOperationQueue mainQueue];
    _dataWindow = [NSMutableArray array];
    [self.motionManager setDeviceMotionUpdateInterval:.01];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:self.deviceUpdateQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        [self updatePlayViewWithPitch:motion.attitude.pitch andYaw:motion.attitude.yaw];
        
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
            NSLog(@"accx: %f", acceleration.x);
            if (xValuesArray.count == 0) {
                [xValuesArray addObject:[NSNumber numberWithDouble:acceleration.x]];
            } else if (!stopUpdatingXValues) {
                if ([[xValuesArray lastObject] doubleValue] * acceleration.x > 0) {
                    [xValuesArray addObject:@(acceleration.x)];
                } else {
                    stopUpdatingXValues = YES;
                }
            }
            if (lastAcceleration.z == 0) {
                lastAcceleration = acceleration;
            }
            didAccelerate = YES;
            lowMagCounter = 0;
        } else if (didAccelerate && magnitude > 2.2) {
            didAccelerate = NO;
            double angleInDegrees = [self angleBetweenV1:acceleration andV2:lastAcceleration] * 180/M_PI;
            if (angleInDegrees > 80) {
                double averageX = [self averageXValues];
                [xValuesArray removeAllObjects];
                NSLog(@"averageX: %f", averageX);
                
                if (attitude.pitch > .65) {
                    if (averageX < -1.1) {
                        NSLog(@"upper right");
                        [((SoundObject *)_sounds[0]).sound play];
                    } else if (averageX > 0.1) {
                        NSLog(@"upper left");
                        [((SoundObject *)_sounds[0]).sound play];
                    } else {
                        NSLog(@"upper center");
                        [((SoundObject *)_sounds[0]).sound play];
                    }
                } else {
                    if (averageX < -0.9) {
                        NSLog(@"lower right");
                        [((SoundObject *)_sounds[0]).sound play];
                    } else if (averageX > 0.1) {
                        NSLog(@"lower left");
                        [((SoundObject *)_sounds[0]).sound play];
                    } else {
                        NSLog(@"lower center");
                        [((SoundObject *)_sounds[0]).sound play];
                    }
                }
                
                
            }
            lastAcceleration.z = 0;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatePlayViewWithPitch:(double)pitch andYaw:(double)yaw {
    if (pitch < 0.7) {
        float distanceFromCenter = fabs(centerYaw - yaw);
        if (distanceFromCenter < 0.3) {
            [_playView updateWithCurSoundObject:_sounds[1]];
        } else if (centerYaw - yaw < 0.0) {
            [_playView updateWithCurSoundObject:_sounds[0]];
        } else if (centerYaw - yaw > 0.0) {
            [_playView updateWithCurSoundObject:_sounds[2]];
        }
    } else {
        float distanceFromCenter = fabs(centerYaw - yaw);
        if (distanceFromCenter < 0.3) {
            [_playView updateWithCurSoundObject:_sounds[4]];
        } else if (centerYaw - yaw < 0.0) {
            [_playView updateWithCurSoundObject:_sounds[3]];
        } else if (centerYaw - yaw > 0.0) {
            [_playView updateWithCurSoundObject:_sounds[5]];
        }
    }
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
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw < 0.0) {
            NSLog(@"Played lower left");
            //play sound lower left
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw > 0.0) {
            NSLog(@"Played lower right");
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
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
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw < 0.0) {
            NSLog(@"Played upper left");
            //play sound upper left
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        } else if (centerYaw - yaw > 0.0) {
            NSLog(@"Played upper right");
            //play sound upper right
            FISound *sound = ((SoundObject *) _sounds[0]).sound;
            if (!sound) {
                //NSLog(@"Failed to load sound: %@", error);
            } else {
                [sound play];
            }
        }
    }
}

@end
