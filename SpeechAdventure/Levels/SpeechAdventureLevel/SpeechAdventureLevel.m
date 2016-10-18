//
//  SpeechAdventureLevel.m
//  speechadventure
//
//  Created by Zak Rubin on 4/10/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"
#import "TransitionScene.h"
#import "MainMenu.h"

@interface SpeechAdventureLevel()

@end

@implementation SpeechAdventureLevel
@synthesize shouldReturnPartials;
//@synthesize backgroundLayer, baseStageLayer, foregroundLayer, activityLayer;
#define kLevelUpdatesPerSecond 18 // We'll have the ui update 18 times a second to show some fluidity without hitting the CPU too hard.

NSString * playerName = @"Sammy";

+ (SpeechAdventureLevel *)scene {
	return [[self alloc] init];
}

- (id)init {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Add Layers
    [self addChild:self.backgroundLayer];
    [self addChild:self.baseStageLayer];
    [self addChild:self.activityLayer];
    [self addChild:self.foregroundLayer];
    
    // Remove all UI components
    _listeningIconIsVisible = false;
    _backButtonIsVisible = false;
    _phraseBoxIsVisible = false;
    _statisticsBeingCollected = true;
    
    _currentScore = [NSNumber numberWithInt:0];
    
    _previousValidSpeech = [[NSString alloc] init];
    [self setDeviceScaleFactor];
    _targetSentence = @"";
    _currentSessionID = [[StatManager sharedManager] getSessionCount];
    _currentLevelID = [[StatManager sharedManager] getLevelCount];
	return self;
}

- (AVAudioPlayer *)audioPlayer {
    if (_audioPlayer == nil)
    {
        _audioPlayer = [[AVAudioPlayer alloc] init];
    }
    return _audioPlayer;
}

- (void) addChild:(CCNode *)node {
    [super addChild:node];
}

- (CCNode *)backgroundLayer {
    if (_backgroundLayer == nil)
    {
        _backgroundLayer = [CCNode node];
        [_backgroundLayer setPositionType:CCPositionTypeNormalized];
        int ScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        int ScreenHeight = [[UIScreen mainScreen] bounds].size.height;
        _backgroundLayer.contentSize = CGSizeMake(ScreenWidth,ScreenHeight);
        self.backgroundLayer = _backgroundLayer;
    }
    return _backgroundLayer;
}

- (CCNode *)baseStageLayer {
    if (_baseStageLayer == nil)
    {
        _baseStageLayer = [CCNode node];
        [_baseStageLayer setPositionType:CCPositionTypeNormalized];
        int ScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        int ScreenHeight = [[UIScreen mainScreen] bounds].size.height;
        _baseStageLayer.contentSize = CGSizeMake(ScreenWidth,ScreenHeight);
        self.baseStageLayer = _baseStageLayer;
    }
    return _baseStageLayer;
}

- (CCNode *)activityLayer {
    if (_activityLayer == nil)
    {
        _activityLayer = [CCNode node];
        [_activityLayer setPositionType:CCPositionTypeNormalized];
        int ScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        int ScreenHeight = [[UIScreen mainScreen] bounds].size.height;
        _activityLayer.contentSize = CGSizeMake(ScreenWidth,ScreenHeight);
        self.activityLayer = _activityLayer;
    }
    return _activityLayer;
}

- (CCNode *)foregroundLayer {
    if (_foregroundLayer == nil)
    {
        _foregroundLayer = [CCNode node];
        [_foregroundLayer setPositionType:CCPositionTypeNormalized];
        int ScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        int ScreenHeight = [[UIScreen mainScreen] bounds].size.height;
        _foregroundLayer.contentSize = CGSizeMake(ScreenWidth,ScreenHeight);
        self.foregroundLayer = _foregroundLayer;
    }
    return _foregroundLayer;
}

- (void) setScaleFactorForSprite:(CCSprite*) theSprite {
    theSprite.scaleX *= _deviceScaleFactor.width;
    theSprite.scaleY *= _deviceScaleFactor.height;
}

- (void) setDeviceScaleFactor {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    _deviceScaleFactor = CGSizeMake(winSize.width / 480, winSize.height / 320);
}

