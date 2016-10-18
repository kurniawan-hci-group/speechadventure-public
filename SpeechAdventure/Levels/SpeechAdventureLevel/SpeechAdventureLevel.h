//
//  SpeechAdventureLevel.h
//  speechadventure
//  This provides 
//  Created by Zak Rubin on 4/10/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "CCScene.h"
#import "CCAnimation.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "OEDelegate.h"
#import "OEManager.h"
#import "OEEvent.h"
#import "StatManager.h"
#import <UIKit/UIKit.h>
@import SpriteKit;

@interface SpeechAdventureLevel : CCScene<OEDelegate>

@property (nonatomic, strong) CCNode *backgroundLayer;
@property (nonatomic, strong) CCNode *baseStageLayer;
@property (nonatomic, strong) CCNode *activityLayer;
@property (nonatomic, strong) CCNode *foregroundLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *uiUpdateTimer;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) CCLabelTTF *audioLevelLabel;
@property (nonatomic, strong) CCButton *listeningIcon;
@property (nonatomic, strong) CCButton *backButton;
@property (nonatomic, strong) CCButton *gameTimerButton;
@property (nonatomic, strong) CCButton *scoreButton;
@property (nonatomic, strong) CCButton *phraseBox;
@property (nonatomic, strong) CCLabelTTF *scoreLabel;
@property (nonatomic, strong) CCLabelTTF *gameTimerLabel;
@property (nonatomic, strong) CCLabelTTF *sentenceLabel;
@property (nonatomic, strong) CCLabelTTF *highlightedWordsLabel;
@property (nonatomic, strong) CCSprite *checkmark;
@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, strong) NSString *levelName;
@property (nonatomic, strong) NSString *levelDescription;
@property (nonatomic, strong) NSString *targetSentence;
@property (nonatomic, strong) NSString *targetWords;
@property (nonatomic, strong) NSString *targetSyllables;
@property (nonatomic, strong) NSString *previousValidSpeech;
@property (nonatomic, strong) NSNumber *levelTimeLimit;
@property (nonatomic, strong) NSNumber *currentScore;
@property (nonatomic) bool listeningIconIsVisible;
@property (nonatomic) bool backButtonIsVisible;
@property (nonatomic) bool scoreButtonIsVisible;
@property (nonatomic) bool gameTimerIsVisible;
@property (nonatomic) bool phraseBoxIsVisible;
@property (nonatomic) bool statisticsBeingCollected;
@property (nonatomic) int gameTimeLeft;
@property (nonatomic) int currentSessionID;
@property (nonatomic) int currentLevelID;
@property (nonatomic) int currentSentenceID;
@property (nonatomic) CGSize deviceScaleFactor;

- (id) init;

// OpenEars
- (void) receiveOEEvent:(OEEvent*) speechEvent;
- (void) receiveOEState:(OEEvent*) stateEvent;
- (void) shouldReturnPartials:(BOOL)returnPartials;
- (BOOL) checkIfPhraseExists:(NSString *) phrase currentHypothesis:(NSString*) currentHypothesis;
- (NSString *) checkForPhraseParts:(NSString *) phrase currentHypothesis:(NSString*) currentHypothesis;
- (void) updatePreviousValidSpeech:(NSString*)speechResult;
- (NSString *) truncateFromPreviousValidSpeech:(NSString *)speechResult;
- (void) pauseListeningAndPlaySound:(NSURL*) file;
- (void) playSound:(NSURL*) file;
- (void) waitForModelsToLoad;

// UI and HUD
- (void) showAllUIElements;
- (void) hideAllUIElements;
- (void) setScaleFactorForSprite:(CCSprite*) theSprite;
- (void) setScaleFactorForScene;
- (void) startDisplayingLevels;
- (void) stopDisplayingLevels;
- (void) showListeningEar;
- (void) hideListeningEar;
- (void) showBackButton;
- (void) hideBackButton;
- (void) changeLevel;
- (void) returnToMainMenu;
- (void) changeToLevel:(NSString *) nextLevelName;

// Phrase box and UI
- (void) showPhraseBox;
- (void) hidePhraseBox;
- (void) setSentenceInPhraseBox:(NSString *) text;
- (void) setHighlightedWordsInPhraseBox:(NSString*)highlightedWords;
- (void) highlightPhraseParts:(NSString*)phraseParts;
- (void) showCheckmark;

// Game timer and UI
- (void) showGameTimer;
- (void) hideGameTimer;
- (void) updateGameTimer:(NSTimer *)theTimer;
- (void) setAndStartGameTimer:(int)gameTime;

// Scorekeeping and Score UI
- (void) showScore;
- (void) hideScore;
- (void) setScore:(NSNumber *) score;
- (void) addToScore:(NSNumber *) scoreToAdd;
- (NSNumber*) getScore;

// Statistics
- (void) setLevelName:(NSString *) theLevelName;
- (void) setNewTargetSentence:(NSString *) targetSentence andTargetWords:(NSString *) targetWords andTargetSyllables:(NSString *) targetSyllables;
- (void) startStatisticsCollection;
- (void) startStatisticsCollectionWithLevelName:(NSString *) levelName;
- (void) stopStatisticsCollection;
- (void) addLevelToStatistics;
- (void) addUtteranceToStatistics:(NSString *) utterance;
- (void) addSentenceToStatistics;

// returns a CCScene that contains the class's layer as the only child
+(CCScene *) scene;

@end
