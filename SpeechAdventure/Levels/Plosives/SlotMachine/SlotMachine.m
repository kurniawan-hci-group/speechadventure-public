//
//  SlotMachine.m
//  speechadventure
//
//  Created by Zak Rubin on 4/15/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "SlotMachine.h"

@implementation SlotMachine
{
    CCSprite *slots[3];
    NSString *slotWord[3];
}

+ (SlotMachine *)scene
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
    [[OEManager sharedManager] swapModel:@"SlotMachine"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    [self intro];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    // Add UI elements
    [self showAllUIElements];
    
    // Start game timer
    [self setAndStartGameTimer:20];
    
    // Add a sprite
    CCButton *slotButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [slotButton setTarget:self selector:@selector(slotButtonPushed:)];
    slotButton.positionType = CCPositionTypeNormalized;
    slotButton.position = ccp(0.9f, 0.5f);
    [self addChild:slotButton];
    
    for(int i = 0; i<3; i++)
    {
        slots[i] = [CCSprite spriteWithImageNamed:@"boat.png"];
        [self addChild:slots[i]];
    }
    [self rollSlots];
}

- (void)highlightObject:(int) slotNumber
{
    [self removeChild:slots[slotNumber]];
    if ([slotWord[slotNumber] rangeOfString:@"BALL"].location != NSNotFound)
    {
        slots[slotNumber] = [CCSprite spriteWithImageNamed:@"ball_highlighted.png"];
    } else if ([slotWord[slotNumber] rangeOfString:@"BUNNY"].location != NSNotFound)
    {
        slots[slotNumber] = [CCSprite spriteWithImageNamed:@"bunny_highlighted.png"];
    } else if ([slotWord[slotNumber] rangeOfString:@"BOAT"].location != NSNotFound)
    {
        slots[slotNumber] = [CCSprite spriteWithImageNamed:@"boat_highlighted.png"];
    } else
    {
        
    }
    slots[slotNumber].positionType = CCPositionTypeNormalized;
    CGFloat x = 0.25*slotNumber+0.15f;
    slots[slotNumber].position  = ccp(x,0.5f);
    [self addChild:slots[slotNumber]];
}

- (void)rollSlots
{
    int randomResult;
    for(int i = 0; i<3; i++)
    {
        [self removeChild:slots[i]];
        randomResult = random()%3;
        switch (randomResult)
        {
            case 0:
                slots[i] = [CCSprite spriteWithImageNamed:@"ball.png"];
                slotWord[i] = [NSString stringWithFormat:@"BALL"];
                break;
            case 1:
                slots[i] = [CCSprite spriteWithImageNamed:@"bunny.png"];
                slotWord[i] = [NSString stringWithFormat:@"BUNNY"];
                break;
            case 2:
                slots[i] = [CCSprite spriteWithImageNamed:@"boat.png"];
                slotWord[i] = [NSString stringWithFormat:@"BOAT"];
                break;
        }
        slots[i].positionType = CCPositionTypeNormalized;
        CGFloat x = 0.25*i+0.15f;
        slots[i].position  = ccp(x,0.5f);
        [self addChild:slots[i]];
    }
    slotWord[1] = [NSString stringWithFormat:@"%@ %@", slotWord[0], slotWord[1]];
    slotWord[2] = [NSString stringWithFormat:@"%@ %@", slotWord[1], slotWord[2]];
}

-(void) timeUp:(CCTime)dt{
    [[OEManager sharedManager] pauseListening];
    [[OEManager sharedManager] recordingCutoff];
    [self changeLevel];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    if(speechEvent.eventType == OpenEarsResponse) {
        if (([speechEvent.text rangeOfString:slotWord[0]].location != NSNotFound))
        {
            [self highlightObject:0];
        }
        if (([speechEvent.text rangeOfString:slotWord[1]].location != NSNotFound))
        {
            [self highlightObject:1];
        }
        if (([speechEvent.text rangeOfString:slotWord[2]].location != NSNotFound))
        {
            [self highlightObject:2];
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

- (void)slotButtonPushed:(id)sender
{
    [self rollSlots];
}


// -----------------------------------------------------------------------

@end
