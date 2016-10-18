//
//  FlappySlug.h
//  speechadventure
//
//  Created by Zak Rubin on 10/23/14.
//  Copyright 2014 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"

@interface FlappySlug : SpeechAdventureLevel <CCPhysicsCollisionDelegate> {
    
}

+ (SpeechAdventureLevel *)scene;
- (id)init;

@end
