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
    BOOL isVertical;
    BOOL exceededThreshold;
    double highestValue;
    FISound *sound;
    BOOL shouldCancel;
    BOOL currentlyPlaying;
    float *accelDataWindow;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSOperationQueue *deviceUpdateQueue;
@property (strong, nonatomic) NSMutableArray *dataWindow;

@end

