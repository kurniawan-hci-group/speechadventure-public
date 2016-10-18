//
//  ViewPerformance.m
//  speechadventure
//
//  Created by Zak Rubin on 5/29/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "ViewPerformance.h"

@implementation ViewPerformance

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (ViewPerformance *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
    [self addChild:background];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Current Performance" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.9f); // Top Center
    [self addChild:label];
    
    [self showBackButton];
    [self addStatistics];
    [self addButtons];
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)addStatistics
{
    CCLabelTTF *label;
    
    // Build the statistics labels
    label = [CCLabelTTF labelWithString:@"Plosives: 85/100" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.05f, 0.7f);
    [self addChild:label];
    
    label = [CCLabelTTF labelWithString:@"Front Vowels: 10/100" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.05f, 0.6f);
    [self addChild:label];
    
    label = [CCLabelTTF labelWithString:@"Back Vowels: 4/100" fontName:@"ArialMT" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.05f, 0.5f);
    [self addChild:label];
    
}

- (void) addButtons
{
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(testLevel:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.8f, 0.72f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(testLevel:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.8f, 0.62f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [testLevelButton setTarget:self selector:@selector(testLevel:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.8f, 0.52f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.5f;
    [self addChild:testLevelButton];
    
}

@end
