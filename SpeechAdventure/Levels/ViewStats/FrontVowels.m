//
//  FrontVowels.m
//  speechadventure
//
//  Created by Michael Weber on 8/1/2014.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"
#import "FrontVowels.h"
#import "BackVowels.h" 
#import "HP.h"

@implementation FrontVowels

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (FrontVowels *)scene
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
    CCSprite *base = [CCSprite spriteWithImageNamed:@"Vowels.png"];
    base.positionType = CCPositionTypeNormalized;
    base.position  = ccp(0.5f, 0.5f);
    [self addChild:base];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Front Vowels" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.9f); // Top Center
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
    label = [CCLabelTTF labelWithString:@"/1/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.84f, 0.80f);
    [self addChild:label];
    //label 2
    label = [CCLabelTTF labelWithString:@"/2/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(00.84f, 0.63f);
    [self addChild:label];
    //label 3
    label = [CCLabelTTF labelWithString:@"/3/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.84f, 0.46f);
    [self addChild:label];
    //label 4
    label = [CCLabelTTF labelWithString:@"/4/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.84f, 0.27f);
    [self addChild:label];
    //lable 5
    label = [CCLabelTTF labelWithString:@"/5/" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.84f, 0.08f);
    [self addChild:label];
}

- (void) addButtons
{
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.74f, 0.82f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 2    
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.74f, 0.65f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 3
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.74f, 0.48f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 4
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.74f, 0.29f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 5
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    //[testLevelButton setTarget:self selector:@selector(StatsGraph:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.74f, 0.10f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
 }

- (void) addToggleButtons
{
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(BackVowels:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.1f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    //Button 2
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(HighP:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.2f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
}

- (void) addToggleButtonsLables
{
    CCLabelTTF *label;
    
    //label 1
    label = [CCLabelTTF labelWithString:@"Back" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.11f, 0.06f);
    [self addChild:label];
    
    //label 2
    label = [CCLabelTTF labelWithString:@"HPC" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.215f, 0.06f);
    [self addChild:label];
}

-(void) testLevel:(id)sender {
    
}

-(void) BackVowels:(id)sender {
	// start spinning scene with transition
    //[self hideBackButton];
    [[CCDirector sharedDirector] replaceScene:[BackVowels scene]];
}
-(void) HighP:(id)sender {
	// start spinning scene with transition
    //[self hideBackButton];
    [[CCDirector sharedDirector] replaceScene:[HP scene]];
}


// -----------------------------------------------------------------------

@end
