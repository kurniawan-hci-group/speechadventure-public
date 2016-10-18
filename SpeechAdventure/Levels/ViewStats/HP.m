//
//  HP.m
//  speechadventure
//
//  Created by Michael Weber on 8/1/2014.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"
#import "FrontVowels.h"
#import "BackVowels.h"
#import "HP.h"
#import "StatsGraph.h"

@implementation HP

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HP *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    //BASE LAYER
    CCSprite *base = [CCSprite spriteWithImageNamed:@"HighPreasureConsanants.png"];
    base.positionType = CCPositionTypeNormalized;
    base.position  = ccp(0.5f, 0.5f);
    [self addChild:base];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"High Pressure Consonant Scores" fontName:@"ArialMT" fontSize:22.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.6f, 0.1f); // Top Center
    [self addChild:label];
    [self showBackButton];
    [self addLables];
    [self addButtons];
    [self addToggleButtons];
    [self addToggleButtonsLables];
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)addLables
{
    CCLabelTTF *label;
    
    // Build the statistics labels
    //label 1
    label = [CCLabelTTF labelWithString:@"/ʃ, tʃ, dʒ/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.7f, 0.780f);
    [self addChild:label];
    //label 2
    label = [CCLabelTTF labelWithString:@"/k,g/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.78f, 0.60f);
    [self addChild:label];
    //label 3
    label = [CCLabelTTF labelWithString:@"/h/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.7f, 0.16f);
    [self addChild:label];
    //label 4
    label = [CCLabelTTF labelWithString:@"/θ/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.25f, 0.16f);
    [self addChild:label];
    //lable 5
    label = [CCLabelTTF labelWithString:@"/f,v/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.1f, 0.375f);
    [self addChild:label];
    //lable 6
    label = [CCLabelTTF labelWithString:@"/p,b/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.1f, 0.680f);
    [self addChild:label];
    //lable 7
    label = [CCLabelTTF labelWithString:@"/t,d,s,z/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.41f, 0.83f);
    [self addChild:label];
}


- (void) addButtons
{
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"1" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(statsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.58f, 0.72f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 2
    testLevelButton = [CCButton buttonWithTitle:@"2" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.66f, 0.62f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 3
    testLevelButton = [CCButton buttonWithTitle:@"3" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.68f, 0.30f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 4
    testLevelButton = [CCButton buttonWithTitle:@"4" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.26f, 0.30f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 5
    testLevelButton = [CCButton buttonWithTitle:@"5" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.14f, 0.30f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 6
    testLevelButton = [CCButton buttonWithTitle:@"6" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.18f, 0.60f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 7
    testLevelButton = [CCButton buttonWithTitle:@"7" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.44f, 0.75f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
}
- (void) addToggleButtons
{
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(FrontVowels:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.00f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 2
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(BackVowels:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.12f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
}

- (void) addToggleButtonsLables
{
    CCLabelTTF *label;
    
    //label 1
    label = [CCLabelTTF labelWithString:@"Front" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.01f, 0.06f);
    [self addChild:label];
    
    //label 2
    label = [CCLabelTTF labelWithString:@"Back" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.13f, 0.06f);
    [self addChild:label];
}


-(void) testLevel:(id)sender {
    
}

-(void) statsGraph:(id)sender {
    [[CCDirector sharedDirector] pushScene:[StatsGraph scene]];
}

-(void) BackVowels:(id)sender {
	// start spinning scene with transition
    //[self hideBackButton];
    [[CCDirector sharedDirector] replaceScene:[BackVowels scene]];
}
-(void) FrontVowels:(id)sender {
	// start spinning scene with transition
    //[self hideBackButton];
    [[CCDirector sharedDirector] replaceScene:[FrontVowels scene]];
}


// -----------------------------------------------------------------------

@end
