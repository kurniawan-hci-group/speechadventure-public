//
//  ForestGump.h
//  speechadventure
//
//  Created by Taylor Gotfrid on 8/2/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"

@interface ForestGump : SpeechAdventureLevel <CCPhysicsCollisionDelegate> {
    CCSprite *background1;
    CCSprite *background2;
    CCSprite *background3;
    CGSize size;
    CCSprite *car;
    CCSprite *cone;
    BOOL _collision;
    
}


// -----------------------------------------------------------------------

+ (ForestGump *)scene;


- (id)init;
-(void)scroll:(CCTime*)dt;


// -----------------------------------------------------------------------

@end

