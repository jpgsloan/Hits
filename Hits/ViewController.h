//
//  ViewController.h
//  Hits
//
//  Created by John Sloan on 5/12/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <FISoundEngine.h>
#import "Attitude.h"

@interface ViewController : UIViewController  {
    FISound *snare;
    FISound *hihat;
    FISound *tom2;
    FISound *tom;
    FISound *kick;
    FISound *crash;
    int lowMagCounter;
    BOOL didAccelerate;
    Attitude *referenceFrame;
    Attitude *lastFrame;
    Attitude *attitudeRelativeToReferenceFrame;
    CMAttitude *oldRefFrame;
    CMAttitude *oldLastFrame;
    CMAcceleration lastAcceleration;
    NSMutableArray *xValuesArray;
    BOOL stopUpdatingXValues;
    int currentPosition;
    BOOL updateReferenceFrame;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSOperationQueue *deviceUpdateQueue;
@property (strong, nonatomic) NSMutableArray *dataWindow;

@end

