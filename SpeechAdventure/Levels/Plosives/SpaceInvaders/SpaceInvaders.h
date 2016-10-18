//
//  SpaceInvaders.h
//  speechadventure
//
//  Created by Taylor Gotfrid on 7/14/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"

@interface SpaceInvaders : SpeechAdventureLevel <CCPhysicsCollisionDelegate> {
    CCSprite *spaceship;
    CCTexture *spaceshipImage;
    CCSprite *background;
    CCTexture *fireBlastImageFromSpaceShip;
    CCSprite *fireBlastFromSpaceShip;
    CCTexture *enemyShipImage;
    CCTexture *fireBlastImageFromEnemyShip;
    CCSprite *fireBlastFromEnemyShip;
    CCSprite *enemyShip;
    BOOL _gameOver;

    
}


// -----------------------------------------------------------------------

+ (SpaceInvaders *)scene;
- (id)init;

// -----------------------------------------------------------------------

@end
