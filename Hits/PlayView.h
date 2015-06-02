//
//  PlayView.h
//  Hits
//
//  Created by John Sloan on 5/30/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundObject.h"

@interface PlayView : UIView

- (void)updateWithCurSoundObject:(SoundObject*)sound;

@end
