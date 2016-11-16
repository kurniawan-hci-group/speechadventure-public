//
//  InstructionEvaluation.m
//  An instructional game for speech adventure
//
//  Created by Zak Rubin on 11/30/15.
//
//

#import "InstructionEvaluation.h"
#import "LivingRoomEvaluation.h"
#import "TransitionScene.h"
#import "MainMenu.h"


@implementation InstructionEvaluation
{
    // Scenery sprites.
    CCSprite *sam, *guideArrow, *instructionTimerButton, *timerCheckMark;
    
    // Node that simulates the physics.
    AVAudioPlayer * narration;
    bool samTouchAllowed;
}


#pragma mark -
#pragma mark Initializer & memory management

- (id) init
{
    if (self=[super init]) {
        // SETUP CHARACTER(S)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sam_sprite_sheet.plist"];
        
        // Enable touch handling on scene node
        self.userInteractionEnabled = YES;
        
        
        narration = [AVAudioPlayer alloc];
        
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
        [self.backgroundLayer addChild:background];
        
        samTouchAllowed = NO;
        
        // SETUP RECOGNITION
        [[OEManager sharedManager] swapModel:@"OpenEars1"];
        [[OEManager sharedManager] stopListening];
        
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
    sam = [CCSprite spriteWithImageNamed:@"sam_right_0.png"];
    
    //Positioning the sprite
    sam.positionType = CCPositionTypeNormalized;
    sam.position  = ccp(0.0f, 0.0f);
    
    //Repeating the sprite animation
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:walkAnim];
    CCActionRepeatForever *repeatingAnimation = [CCActionRepeatForever actionWithAction:animationAction];
    
    //Animation continuously repeating
    [sam runAction:repeatingAnimation];
    [self setScaleFactorForSprite:sam];
    //Adding the Sprite to the Scene
    [self addChild:sam];
    
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:2.0f position:ccp(0.5f, 0.25f)];
    [sam runAction:actionMove];
    [self scheduleOnce:@selector(sentence1:) delay:2.0f];
}



-(void) sentence1:(CCTime)dt
{
    [sam stopAllActions];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorial1"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self scheduleOnce:@selector(sentence2:) delay:1.5f];
}

-(void) sentence2:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorial2"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self scheduleOnce:@selector(sentence3:) delay:3.5f];
}

-(void) sentence3:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorial3"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self scheduleOnce:@selector(backArrowInstruction:) delay:1.5f];
}

-(void) backArrowInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialbackarrow"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self showBackButton];
    [self scheduleOnce:@selector(scoreBoxInstruction:) delay:3.0f];
}

-(void) scoreBoxInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialscorebox"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self showScore];
    [self scheduleOnce:@selector(timeBoxInstruction:) delay:2.2f];
}

-(void) timeBoxInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialtimebox"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self showGameTimer];
    [self scheduleOnce:@selector(textBoxInstruction:) delay:8.5f];
    [self scheduleOnce:@selector(finishedTimeBox:) delay:3.5];
}

-(void) finishedTimeBox:(CCTime)dt
{
    [self scheduleOnce:@selector(resetTimeBox:) delay:1.0f];
    instructionTimerButton =  [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"]];
    instructionTimerButton.positionType = CCPositionTypeNormalized;
    instructionTimerButton.scale *= 1.1f;
    instructionTimerButton.anchorPoint = ccp(0,0.5f);
    instructionTimerButton.position = ccp(0.25f, 0.95f);

    timerCheckMark = [CCSprite spriteWithImageNamed:@"Checkmark.gif"];
    timerCheckMark.positionType = CCPositionTypeNormalized;
    timerCheckMark.position = ccp(0.30f, 0.95f);
    timerCheckMark.scale *= 0.20f;
    [self setScaleFactorForSprite:timerCheckMark];
    [self addChild: instructionTimerButton];
    [self addChild: timerCheckMark];
    
}

-(void) resetTimeBox:(CCTime)dt
{
    [self setGameTimerButton: [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]]];
    [timerCheckMark removeFromParent];
    [instructionTimerButton removeFromParent];
}