- (void) setScaleFactorForScene {
    self.scaleX *= _deviceScaleFactor.width;
    self.scaleY *= _deviceScaleFactor.height;
}

- (void) setLevelName:(NSString *) levelName {
    _levelName = levelName;
    //[self addLevelToStatistics];
}

- (void) setNewTargetSentence:(NSString *) targetSentence andTargetWords:(NSString *) targetWords andTargetSyllables:(NSString *) targetSyllables {
    _targetSentence = targetSentence;
    _targetWords = targetWords;
    _targetSyllables = targetSyllables;
    //[self addSentenceToStatistics];
    _currentSentenceID = [[StatManager sharedManager] getSentenceCount];
}

// -----------------------------------------------------------------------
#pragma mark - OpenEars Functions And Speech Analysis
// -----------------------------------------------------------------------

- (void) receiveOEEvent:(OEEvent*) speechEvent {
    //abstract method for dealing with speech events
    [NSException raise:NSInternalInconsistencyException
                format:@"You must overide %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void) receiveOEState:(OEEvent*) stateEvent {
    if([stateEvent isListening]) {
        [self startListeningIcon];
    } else {
        [self stopListeningIcon];
    }
}

- (void) shouldReturnPartials:(BOOL)returnPartials {
    shouldReturnPartials = returnPartials;
}

- (void) pauseListeningAndPlaySound:(NSURL*) file {
    [[OEManager sharedManager] pauseListening];
    if(_listeningIconIsVisible) {
        [self stopDisplayingLevels];
        [_listeningIcon setBackgroundColor:[CCColor grayColor] forState:CCControlStateNormal];
    }
    _audioPlayer = [self.audioPlayer initWithContentsOfURL:file error:nil];
    [_audioPlayer prepareToPlay];
    int soundLength = [_audioPlayer duration]+0.5f;
    [_audioPlayer play];
    //[[SimpleAudioEngine sharedEngine] playEffect:@"S1ChildPhrase.wav"];
    [self scheduleOnce:@selector(resumeListening:) delay:soundLength];
}

- (void) playSound:(NSURL*) file {
    _audioPlayer = [self.audioPlayer initWithContentsOfURL:file error:nil];
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

-(void) resumeListening:(id)sender {
    [[OEManager sharedManager] resumeListening];
    if(_listeningIconIsVisible) [self startDisplayingLevels];
}

- (BOOL) checkIfPhraseExists:(NSString *) phrase currentHypothesis:(NSString*) currentHypothesis {
    if(!phrase || !currentHypothesis || currentHypothesis.length < phrase.length) return false;
    return [currentHypothesis rangeOfString:phrase].location != NSNotFound;
}

- (NSString *) checkForPhraseParts:(NSString *) phrase currentHypothesis:(NSString*) currentHypothesis {
    if(!phrase || !currentHypothesis) return @"";
    NSMutableArray *array = (NSMutableArray *)[phrase componentsSeparatedByString:@" "];
    NSString * partsFound = @"";
    NSString * subString = [NSString stringWithString:currentHypothesis];
    int i;
    for(i=0; i<array.count; i++) {
        NSRange wordRange = [subString rangeOfString:array[i]];
        if(wordRange.location == NSNotFound) {
            // We don't want to skip words or have them out of order, attempts must be sequential
            i=array.count;
        } else {
            subString = [subString substringFromIndex:wordRange.length];
            partsFound = [partsFound stringByAppendingString:array[i]];
            partsFound = [partsFound stringByAppendingString:@" "];
        }
    }
    return partsFound;
}

- (void) updatePreviousValidSpeech: (NSString*)speechResult {
    _previousValidSpeech = [NSString stringWithString:speechResult];
}

- (NSString *) truncateFromPreviousValidSpeech: (NSString*)speechResult {
    NSString * truncateResult = [[NSString alloc] initWithString:speechResult];
    if(speechResult.length > _previousValidSpeech.length) {
        truncateResult = [NSString stringWithString:[speechResult substringFromIndex:_previousValidSpeech.length]];
        // We want the developer to manually update this.
        //_previousValidSpeech = speechResult;
    }
    else {
        _previousValidSpeech = @"";
    }
    if([[truncateResult substringToIndex:1] isEqualToString:@" "]) truncateResult = [truncateResult substringFromIndex:1];
    return truncateResult;
}

- (void) waitForModelsToLoad {
    //[[OEManager sharedManager] ]
}


// -----------------------------------------------------------------------
#pragma mark - HUD Behavior
// -----------------------------------------------------------------------

- (void) showAllUIElements {
    [self showListeningEar];
    [self showBackButton];
    [self showGameTimer];
    [self showScore];
    [self showPhraseBox];
}

- (void) hideAllUIElements {
    [self hideListeningEar];
    [self hideBackButton];
    [self hideGameTimer];
    [self hideScore];
    [self hidePhraseBox];
}

- (void) startDisplayingLevels {
    [self stopDisplayingLevels]; // We never want more than one timer valid so we'll stop any running timers first.
	self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateListeningIconColor) userInfo:nil repeats:YES];
}

