//
//  ViewController.h
//  Hits
//
//  Created by John Sloan on 5/12/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController {
    BOOL isVertical;
    BOOL exceededThreshold;
    NSMutableArray *accelDataWindow;
    double highestValue;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSOperationQueue *deviceUpdateQueue;

@end

