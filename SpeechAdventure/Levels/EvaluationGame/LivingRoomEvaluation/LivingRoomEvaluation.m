//
//  LivingRoomLayer.m
//  SpeechAdventure
//
//  Created by Zak Rubin on 5/10/13.
//
//

#import "LivingRoomEvaluation.h"
#import "PopABalloonEvaluation.h"
#import "TransitionScene.h"
#import "MainMenu.h"


@implementation LivingRoomEvaluation
{
    // Scenery sprites.
    CCSprite *_foreground, *_background;
    
    // Node that simulates the physics.
    CCPhysicsNode *_physics;
    
    // The boundaries of the "bin" that the balls are trapped inside of.
    CGRect _binRect;
    
    // List of balls in the game.
    NSMutableArray *_balls;
    
    // Number of elapsed fixed timesteps.
    NSUInteger _ticks;
    
    // Cache the particles definition.
    NSDictionary *_popParticles;
}

//@synthesize sam = _sam;
@synthesize sentenceLabel = _sentenceLabel;
@synthesize highlightedWord = _highlightedWord;
@synthesize levelTime = _levelTime;
//@synthesize backgroundLayer, foregroundLayer, activityLayer, baseStageLayer;


#pragma mark -
#pragma mark Initializer & memory management

- (id) init
{
    if (self=[super init]) {
        // SETUP CHARACTER(S)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sam_sprite_sheet.plist"];
        
        // Enable touch handling on scene node
        self.userInteractionEnabled = YES;
        
        //******************ADD SPRITES TO THE PROPER LAYERS******************
        // BASE LAYER
        CCSprite *base = [CCSprite spriteWithImageNamed:@"BaseStage.png"];
        base.anchorPoint = ccp(0,0);
        base.position = ccp(0,0);
        [self setScaleFactorForSprite:base];
        //[self addChild:base];
        [self.backgroundLayer addChild:base];
        
        [self addHat];
        
        [self addBoots];
        
        
        // SETUP RECOGNITION
        [[OEManager sharedManager] swapModel:@"LivingRoomPlosives"];
        [[OEManager sharedManager] startListening];
        
        // BEGIN ACTIONS
        //while(![[OEManager sharedManager] modelSwapped]);
        
        //[self waitForModelsToLoad];
        [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:TRUE];
        [[OEManager sharedManager] pauseListening];
        
        // Initialize statistics
        [self startStatisticsCollection];
        [self setLevelName:@"LivingRoomEvaluation"];
        
        [self intro];
    }
    return self;
}

//Initializer methods

#pragma mark -
#pragma mark Acts within the stage

- (void)intro
{
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for(int i = 0; i <= 1; ++i)
    {
        [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"sam_right_%d.png", i]]];
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.5f]; //Framerate
    
    //Adding png to sprite
    self.sam = [CCSprite spriteWithImageNamed:@"sam_right_0.png"];
    
    //Positioning the sprite
    self.sam.positionType = CCPositionTypeNormalized;
    self.sam.position  = ccp(0.0f, 0.0f);
    
    //Repeating the sprite animation
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:walkAnim];
    CCActionRepeatForever *repeatingAnimation = [CCActionRepeatForever actionWithAction:animationAction];
    
    //Animation continuously repeating
    [self.sam runAction:repeatingAnimation];
    [self setScaleFactorForSprite:self.sam];
    //Adding the Sprite to the Scene
    [self addChild:self.sam];
    
    //animate sam2
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"LivingRoomIntro"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:2.0f position:ccp(0.6f, 0.25f)];
    [self.sam runAction:actionMove];
    [self showBackButton];
    [self showPhraseBox];
    [self setSentenceInPhraseBox:@"Touch glowing things!"];
}

- (void) addBoots {
    // boots
    self.boots = [CCSprite spriteWithImageNamed:@"boots.png"];
    [self setScaleFactorForSprite:self.boots];
    self.boots.positionType = CCPositionTypeNormalized;
    self.boots.position = ccp(0.45f,0.3f);
    [self.foregroundLayer addChild:self.boots];
    
    // boots glow
    self.bootsGlow = [CCSprite spriteWithImageNamed:@"boots.png"];
    self.bootsGlow.scale *= 1.25f;
    [self setScaleFactorForSprite:self.bootsGlow];
    self.bootsGlow.positionType = CCPositionTypeNormalized;
    self.bootsGlow.position = ccp(0.45f,0.3f);
    [self.bootsGlow setColor:[CCColor colorWithCcColor3b:ccYELLOW]];
    [self.activityLayer addChild:self.bootsGlow];
    self.bootsGlowUp = true;
    
    [self schedule:@selector(bootsGlow:) interval:0.05f repeat:CCTimerRepeatForever delay:0.3f];
}