- (void) startEarToVolume {
    [self stopDisplayingLevels]; // We never want more than one timer valid so we'll stop any running timers first.
    self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateListeningIconColor) userInfo:nil repeats:YES];
}

- (void) stopDisplayingLevels {
    if(self.uiUpdateTimer && [self.uiUpdateTimer isValid]) { // If there is a running timer, we'll stop it here.
		[self.uiUpdateTimer invalidate];
		self.uiUpdateTimer = nil;
	}
}

- (void) hideListeningEar {
    if(_listeningIconIsVisible) {
        [self removeChild:_listeningIcon];
        [self stopDisplayingLevels];
        _listeningIconIsVisible= false; 
    }
}

- (void) showListeningEar {
    if(!_listeningIconIsVisible) {
        CCSpriteFrame * baseListeningFrame = [CCSpriteFrame frameWithImageNamed:@"ear_base.png"];
        _listeningIcon = [CCButton buttonWithTitle:@"" spriteFrame:baseListeningFrame];
        [_listeningIcon setScaleX:_deviceScaleFactor.width];
        [_listeningIcon setScaleY:_deviceScaleFactor.height];
        [_listeningIcon setTarget:self selector:@selector(toggleListening:)];
        _listeningIcon.positionType = CCPositionTypeNormalized;
        _listeningIcon.position = ccp(0.97f, 0.91f);
        [self addChild:_listeningIcon];
        [self startEarToVolume];
        _listeningIconIsVisible= true;
    }
}

- (void) showBackButton {
    if(!_backButtonIsVisible) {
        _backButton = self.backButton;
        _backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow_selected.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"]];
        [_backButton setTarget:self selector:@selector(goBack:)];
        _backButton.positionType = CCPositionTypeNormalized;
        [_backButton setScaleX:_deviceScaleFactor.width];
        [_backButton setScaleY:_deviceScaleFactor.height];
        _backButton.position = ccp(0.05f, 0.91f);
        [self addChild:_backButton];
        _backButtonIsVisible = TRUE;
    }
}

- (void) hideBackButton
{
    [self removeChild:_backButton];
    _backButtonIsVisible = false;
}

- (void) showScore
{
    if(!_scoreButtonIsVisible) {
        _scoreButton = self.scoreButton;
        _scoreButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"]];
        _scoreButton.positionType = CCPositionTypeNormalized;
        _scoreButton.scaleX = _deviceScaleFactor.width/2;
        _scoreButton.scaleY = _deviceScaleFactor.height/2;
        _scoreButton.anchorPoint = ccp(0,0.5f);
        _scoreButton.position = ccp(0.12f, 0.95f);
        [self addChild: _scoreButton];
        NSString *currentScoreString = [_currentScore stringValue];
        _scoreLabel = [CCLabelTTF labelWithString:currentScoreString fontName:@"ArialMT" fontSize:48.0];
        _scoreLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
        _scoreLabel.positionType = CCPositionTypeNormalized;
        _scoreLabel.scaleX = _deviceScaleFactor.width/2;
        _scoreLabel.scaleY = _deviceScaleFactor.height/2;
        _scoreLabel.position = ccp(0.16f, 0.95f);
        _scoreLabel.anchorPoint = ccp(0,0.5f);
        [self addChild: _scoreLabel];
        _scoreButtonIsVisible = TRUE;
    }
}

