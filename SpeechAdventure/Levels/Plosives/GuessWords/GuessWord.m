//  GuessWord.m
//  speechadventure
//
//  Created by Steven Cruz on 5/3/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "GuessWord.h"

@implementation GuessWord
{
    CCSprite *image[6];
    int next_num;
    CCSprite *line;
    CCSprite *boo[6];
    CCSprite *tweet[6];
    CCSprite *roar[6];
    CCSprite *bird[6];
    CCSprite *lion[6];
    CCSprite *oink[6];
    CCSprite *woof[6];
}

+ (GuessWord *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"guessWord"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    // Create a colored background
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    //add sprites
    line = [CCSprite spriteWithImageNamed:@"line.png"];
    image[0] = [CCSprite spriteWithImageNamed:@"ghost.png"];
    image[1] = [CCSprite spriteWithImageNamed:@"bird.png"];
    image[2] = [CCSprite spriteWithImageNamed:@"lion.png"];
    image[3] = [CCSprite spriteWithImageNamed:@"pig.png"];
    image[4] = [CCSprite spriteWithImageNamed:@"dog.png"];
    
    //sprites for the words for each animal
    //Ghost
    boo[0] = [CCSprite spriteWithImageNamed:@"b.png"];
    boo[1] = [CCSprite spriteWithImageNamed:@"line.png"];
    boo[2] = [CCSprite spriteWithImageNamed:@"o.png"];
    boo[3] = [CCSprite spriteWithImageNamed:@"o.png"];
    boo[0].position = ccp(0.3,0.25);
    boo[1].position = ccp(0.5,0.20);
    boo[2].position = ccp(0.7,0.25);
    boo[3].position = ccp(0.5,0.25);
    boo[0].scale = 0.4f;
    boo[0].scale = 0.4f;
    boo[1].scale = 0.4f;
    boo[3].scale = 0.4f;
    
    
    //birdie
    tweet[0] = [CCSprite spriteWithImageNamed:@"t.png"];
    tweet[1] = [CCSprite spriteWithImageNamed:@"w.png"];
    tweet[2] = [CCSprite spriteWithImageNamed:@"line.png"];
    tweet[3] = [CCSprite spriteWithImageNamed:@"line.png"];
    tweet[4] = [CCSprite spriteWithImageNamed:@"e.png"];
    tweet[5] = [CCSprite spriteWithImageNamed:@"t.png"];
    tweet[0].position = ccp(0.13,0.25);
    tweet[1].position = ccp(0.3,0.25);
    tweet[2].position = ccp(0.45,0.25);
    tweet[3].position = ccp(0.6,0.25);
    tweet[4].position = ccp(0.75,0.25);
    tweet[5].position = ccp(0.9,0.25);
    
    //male version of lioness
    roar[0] = [CCSprite spriteWithImageNamed:@"r.png"];
    roar[1] = [CCSprite spriteWithImageNamed:@"o.png"];
    roar[2] = [CCSprite spriteWithImageNamed:@"line.png"];
    roar[3] = [CCSprite spriteWithImageNamed:@"r.png"];
    roar[0].position = ccp(0.2,0.25);
    roar[1].position = ccp(0.4,0.25);
    roar[2].position = ccp(0.6,0.25);
    roar[3].position = ccp(0.8,0.25);
    
    //piggie
    oink[0] = [CCSprite spriteWithImageNamed:@"o.png"];
    oink[1] = [CCSprite spriteWithImageNamed:@"line.png"];
    oink[2] = [CCSprite spriteWithImageNamed:@"n.png"];
    oink[3] = [CCSprite spriteWithImageNamed:@"k.png"];
    
    oink[0].position = ccp(0.2,0.25);
    oink[1].position = ccp(0.4,0.25);
    oink[2].position = ccp(0.6,0.25);
    oink[3].position = ccp(0.8,0.25);
    
    //bark bark
    woof[0] = [CCSprite spriteWithImageNamed:@"w.png"];
    woof[1] = [CCSprite spriteWithImageNamed:@"o.png"];
    woof[2] = [CCSprite spriteWithImageNamed:@"line.png"];
    woof[3] = [CCSprite spriteWithImageNamed:@"f.png"];
    
    woof[0].position = ccp(0.2,0.25);
    woof[1].position = ccp(0.4,0.25);
    woof[2].position = ccp(0.6,0.25);
    woof[3].position = ccp(0.8,0.25);


    //manual resizing of sprites
    image[0].scale = 0.65f;
    image[1].scale = 0.25f;
    image[2].scale = 0.45f;
    image[3].scale = 0.3f;
    image[4].scale = 0.25f;
    for (int i = 0; i < 6; i++) {
        boo[i].positionType = CCPositionTypeNormalized;
        tweet[i].positionType = CCPositionTypeNormalized;
        roar[i].positionType = CCPositionTypeNormalized;
        oink[i].positionType = CCPositionTypeNormalized;
        woof[i].positionType = CCPositionTypeNormalized;
        boo[i].positionType = CCPositionTypeNormalized;
        image[i].positionType = CCPositionTypeNormalized;
        boo[i].scale = 0.4;
        tweet[i].scale = 0.4;
        roar[i].scale = 0.4;
        oink[i].scale = 0.4;
        woof[i].scale = 0.4;
        image[i].position = ccp(0.5,0.75);
    }
    
    [self intro];
    
    // done
    return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    [self showAllUIElements];
    [self setAndStartGameTimer:20];
    
    //start off with ghost and move down the list
    next_num = 0;
    
    [self displayWord];
}

