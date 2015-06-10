//
//  Attitude.h
//  Hits
//
//  Created by John Sloan on 6/9/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface Attitude : NSObject

- (id)initWithAttitude:(CMAttitude*)attitude;
- (CMRotationMatrix)constructMatrixFromEuler;
- (CMAcceleration)correctedVectorForAttitude:(CMAcceleration)vector;
- (Attitude*)relativeAttitude:(CMAttitude*)curAttitude;


@property (nonatomic) double roll;
@property (nonatomic) double pitch;
@property (nonatomic) double yaw;
@property (nonatomic,readwrite) CMRotationMatrix rotationMatrix;

@end