- (void) hideScore {
    [self removeChild: _scoreButton];
    [self removeChild: _scoreLabel];
    _scoreButtonIsVisible = FALSE;
}

- (void) setScore:(NSNumber *) score {
    _currentScore = score;
    if(_scoreButtonIsVisible) {
        [self removeChild: _scoreLabel];
        _scoreLabel = [CCLabelTTF labelWithString:[_currentScore stringValue] fontName:@"ArialMT" fontSize:48.0];
        _scoreLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
        _scoreLabel.positionType = CCPositionTypeNormalized;
        _scoreLabel.scaleX = _deviceScaleFactor.width/2;
        _scoreLabel.scaleY = _deviceScaleFactor.height/2;
        _scoreLabel.position = ccp(0.16f, 0.95f);
        _scoreLabel.anchorPoint = ccp(0,0.5f);
        [self addChild: _scoreLabel];
    }
}

- (void) addToScore:(NSNumber *) scoreToAdd {
    _currentScore =[NSNumber numberWithInt:([scoreToAdd intValue] + [_currentScore intValue])];
    if(_scoreButtonIsVisible) {
        [self removeChild: _scoreLabel];
        _scoreLabel = [CCLabelTTF labelWithString:[_currentScore stringValue] fontName:@"ArialMT" fontSize:48.0];
        _scoreLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
        _scoreLabel.positionType = CCPositionTypeNormalized;
        _scoreLabel.scaleX = _deviceScaleFactor.width/2;
        _scoreLabel.scaleY = _deviceScaleFactor.height/2;
        _scoreLabel.position = ccp(0.16f, 0.95f);
        _scoreLabel.anchorPoint = ccp(0,0.5f);
        [self addChild: _scoreLabel];
    }
}

- (NSNumber*) getScore {
    return _currentScore;
}

- (void) showGameTimer {
    if(!_gameTimerIsVisible) {
        _gameTimerButton = self.gameTimerButton;
        if([[StatManager sharedManager] getTimePlayedToday] >= 600) {
            _gameTimerButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"]];
        } else {
            _gameTimerButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
        }
        
        _gameTimerButton.positionType = CCPositionTypeNormalized;
        _gameTimerButton.scaleX = _deviceScaleFactor.width/2;
        _gameTimerButton.scaleY = _deviceScaleFactor.height/2;
        _gameTimerButton.anchorPoint = ccp(0,0.5f);
        _gameTimerButton.position = ccp(0.25f, 0.95f);
        [self addChild: _gameTimerButton];
        _gameTimerLabel = [CCLabelTTF labelWithString:@"0" fontName:@"ArialMT" fontSize:48.0];
        _gameTimerLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
        _gameTimerLabel.positionType = CCPositionTypeNormalized;
        _gameTimerLabel.scaleX = _deviceScaleFactor.width/2;
        _gameTimerLabel.scaleY = _deviceScaleFactor.height/2;
        _gameTimerLabel.position = ccp(0.29f, 0.95f);
        _gameTimerLabel.anchorPoint = ccp(0,0.5f);
        [self addChild: _gameTimerLabel];
        _gameTimerIsVisible = TRUE;
        if([[StatManager sharedManager] getTimePlayedToday] >= 600) {
            CCSprite * timerCheckMark = [CCSprite spriteWithImageNamed:@"Checkmark.gif"];
            timerCheckMark.positionType = CCPositionTypeNormalized;
            timerCheckMark.position = ccp(0.30f, 0.95f);
            timerCheckMark.scale *= 0.20f;
            [self setScaleFactorForSprite:timerCheckMark];
            //_checkmark.scale *= 0.5f;
            [self addChild: timerCheckMark];
        }
    }
}

- (void) hideGameTimer {
    [_gameTimer invalidate];
    [self removeChild: _gameTimerButton];
    [self removeChild: _gameTimerLabel];
    _gameTimerIsVisible = false;
}