- (void) addHat {
    // hat
    self.hat = [CCSprite spriteWithImageNamed:@"hat.png"];
    self.hat.positionType = CCPositionTypeNormalized;
    self.hat.position = ccp(0.5f,0.55f);
    [self setScaleFactorForSprite:self.hat];
    [self.foregroundLayer addChild:self.hat];
    
    // hat glow
    self.hatGlow = [CCSprite spriteWithImageNamed:@"hat.png"];
    self.hatGlow.scale *= 1.3f;
    [self setScaleFactorForSprite:self.hatGlow];
    //self.hatGlow.scaleY *= 1.4f;
    self.hatGlow.positionType = CCPositionTypeNormalized;
    self.hatGlow.position = ccp(0.5f,0.55f);
    [self.hatGlow setColor:[CCColor colorWithCcColor3b:ccYELLOW]];
    [self.activityLayer addChild:self.hatGlow];
    self.hatGlowUp = true;
    
    [self schedule:@selector(hatGlow:) interval:0.05f repeat:CCTimerRepeatForever delay:0.5f];
}

- (void) bootsGlow:(CCTime)dt
{
    if([[self bootsGlow] opacity] >= 1.0f) {
        self.bootsGlowUp = false;
    }
    if([[self bootsGlow] opacity] <= 0.0f) {
        self.bootsGlowUp = true;
    }
    
    if(self.bootsGlowUp) {
        [[self bootsGlow] setOpacity:[[self bootsGlow] opacity]+0.05f];
    } else {
        [[self bootsGlow] setOpacity:[[self bootsGlow] opacity]-0.05f];
    }
}

- (void) hatGlow:(CCTime)dt
{
    if([[self hatGlow] opacity] >= 1.0f) {
        self.hatGlowUp = false;
    }
    if([[self hatGlow] opacity] <= 0.0f) {
        self.hatGlowUp = true;
    }
    
    if(self.hatGlowUp) {
        [[self hatGlow] setOpacity:[[self hatGlow] opacity]+0.05f];
    } else {
        [[self hatGlow] setOpacity:[[self hatGlow] opacity]-0.05f];
    }
    
}

-(void) sentence1
{
    // DISPLAY THE ALL-LISTENING EAR.
    //[self.sam stopAllActions];
    [self showListeningEar];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"PutOnBoots"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self setNewTargetSentence:@"PUT ON BOOTS" andTargetWords:@"PUT, BOOTS" andTargetSyllables:@"p, b"];
    [self displayPhrase:@"Put on boots" wordsToHighLight:nil];
    
}

-(void) sentence2
{
    [self showListeningEar];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"WearAHat"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self setNewTargetSentence:@"WEAR A HAT" andTargetWords:@"HAT" andTargetSyllables:@"h"];
    [self displayPhrase:@"Wear a hat" wordsToHighLight:nil];
}

-(void) sentence3:(CCTime)dt
{
    [self.sam stopAllActions];
    [self showListeningEar];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"OpenTheDoor"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self setNewTargetSentence:@"OPEN THE DOOR" andTargetWords:@"OPEN, DOOR" andTargetSyllables:@"p, d"];
    [self displayPhrase:@"Open the door" wordsToHighLight:nil];
}

- (void)sentence1Action
{
    [self reward1];
    if(self.hat == nil) {
        [self scheduleOnce:@selector(sentence3:) delay:2.0f];
    }
}

- (void)sentence2Action
{
    self.sam = [CCSprite spriteWithImageNamed:@"sam_front_HAT.png"];
    //[self.samCharacter setRewardFrame:@"sam_excite_HAT.png"];
    [self reward2];
    if(self.boots == nil) {
        [self scheduleOnce:@selector(sentence3:) delay:2.0f];
    }
}

