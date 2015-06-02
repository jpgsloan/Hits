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

@interface ViewController : UIViewController {
    FISound *snare;
    FISound *hihat;
    FISound *ride;
    FISound *tom;
    FISound *kick;
    FISound *crash;
    int lowMagCounter;
    BOOL didAccelerate;
    CMAttitude *referenceFrame;
    CMAttitude *lastFrame;
    CMAcceleration lastAcceleration;
    NSMutableArray *xValuesArray;
    BOOL stopUpdatingXValues;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSOperationQueue *deviceUpdateQueue;
@property (strong, nonatomic) NSMutableArray *dataWindow;
@property (strong, nonatomic) NSMutableArray *sounds;

@end