- (void) updateGameTimer:(NSTimer *)theTimer {
    if(_gameTimeLeft > 0 ) {
        _gameTimeLeft -- ;
        [self removeChild: _gameTimerLabel];
        _gameTimerLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%02d", _gameTimeLeft] fontName:@"ArialMT" fontSize:48.0];
        _gameTimerLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
        _gameTimerLabel.positionType = CCPositionTypeNormalized;
        _gameTimerLabel.scaleX = _deviceScaleFactor.width/2;
        _gameTimerLabel.scaleY = _deviceScaleFactor.height/2;
        _gameTimerLabel.position = ccp(0.29f, 0.95f);
        _gameTimerLabel.anchorPoint = ccp(0,0.5f);
        [self addChild: _gameTimerLabel];
    } else {
        [_gameTimer invalidate];
        [self timeUp];
    }
}

-(void) setAndStartGameTimer:(int) gameTime {
    _levelTimeLimit = [NSNumber numberWithInt:gameTime];
    _gameTimeLeft = gameTime;
    [[StatManager sharedManager] setStartGameTimeToNow];
    if([_gameTimer isValid]) {
        _gameTimer = 0;
    }
    _gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateGameTimer:) userInfo:nil repeats:YES];
}

- (void) showPhraseBox {
    _phraseBox = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_large.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_large.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_large.png"]];
    _phraseBox.positionType = CCPositionTypeNormalized;
    _phraseBox.scaleX = _deviceScaleFactor.width/2;
    _phraseBox.scaleY = _deviceScaleFactor.height/2;
    _phraseBox.anchorPoint = ccp(0,0.5f);
    _phraseBox.position = ccp(0.4f, 0.95f);
    [self addChild: _phraseBox];
}

- (void) hidePhraseBox {
    
}

- (void) setSentenceInPhraseBox:(NSString *) text {
    [self removeChild: _sentenceLabel];
    _sentenceLabel = [CCLabelTTF labelWithString:text fontName:@"ArialMT" fontSize:48.0];
    if(text.length > 18) _sentenceLabel.fontSize = 42.0;
    _sentenceLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
    _sentenceLabel.positionType = CCPositionTypeNormalized;
    _sentenceLabel.scaleX = _deviceScaleFactor.width/2;
    _sentenceLabel.scaleY = _deviceScaleFactor.height/2;
    _sentenceLabel.position = ccp(0.425f, 0.95f);
    _sentenceLabel.anchorPoint = ccp(0,0.5f);
    [self addChild: _sentenceLabel];
    [_highlightedWordsLabel removeFromParent];
    if(_highlightedWordsLabel)[self addChild:_highlightedWordsLabel];
}

- (void) setHighlightedWordsInPhraseBox:(NSString*)wordsToHighlight {
    if(wordsToHighlight != nil) {
        if(_highlightedWordsLabel) {
            [self removeChild:_highlightedWordsLabel];
            _highlightedWordsLabel = nil;
        }
        _highlightedWordsLabel = [CCLabelTTF labelWithString:wordsToHighlight fontName:@"ArialMT" fontSize:48.0];
        _highlightedWordsLabel.positionType = CCPositionTypeNormalized;
        _highlightedWordsLabel.position = ccp(0.541f, 0.95f);
        _highlightedWordsLabel.anchorPoint = ccp(0,0.5f);
        
        if(_sentenceLabel.string.length > 18) {
            _highlightedWordsLabel.fontSize = 42.0;
            _highlightedWordsLabel.position = ccp(0.528f, 0.95f);
        }
        
        _highlightedWordsLabel.color = [CCColor colorWithCcColor3b:ccYELLOW];
        _highlightedWordsLabel.scaleX = _deviceScaleFactor.width/2;
        _highlightedWordsLabel.scaleY = _deviceScaleFactor.height/2;
        [self addChild: _highlightedWordsLabel];
    }
}

- (void) highlightPhraseParts:(NSString*)phraseParts {
    if(phraseParts.length > 0) {
        phraseParts = [phraseParts lowercaseString];
        phraseParts = [phraseParts stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[phraseParts substringToIndex:1] uppercaseString]];
        //[self setSentenceInPhraseBox:currentSentenceFormatted];
        [self setHighlightedWordsInPhraseBox:phraseParts];
    } else {
        //[self setSentenceInPhraseBox:currentSentenceFormatted];
        [self setHighlightedWordsInPhraseBox:phraseParts];
    }
}