- (void)sentence3Action
{
    //[self.samCharacter reward];
    CCSprite *base = [CCSprite spriteWithImageNamed:@"BaseStage_opendoor.png"];
    base.anchorPoint = ccp(0,0);
    base.position = ccp(0,0);
    [self setScaleFactorForSprite:base];
    [self.backgroundLayer addChild:base];
    //[_statLevelEntry addSentence:_currentSentenceStats];
    [self reward3];
}

- (void)reward1
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"SlugsDontWearBoots"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self unschedule:@selector(bootsGlow:)];
    [self.activityLayer removeChild:self.bootsGlow];
    [self.foregroundLayer removeChild:self.boots];
    self.boots = nil;
}

- (void)reward2
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"SomethingASlugCanWear"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self unschedule:@selector(hatGlow:)];
    [self.activityLayer removeChild:self.hatGlow];
    [self.foregroundLayer removeChild:self.hat];
    self.hat = nil;
}

- (void)reward3
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"LivingRoomComplete"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self scheduleOnce:@selector(nextScene:) delay:3];
}

-(void) sayPhrase:(id)sender
{
    /*NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"S1ChildPhrase"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile delay:1.5];*/
}

-(void) displayPhrase:(NSString*)phrase wordsToHighLight:(NSString*)highlightedWords
{
    if(_sentenceLabel != nil) {
        [self removeChild:_sentenceLabel cleanup:false];
    }
    if(phrase == nil) {
        phrase = @" ";
    }
    [self showPhraseBox];
    NSString *obstacleText = @"Say \"";
    obstacleText = [obstacleText stringByAppendingString:phrase];
    obstacleText = [obstacleText stringByAppendingString:@"\"!"];
    [self setSentenceInPhraseBox:obstacleText];
    [self setHighlightedWordsInPhraseBox:highlightedWords];
}

-(void) nextScene:(CCTime)dt
{
    [self hideListeningEar];
    [self addLevelToStatistics];
    [StatManager sharedManager].timePlayedThisSession += 10;
    [[StatManager sharedManager] updateTimeScoreLevelsForThisSession];
    [[OEManager sharedManager] removeDelegate:self];
    [[CCDirector sharedDirector] replaceScene:[PopABalloonEvaluation scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    if (CGRectContainsPoint(self.boots.boundingBox, touchLoc)) {
        NSLog(@"You touched boots");
        [self sentence1];
    } else if (CGRectContainsPoint(self.hat.boundingBox, touchLoc)){
        NSLog(@"You touched hat");
        [self sentence2];
    }
    
}

// -----------------------------------------------------------------------
#pragma mark - Voice Input Handling
// -----------------------------------------------------------------------

- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
}

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"LivingRoomEval received speechEvent.\ntext:%@\ntargetsentence:%@",speechEvent.text,[self targetSentence]);
    
    if([self targetSentence].length > 1 && speechEvent.eventType == RapidEarsPartial) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:speechEvent.text];
        BOOL phraseSaid = NO;
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            // Check which sentence
            if([self.targetSentence isEqualToString:@"PUT ON BOOTS"]) {
                [self sentence1Action];
                [self addSentenceToStatistics];
                [self showCheckmark];
                [self setTargetSentence:@" "];
                phraseSaid = YES;
                [self addToScore:[NSNumber numberWithInt:1]];
                //[self setSentenceInPhraseBox:@" "];
            } else if ([self.targetSentence isEqualToString:@"WEAR A HAT"]) {
                [self sentence2Action];
                [self addSentenceToStatistics];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self showCheckmark];
                phraseSaid = YES;
                [self setTargetSentence:@" "];
                //[self setSentenceInPhraseBox:@" "];
            } else if ([self.targetSentence isEqualToString:@"OPEN THE DOOR"]) {
                [self sentence3Action];
                [self addSentenceToStatistics];
                [self showCheckmark];
                phraseSaid = YES;
                [self addToScore:[NSNumber numberWithInt:1]];
            } else {
                
            }
            [self addUtteranceToStatistics:speechEvent.text];
        } else {
            
        }
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        [self highlightPhraseParts:phraseParts];
        if(phraseSaid) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f ];
    }
}

#pragma mark -
#pragma mark Cocos2D Methods
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	LivingRoomEvaluation *layer = [LivingRoomEvaluation node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    // return the scene
	return scene;
}

@end
