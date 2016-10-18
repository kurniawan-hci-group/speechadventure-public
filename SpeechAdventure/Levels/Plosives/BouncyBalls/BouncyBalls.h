//
//  BouncyBalls.h
//  speechadventure
//
//  Created by Steven Cruz on 3/14/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"

@interface BouncyBalls : SpeechAdventureLevel <CCPhysicsCollisionDelegate> {
    
}

-(void)killVelocity:(NSTimeInterval) dt;

// -----------------------------------------------------------------------

+ (BouncyBalls *)scene;

@property(nonatomic,readwrite) BOOL ballZero;
@property(nonatomic,readwrite) BOOL ballOne;
@property(nonatomic,readwrite) BOOL ballTwo;
- (id)init;

// -----------------------------------------------------------------------

@end