-(void) textBoxInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialtextbox"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self showPhraseBox];
    [self setSentenceInPhraseBox:@"Touch the arrow to exit"];
    [self scheduleOnce:@selector(earInstruction:) delay:3.5f];
    
}

-(void) earInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialear"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self showListeningEar];
    [self scheduleOnce:@selector(pokeSamInstruction:) delay:9.0f];
    
}

-(void) pokeSamInstruction:(CCTime)dt
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialpokesam"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    samTouchAllowed = YES;
    [self setSentenceInPhraseBox:@"Poke sam!"];
    
}

- (void)sayGoRight
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialgoright"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self setTargetSentence:@"GO RIGHT"];
    [self setSentenceInPhraseBox:@"Say \"Go right\"!"];
    [self scheduleOnce:@selector(timedSpeechStart:) delay:1.0f];
    //[self reward1];
}

- (void)timedSpeechStart:(CCTime) dt {
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:TRUE];
}

- (void)goRight
{
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:1.0f position:ccp(0.25f, 0.0f)];
    [sam runAction:actionMove];
}

- (void)sayGoLeft
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialgoleft"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    [self setTargetSentence:@"GO LEFT"];
    [self setSentenceInPhraseBox:@"Say \"Go left\"!"];
    [self scheduleOnce:@selector(timedSpeechStart:) delay:1.5f];
}

- (void)goLeft
{
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:2.0f position:ccp(-0.50f, 0.0f)];
    [sam runAction:actionMove];

}

- (void)greatJob
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"tutorialgreatjob"
                                               ofType:@"wav"]];
    narration = [narration initWithContentsOfURL:soundFile error:nil];
    [narration play];
    //[[OEManager sharedManager] stopListening];
    [self scheduleOnce:@selector(nextScene:) delay:2.5f];
}

-(void) nextScene:(CCTime)dt
{
    [self hideListeningEar];
    [[StatManager sharedManager] updateTimeScoreLevelsForThisSession];
    [[OEManager sharedManager] removeDelegate:self];
    [[CCDirector sharedDirector] popToRootSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:1.0f]];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    if (CGRectContainsPoint(sam.boundingBox, touchLoc) && samTouchAllowed) {
        NSLog(@"You touched sam");
        [self sayGoRight];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Voice Input Handling
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool phraseSaid = NO;
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            if([self.targetSentence isEqualToString:@"GO RIGHT"]) {
                [self showCheckmark];
                [self updatePreviousValidSpeech:speechEvent.text];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self goRight];
                [self greatJob];
                
            } else if([self.targetSentence isEqualToString:@"GO LEFT"]) {
                [self addSentenceToStatistics];
                [self showCheckmark];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self updatePreviousValidSpeech:speechEvent.text];
                //[self addSen:speechEvent.text];
                [self goLeft];
                [self greatJob];
                [self scheduleOnce:@selector(nextScene:) delay:2.0f];
            } else {
                
            }
        } else {
            
        }
        // Convert all uppercase strings to standard sentence format for display (first letter of phrase uppercase)
        //if(![self.targetSentence isEqual:@""]);
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        
        if(phraseParts.length > 0) {
            phraseParts = [phraseParts lowercaseString];
            phraseParts = [phraseParts stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[phraseParts substringToIndex:1] uppercaseString]];
            //[self setSentenceInPhraseBox:currentSentenceFormatted];
            [self setHighlightedWordsInPhraseBox:phraseParts];
        } else {
            //[self setSentenceInPhraseBox:currentSentenceFormatted];
            [self setHighlightedWordsInPhraseBox:phraseParts];
        }
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
	InstructionEvaluation *layer = [InstructionEvaluation node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    // return the scene
	return scene;
}

@end
