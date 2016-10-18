//
//  MainMenu.m
//  speechadventure
//
//  Created by Zak Rubin on 4/24/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "MainMenu.h"
#import "TransitionScene.h"
#import "FrontVowels.h"
#import "ViewPerformance.h"
#import "StatsGraph.h"
#import "PopABalloonEvaluation.h"
#import "LivingRoomEvaluation.h"
#import "InstructionEvaluation.h"

@implementation MainMenu

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MainMenu *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(id) init {
    if( (self=[super init])) {
        [self addBackgroundAndTitle];
        
        [self addMenuButtons];
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            NSLog(@"permission : %d", granted);
            if(!granted) [self addRecordRequestButton];
        }];
        //[[AVAudioSession sharedInstance] requestRecordPermission:nil];
    }
    return self;
}

-(void) addMenuButtons
{
    CCButton *startGameButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [startGameButton setTarget:self selector:@selector(startGame:)];
    startGameButton.positionType = CCPositionTypeNormalized;
    startGameButton.position = ccp(0.5f, 0.7f);
    [self addChild:startGameButton];
    CCButton *tutorialButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [tutorialButton setTarget:self selector:@selector(startTutorial:)];
    tutorialButton.positionType = CCPositionTypeNormalized;
    tutorialButton.position = ccp(0.5f, 0.5f);
    [self addChild:tutorialButton];
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(testLevel:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.5f, 0.3f);
    [self addChild:testLevelButton];
    CCButton *viewStatsButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [viewStatsButton setTarget:self selector:@selector(viewStats:)];
    viewStatsButton.positionType = CCPositionTypeNormalized;
    viewStatsButton.position = ccp(0.5f, 0.1f);
    [self addChild:viewStatsButton];
    
    CCLabelTTF *sentenceLabel = [CCLabelTTF labelWithString:@"Start Game" fontName:@"ArialMT" fontSize:48.0];
    sentenceLabel.color = [CCColor colorWithRed:0 green:0 blue:0];
    sentenceLabel.positionType = CCPositionTypeNormalized;
    sentenceLabel.position = ccp(0.5f, 0.7f);
    [self addChild: sentenceLabel];
    sentenceLabel = [CCLabelTTF labelWithString:@"Storybook" fontName:@"ArialMT" fontSize:48.0];
    sentenceLabel.color = [CCColor colorWithRed:0 green:0 blue:0];
    sentenceLabel.positionType = CCPositionTypeNormalized;
    sentenceLabel.position = ccp(0.5f, 0.5f);
    [self addChild: sentenceLabel];
    sentenceLabel = [CCLabelTTF labelWithString:@"Help" fontName:@"ArialMT" fontSize:48.0];
    sentenceLabel.color = [CCColor colorWithRed:0 green:0 blue:0];
    sentenceLabel.positionType = CCPositionTypeNormalized;
    sentenceLabel.position = ccp(0.5f, 0.3f);
    [self addChild: sentenceLabel];
    sentenceLabel = [CCLabelTTF labelWithString:@"View Stats" fontName:@"ArialMT" fontSize:48.0];
    sentenceLabel.color = [CCColor colorWithRed:0 green:0 blue:0];
    sentenceLabel.positionType = CCPositionTypeNormalized;
    sentenceLabel.position = ccp(0.5f, 0.1f);
    [self addChild: sentenceLabel];
}

-(void) addBackgroundAndTitle {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGSize scaleFactor = CGSizeMake(winSize.width / 480, winSize.height / 320);
    
    CCSprite *base = [CCSprite spriteWithImageNamed:@"MainMenu_Background.png"];
    base.positionType = CCPositionTypeNormalized;
    base.position  = ccp(0.5f, 0.5f);
    base.scaleX = scaleFactor.width;
    base.scaleY = scaleFactor.height;
    [self addChild:base];
    
    CCSprite * mainTitle = [CCSprite spriteWithImageNamed:@"Speechwithsamflat.png"];
    mainTitle.positionType = CCPositionTypeNormalized;
    //mainTitle.color = [CCColor blackColor];
    mainTitle.position = ccp(0.5f, 0.9f);
    [self addChild: mainTitle];
}

-(void) addRecordRequestButton {
    [self addBackgroundAndTitle];
    CCButton *startGameButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [startGameButton setTarget:self selector:@selector(requestRecordPermission:)];
    startGameButton.positionType = CCPositionTypeNormalized;
    startGameButton.position = ccp(0.5f, 0.7f);
    [self addChild:startGameButton];
    
    CCLabelTTF *sentenceLabel = [CCLabelTTF labelWithString:@"Start Game" fontName:@"ArialMT" fontSize:42.0];
    sentenceLabel.color = [CCColor colorWithRed:0 green:0 blue:0];
    sentenceLabel.positionType = CCPositionTypeNormalized;
    sentenceLabel.position = ccp(0.5f, 0.7f);
    [self addChild: sentenceLabel];
}

// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

-(void) startGame:(id)sender
{
    
    [[StatManager sharedManager] startNewSessionStats];
    [[CCDirector sharedDirector] pushScene:[TransitionScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}


-(void) startTutorial:(id)sender
{
    [[StatManager sharedManager] startNewSessionStats];
    //[[StatManager sharedManager] updateTimeAndLevelsForThisSession];
    [[CCDirector sharedDirector] pushScene:[LivingRoomEvaluation scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

-(void) testLevel:(id)sender
{
    [[CCDirector sharedDirector] pushScene:[InstructionEvaluation scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

-(void) viewStats:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] pushScene:[StatsGraph scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

-(void) requestRecordPermission:(id)sender {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        NSLog(@"permission : %d", granted);
        if(!granted) {
            [self addRecordRequestButton];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mic Access Needed"
                                                             message:@"Please go to Settings->Privacy->Microphone and Swipe right on Speech with Sam"
                                                            delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
            [alert show];
            [self removeChild: alert];
        }
        else [self addMenuButtons];
    }];
}


// -----------------------------------------------------------------------


@end