- (void) showCheckmark {
    if(_checkmark) {
        [self removeChild: _checkmark];
        _checkmark = nil;
    }
    _checkmark = [CCSprite spriteWithImageNamed:@"Checkmark.gif"];
    _checkmark.positionType = CCPositionTypeNormalized;
    _checkmark.position = ccp(0.85f, 0.94f);
    _checkmark.scale = 0.20f;
    [self setScaleFactorForSprite:_checkmark];
    //_checkmark.scale *= 0.5f;
    [self addChild: _checkmark];
    [self scheduleOnce:@selector(hideCheckmark:) delay:0.25f];
}

- (void) hideCheckmark:(id)sender {
    if(_checkmark) {
        [self removeChild: _checkmark];
        _checkmark = nil;
    }
}

// -----------------------------------------------------------------------
#pragma mark - HUD Callbacks
// -----------------------------------------------------------------------

- (void) startListeningIcon { // Start displaying the levels using a timer

}

- (void) stopListeningIcon { // Stop displaying the levels by stopping the timer if it's running.

}

- (void) updateListeningIconColor {
    if(_audioLevelLabel != nil){
        [self removeChild:_audioLevelLabel cleanup:false];
    }
    float rawAudioLevel = [[OEManager sharedManager] getRawAudioLevel];
    
    // rawAudio = -90 color = green
    // rawAudio = -60 color = yellow
    // rawAudio = -40 color = red
    float earAudioOffset = rawAudioLevel + 92; //noise floor based on ipad is 95 dbm. Add 3dBm for good measure.
    int multiplier = 6;
    
    // Total gradient size: 255+255 = 510
    //0,255 -> 255,255 -> 255,0
    // Below 80 = grey
    // 85-60 = Green
    // 60-50 = Yellow
    // 50+ = red
    float red, green, blue;
    red = (earAudioOffset * multiplier)/255;
    green = (255 - (earAudioOffset * multiplier))/255;
    blue = 0;
    
    if(rawAudioLevel <= -65) {
        red = 0.5f;
        green = 0.5f + ((earAudioOffset+25) * multiplier)/255;
        blue = 0.5f;
    } else if (rawAudioLevel <= -54) {
        green = 1;
        red =(earAudioOffset * multiplier)/255;
    } else if (rawAudioLevel <= -51) {
        earAudioOffset -= 10;
        red = (earAudioOffset * multiplier)/255;
        green = (255 - (earAudioOffset * multiplier))/255;
    } else if (rawAudioLevel <= -48) {
        earAudioOffset -= 35;
        red = (earAudioOffset * multiplier)/255;
        green = 0;
    } else {
        
    }
    
    if(red < 0) red = 0;
    if(green > 2) green = 2;
    
    CCColor *earColor = [CCColor colorWithRed:red green: green blue:blue];
    _listeningIconIsVisible = true;
    [_listeningIcon setBackgroundColor:earColor forState:CCControlStateNormal];
}


// Update sound levels
- (void) updateLevelsUI {
    if(_audioLevelLabel != nil){
        [self removeChild: _audioLevelLabel cleanup:false];
    }
    NSString* audioLevel = [NSString stringWithFormat:@"%@",[[OEManager sharedManager] getAudioLevel]];
    _audioLevelLabel = [CCLabelTTF labelWithString:audioLevel fontName:@"ArialMT" fontSize:48.0];
    //audioLevelLabel.color = ccc3(0,0,0);
    _audioLevelLabel.position = ccp(0.05f, 0.5f);
    [self addChild: _audioLevelLabel];
}

- (void) toggleListening:(id)sender {
    if([[OEManager sharedManager] isListening]) {
        [[OEManager sharedManager] pauseListening];
        _listeningIcon = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_paused.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_selected.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_paused.png"]];
        [_listeningIcon setTarget:self selector:@selector(toggleListening:)];
        [_listeningIcon setScaleX:_deviceScaleFactor.width];
        [_listeningIcon setScaleY:_deviceScaleFactor.height];
        _listeningIcon.positionType = CCPositionTypeNormalized;
        _listeningIcon.position = ccp(0.97f, 0.91f);
    } else {
        [[OEManager sharedManager] resumeListening];
        _listeningIcon = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_quiet.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_selected.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ear_quiet.png"]];
        [_listeningIcon setTarget:self selector:@selector(toggleListening:)];
        [_listeningIcon setScaleX:_deviceScaleFactor.width];
        [_listeningIcon setScaleY:_deviceScaleFactor.height];
        _listeningIcon.positionType = CCPositionTypeNormalized;
        _listeningIcon.position = ccp(0.97f, 0.91f);
    }
    if(_listeningIconIsVisible){
        [self.foregroundLayer addChild:_listeningIcon];
    }
}

