//
//  PlayView.m
//  Hits
//
//  Created by John Sloan on 5/30/15.
//  Copyright (c) 2015 JPGS inc. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSLog(@"init PlayView");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)updateWithCurSoundObject:(SoundObject*)sound
{
    //Takse SoundObject as input that contains icon and color. Then updates playview accordingly to show the sound.
    if (self.backgroundColor != sound.color) {
        NSLog(@"updating playview");
        self.backgroundColor = sound.color;
    }
}

@end
