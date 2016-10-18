//
//  PopABalloon.h
//  SpeechAdventure
//
//  Created by John Chambers on 7/27/12.
//
//

#import <Foundation/Foundation.h>

#import <GameKit/GameKit.h>
#import "cocos2d.h"

#import "SpeechAdventureLevel.h"

@interface PopABalloonEvaluation : SpeechAdventureLevel <CCPhysicsCollisionDelegate>
    
- (id) init;

@property (nonatomic, strong) CCSprite *sam;
@property (nonatomic, strong) NSMutableArray *balloons;
@property (nonatomic, strong) NSMutableArray *balloonsGlow;
@property (nonatomic, strong) CCLabelTTF *sentenceLabel;
@property (nonatomic, strong) CCLabelTTF *highlightedWord;
@property (nonatomic, strong) NSDate *levelTime;






@end