-(void) displayWord {
    CCActionFadeIn *fadeI = [CCActionFadeIn actionWithDuration:3.0];
    //ghost
    if (next_num == 0) {
        [self addChild:image[0]];
        for (int i = 0; i < 3; i++) {
            [self addChild:boo[i]];
        }
    }
    //bird
    else if (next_num == 1) {
        [self addChild:image[1]];
        [image[1] runAction:fadeI];
        for (int i = 0; i < 6; i++) {
            [self addChild:tweet[i]];
        }
        for (int i = 0; i < 6; i++) {
            [tweet[i] runAction:[fadeI copy]];
        }
        
    }
    //lion
    else if (next_num == 2) {
        [self addChild:image[2]];
        [image[2] runAction:fadeI];
        for (int i = 0; i < 4; i++) {
            [self addChild:roar[i]];
        }
        for (int i = 0; i < 4; i++) {
            [roar[i] runAction:[fadeI copy]];
        }
        
    }
    //pig
    else if (next_num == 3) {
        [self addChild:image[3]];
        [image[3] runAction:fadeI];
        for (int i = 0; i < 4; i++) {
            [self addChild:oink[i]];
        }
        for (int i = 0; i < 4; i++) {
            [oink[i] runAction:[fadeI copy]];
        }
        
    }
    //dog
    else if (next_num == 4) {
        [self addChild:image[4]];
        [image[4] runAction:fadeI];
        for (int i = 0; i < 4; i++) {
            [self addChild:woof[i]];
        }
        for (int i = 0; i < 4; i++) {
            [woof[i] runAction:[fadeI copy]];
        }
    }
}

- (void) booFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:3.0];
    [image[0] runAction:fadeO];
    for (int i = 0; i < 4; i++) {
        [boo[i] runAction:[fadeO copy]];
    }
    CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < 4; i++) {
            [boo[i] removeFromParentAndCleanup:YES];
        }
    }];
    [boo[1] removeFromParentAndCleanup:YES];
    for (int i = 0; i < 5; i++) {
        [boo[i] runAction:rmAct];
    }
    next_num = 1;
    [self displayWord];
}

- (void) birdFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:3.0];
    [image[1] runAction:fadeO];
    for (int i = 0; i < 6; i++) {
        [tweet[i] runAction:[fadeO copy]];
    }
    CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < 6; i++) {
            [tweet[i] removeFromParentAndCleanup:YES];
        }
    }];
    [image[1] removeFromParentAndCleanup:YES];
    for (int i = 0; i < 5; i++) {
        [tweet[i] runAction:rmAct];
    }
    next_num = 2;
    [self displayWord];
}

- (void) lionFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:1.5];
    [image[2] runAction:fadeO];
    for (int i = 0; i < 4; i++) {
        [roar[i] runAction:[fadeO copy]];
    }
    CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < 4; i++) {
        [roar[i] removeFromParentAndCleanup:YES];
        }
    }];
    [image[2] removeFromParentAndCleanup:YES];
    for (int i = 0; i < 4; i++) {
        [roar[i] runAction:rmAct];
    }
    next_num = 3;
    [self displayWord];
}

- (void) pigFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:1.5];
    [image[3] runAction:fadeO];
    for (int i = 0; i < 4; i++) {
        [oink[i] runAction:[fadeO copy]];
    }
    CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < 4; i++) {
            [oink[i] removeFromParentAndCleanup:YES];
        }
    }];
    [image[3] removeFromParentAndCleanup:YES];
    for (int i = 0; i < 4; i++) {
        [oink[i] runAction:rmAct];
    }
    next_num = 4;
    [self displayWord];
}

- (void) dogFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:1.5];
    [image[4] runAction:fadeO];
    for (int i = 0; i < 4; i++) {
        [woof[i] runAction:[fadeO copy]];
    }
    CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
        for (int i = 0; i < 4; i++) {
            [woof[i] removeFromParentAndCleanup:YES];
        }
    }];
    [image[4] removeFromParentAndCleanup:YES];
    for (int i = 0; i < 4; i++) {
        [woof[i] runAction:rmAct];
    }
    next_num = 0;
    [self displayWord];
}

//- (void) displayMissing {
//    CCActionFadeIn *fadeI = [CCActionFadeIn actionWithDuration:3.0];
//    if (next_num == 0) {
//        [self addChild:boo[3]];
//        [boo[3] runAction:fadeI];
//    }
//}


// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    //[self.currentSentenceStats addUtterance:speechEvent.text];
    if(speechEvent.eventType == OpenEarsResponse) {
        if (([speechEvent.text rangeOfString:@"BOO"].location != NSNotFound && next_num == 0)) {
            //[self displayMissing];
            [self booFade];
        } else if (([speechEvent.text rangeOfString:@"TWEET"].location != NSNotFound && next_num == 1)) {
            [self birdFade];
        }
        } else if ((([speechEvent.text rangeOfString:@"ROAR"].location != NSNotFound || [speechEvent.text rangeOfString:@"OAR"].location != NSNotFound) && next_num == 2)) {
            [self lionFade];
        } else if (([speechEvent.text rangeOfString:@"OINK"].location != NSNotFound && next_num == 3)) {
            [self pigFade];
        }
          else if (([speechEvent.text rangeOfString:@"WOOF"].location != NSNotFound && next_num == 4)) {
            [self dogFade];
        }
    }

@end
