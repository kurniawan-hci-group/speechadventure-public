//
//  GuessPic.m
//  speechadventure
//
//  Created by Steven Cruz on 6/1/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "GuessPic.h"

@implementation GuessPic {
    CCSprite *key;
    CCSprite *moon;
    CCSprite *snail;
    CCSprite *teddy;
    CCSprite *zak;
    int pic_num;
}

+ (GuessPic *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    if (self=[super init]) {
        // SETUP RECOGNITION
        [[OEManager sharedManager] swapModel:@"guessPic"];
        [[OEManager sharedManager] startListening];
        [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:TRUE];
    
        // Enable touch handling on scene node for testing
        self.userInteractionEnabled = YES;
        
        // Create a green background
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f]];
        [self.backgroundLayer addChild:background];
        
        //add sprites
        key = [CCSprite spriteWithImageNamed:@"key.png"];
        moon = [CCSprite spriteWithImageNamed:@"moon.png"];
        snail = [CCSprite spriteWithImageNamed:@"snail.png"];
        teddy = [CCSprite spriteWithImageNamed:@"teddy.png"];
        zak = [CCSprite spriteWithImageNamed:@"zak.png"];
        
        //reposition the sprites
        key.scale = 0.75f;
        key.position = ccp(275.0,160.0);
        moon.scale = 0.50f;
        moon.position = ccp(275.0,160.0);
        snail.scale = 0.50f;
        snail.position = ccp(275.0,160.0);
        teddy.scale = 0.5f;
        teddy.position = ccp(275.0, 160.0);
        zak.position = ccp(285.0,160.0);
        
        
        }
        [self intro];
    // done
    return self;
}

- (void)intro
{
    [self showAllUIElements];
    [self setAndStartGameTimer:20];
    pic_num = 0;
    //[self displayPic];
    
}

-(void)displayPic {
    CCActionFadeIn *fadeI = [CCActionFadeIn actionWithDuration:2.5];
    if (pic_num == 0) {
        [self addChild:key];
        [key runAction:fadeI];
    }
    else if (pic_num == 1) {
        [self addChild:moon];
        [moon runAction:fadeI];
    }
    else if (pic_num == 2) {
        [self addChild:snail];
        [snail runAction:fadeI];
    }
    else if (pic_num == 3) {
        [self addChild:teddy];
        [teddy runAction:fadeI];
    }
    else if (pic_num == 4) {
        [self addChild:zak];
        [zak runAction:fadeI];
    }
}

-(void)keyFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:2.5];
    if (pic_num == 0) {
        [key runAction:fadeO];
        CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
            [key removeFromParentAndCleanup:YES];
        }];
        [key runAction:rmAct];
        pic_num = 1;
        [self displayPic];
    }
}

-(void)moonFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:2.5];
    if (pic_num == 1) {
        [moon runAction:fadeO];
        CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
            [moon removeFromParentAndCleanup:YES];
        }];
        [moon runAction:rmAct];
        pic_num = 2;
        [self displayPic];
    }
}

-(void)snailFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:2.5];
    if (pic_num == 2) {
        [snail runAction:fadeO];
        CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
            [snail removeFromParentAndCleanup:YES];
        }];
        [snail runAction:rmAct];
        pic_num = 3;
        [self displayPic];
    }
}

-(void)tedFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:2.5];
    if (pic_num == 3) {
        [teddy runAction:fadeO];
        CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
            [teddy removeFromParentAndCleanup:YES];
        }];
        [teddy runAction:rmAct];
        pic_num = 4;
        [self displayPic];
    }
}

-(void)zFade {
    CCActionFadeOut *fadeO = [CCActionFadeOut actionWithDuration:2.5];
    if (pic_num == 4) {
        [zak runAction:fadeO];
        CCActionCallBlock *rmAct = [CCActionCallBlock actionWithBlock:^{
            [zak removeFromParentAndCleanup:YES];
        }];
        [zak runAction:rmAct];
        pic_num = 0;
        [self displayPic];
    }
}




// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent{
    //NSLog(@"GuessPic received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    //[self.currentSentenceStats addUtterance:speechEvent.text];
    if(speechEvent.eventType == OpenEarsResponse) {
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound && pic_num == 0)) {
            [self keyFade];
        }
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound && pic_num == 1)) {
            [self moonFade];
        }
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound && pic_num == 2)) {
            [self snailFade];
        }
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound && pic_num == 3)) {
            [self tedFade];
        }
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound && pic_num == 4)) {
            [self zFade];
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

//just for testing
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];

    if (CGRectContainsPoint(key.boundingBox, touchLoc)) {
        [self keyFade];
    }
    if (CGRectContainsPoint(moon.boundingBox, touchLoc)) {
        [self moonFade];
    }
    if (CGRectContainsPoint(snail.boundingBox, touchLoc)) {
        [self snailFade];
    }
    if (CGRectContainsPoint(teddy.boundingBox, touchLoc)) {
        [self tedFade];
    }
//    if (CGRectContainsPoint(zak.boundingBox, touchLoc)) {
//        [self zFade];
//    }

}


@end