- (void) goBack:(id)sender {
    [self updateSessionStatistics];
    
    [self returnToMainMenu];
}

- (void) returnToMainMenu {
    [self hideBackButton];
    [self hideListeningEar];
    [self hideGameTimer];
    [self stopStatisticsCollection];
    [[OEManager sharedManager] removeDelegate:self];
    if([[OEManager sharedManager] isListening]) {
        [[OEManager sharedManager] stopListening];
    }
    /*[[CCDirector sharedDirector] replaceScene:[MainMenu scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];*/
    [[CCDirector sharedDirector] popToRootSceneWithTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

- (void) changeLevel {
    [[OEManager sharedManager] removeDelegate:self];
    [self hideBackButton];
    [self hideListeningEar];
    [self hideGameTimer];
    [self updateSessionStatistics];
    if([[OEManager sharedManager] isListening]) {
        [[OEManager sharedManager] stopListening];
    }
    @try {
        [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [[CCDirector sharedDirector] popToRootScene];
    }
    @finally {
        NSLog(@"finally");
        
    }
    
}

- (void) changeToLevel:(NSString*) nextLevelName {
    [self hideBackButton];
    [self hideListeningEar];
    [self hideGameTimer];
    [[CCDirector sharedDirector] replaceScene:[NSClassFromString(nextLevelName) scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

-(void) timeUp {
    [self changeLevel];
}

// -----------------------------------------------------------------------
#pragma mark - Statistics Functions
// -----------------------------------------------------------------------
- (void) startStatisticsCollection {
    _statisticsBeingCollected = true;
}

- (void) startStatisticsCollectionWithLevelName:(NSString *) levelName {
    _levelName = levelName;
    [self addLevelToStatistics];
}

- (void) stopStatisticsCollection {
    _statisticsBeingCollected = false;
}

- (void) updateSessionStatistics {
    // Add statistics
    int maxLevelTime = [[self levelTimeLimit] integerValue];
    int levelTime = maxLevelTime - _gameTimeLeft;
    int sessionTime = [[StatManager sharedManager] timePlayedThisSession];
    [[StatManager sharedManager] setTimePlayedThisSession:sessionTime + levelTime];
    [self addLevelToStatistics];
    int levelScore = [[self getScore] integerValue];
    int currentSessionScore = [[StatManager sharedManager] scoreThisSession];
    [[StatManager sharedManager]  setScoreThisSession:levelScore+currentSessionScore];
    [[StatManager sharedManager] updateTimeScoreLevelsForThisSession];
}

- (void) addLevelToStatistics {
    int maxLevelTime = [[self levelTimeLimit] integerValue];
    int levelScore = [[self getScore] integerValue];
    int levelTime = maxLevelTime - _gameTimeLeft;
    
    NSString *dateString = [[StatManager sharedManager] getStartGameTimeAsDateTime];
    NSString * query = [NSString stringWithFormat:@"%d, '%@', '%@', '%@', %d, %d", _currentSessionID, @"TestUser", dateString, _levelName, levelTime, levelScore];
    NSLog(@"Time is %d score is %d", levelTime, levelScore);
    //[self startStatisticsCollection];
    if(_statisticsBeingCollected) [[StatManager sharedManager] addLevelToDatabase:query];
}

- (void) addSentenceToStatistics {
    NSString * query = [NSString stringWithFormat:@"%d, %d, '%@', '%@', '%@'", _currentSessionID, _currentLevelID, _targetSentence, _targetWords, _targetSyllables];
    if(_statisticsBeingCollected) [[StatManager sharedManager] addSentenceToDatabase:query];
}

- (void) addUtteranceToStatistics:(NSString *) utterance {
    NSString * query = [NSString stringWithFormat:@"%d, '%@'", _currentSentenceID, utterance];
    if(_statisticsBeingCollected) [[StatManager sharedManager] addUtteranceToDatabase:query];
}

@end
