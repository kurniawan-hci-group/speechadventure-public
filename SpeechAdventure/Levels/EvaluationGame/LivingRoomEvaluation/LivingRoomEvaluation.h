//
//  LivingRoomEvaluation.h
//  SpeechAdventure
//
//  Created by Zak Rubin on 5/10/15.
//
//

#import "SpeechAdventureLevel.h"

@interface LivingRoomEvaluation : SpeechAdventureLevel <CCPhysicsCollisionDelegate> {

}

- (id) init;

@property (nonatomic, strong) CCLabelTTF *sentenceLabel;
@property (nonatomic, strong) CCLabelTTF *highlightedWord;
@property (nonatomic, strong) NSDate *levelTime;
@property (nonatomic, strong) CCSprite *boots;
@property (nonatomic, strong) CCSprite *hat;
@property (nonatomic, strong) CCSprite *bootsGlow;
@property (nonatomic, strong) CCSprite *hatGlow;
@property (nonatomic, strong) CCSprite *sam;

@property(nonatomic,readwrite) BOOL bootsGlowUp;
@property(nonatomic,readwrite) BOOL hatGlowUp;

@end
