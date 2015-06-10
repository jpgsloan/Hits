//
//  Attitude.m
//  Hits
//
//  Created by John Sloan on 6/9/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import "Attitude.h"

@implementation Attitude


- (id)initWithAttitude:(CMAttitude *)attitude {
    self = [super init];
    _roll = attitude.roll;
    _pitch = attitude.pitch;
    _yaw = attitude.yaw;
    _rotationMatrix = attitude.rotationMatrix;
    return self;
}

- (CMRotationMatrix)constructMatrixFromEuler {
    CMRotationMatrix matrix;
    matrix.m11 = cos(_roll) * cos(_yaw);
    matrix.m12 = (cos(_pitch) * cos(_yaw)) + (sin(_pitch) * sin(_roll) * cos(_yaw));
    matrix.m13 = (sin(_roll) * sin(_yaw)) - (cos(_pitch) * sin(_roll) * sin(_yaw));
    matrix.m21 = -cos(_roll) * sin(_yaw);
    matrix.m22 = (cos(_pitch) * cos(_yaw)) - (sin(_pitch) * sin(_roll) * sin(_yaw));
    matrix.m23 = (sin(_pitch) * cos(_yaw)) + (cos(_pitch) * sin(_roll) * sin(_yaw));
    matrix.m31 = sin(_roll);
    matrix.m32 = -sin(_pitch) * cos(_roll);
    matrix.m33 = cos(_pitch) * cos(_roll);
    return matrix;
}

- (void)deriveEulerFromMatrix {
    _roll = atan2(_rotationMatrix.m32, _rotationMatrix.m33);
    _pitch = atan2(-_rotationMatrix.m31, sqrt(pow(_rotationMatrix.m32,2) + pow(_rotationMatrix.m33, 2)));
    _yaw = atan2(_rotationMatrix.m21, _rotationMatrix.m11);
}

- (Attitude*)relativeAttitude:(CMAttitude*)curAttitude {
    //curAttitude: motion.attitude
    Attitude *relativeAttitude = [[Attitude alloc] init];
    CMRotationMatrix curMatrix = curAttitude.rotationMatrix;
    CMRotationMatrix correctedRotationMatrix;
    correctedRotationMatrix.m11 = (curMatrix.m11*_rotationMatrix.m11) + (curMatrix.m12*_rotationMatrix.m12) + (curMatrix.m13*_rotationMatrix.m13);
    correctedRotationMatrix.m12 = (curMatrix.m11*_rotationMatrix.m21) + (curMatrix.m12*_rotationMatrix.m22) + (curMatrix.m13*_rotationMatrix.m23);
    correctedRotationMatrix.m13 = (curMatrix.m11*_rotationMatrix.m31) + (curMatrix.m12*_rotationMatrix.m32) + (curMatrix.m13*_rotationMatrix.m33);
    
    correctedRotationMatrix.m21 = (curMatrix.m21*_rotationMatrix.m11) + (curMatrix.m22*_rotationMatrix.m12) + (curMatrix.m23*_rotationMatrix.m13);
    correctedRotationMatrix.m22 = (curMatrix.m21*_rotationMatrix.m21) + (curMatrix.m22*_rotationMatrix.m22) + (curMatrix.m23*_rotationMatrix.m23);
    correctedRotationMatrix.m23 = (curMatrix.m21*_rotationMatrix.m31) + (curMatrix.m22*_rotationMatrix.m32) + (curMatrix.m23*_rotationMatrix.m33);
    
    correctedRotationMatrix.m31 = (curMatrix.m31*_rotationMatrix.m11) + (curMatrix.m32*_rotationMatrix.m12) + (curMatrix.m33*_rotationMatrix.m13);
    correctedRotationMatrix.m31 = (curMatrix.m31*_rotationMatrix.m21) + (curMatrix.m32*_rotationMatrix.m22) + (curMatrix.m33*_rotationMatrix.m23);
    correctedRotationMatrix.m31 = (curMatrix.m31*_rotationMatrix.m31) + (curMatrix.m32*_rotationMatrix.m32) + (curMatrix.m33*_rotationMatrix.m33);
    
    relativeAttitude.rotationMatrix = correctedRotationMatrix;
    [relativeAttitude deriveEulerFromMatrix];
    
    return relativeAttitude;
}

- (CMAcceleration)correctedVectorForAttitude:(CMAcceleration)vector {
    CMAcceleration correctedVector;
    
    return correctedVector;
}







@end
