//
//  SoundObject.h
//  Hits
//
//  Created by John Sloan on 5/30/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FISoundEngine.h>

@interface SoundObject : NSObject

@property (strong,nonatomic) UIColor *color;
@property (strong,nonatomic) FISound *sound;

@end
