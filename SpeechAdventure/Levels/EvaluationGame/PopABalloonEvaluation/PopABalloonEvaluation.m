//
//  PopABalloon.m
//  SpeechAdventure
//
//  Created by John Chambers on 7/27/12.
//
//

#import "PopABalloonEvaluation.h"
#import "MainMenu.h"

@implementation PopABalloonEvaluation


@synthesize sam = sam;
@synthesize balloons = _balloons;
@synthesize sentenceLabel = _sentenceLabel;
@synthesize highlightedWord = _highlightedWord;
@synthesize levelTime = _levelTime;


#pragma mark -
#pragma mark Initializer & memory management

- (id) init
{
    if (self=[super init]) {
        [[OEManager sharedManager] swapModel:@"PopABalloonPlosives"];
        [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:TRUE];
        
        //SETUP CHARACTER(S)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sam_sprite_sheet.plist"];
        
        //******************ADD SPRITES TO THE PROPER LAYERS******************
        
        //BASE LAYER
        CCSprite *base = [CCSprite spriteWithImageNamed:@"S1BaseStage.png"];
        base.anchorPoint = ccp(0,0);
        base.position = ccp(0,0);
        [self setScaleFactorForSprite:base];
        [self.backgroundLayer addChild:base];
        
        //balloons
        for (int i = 0; i<3; i++) {
            CCSprite *newBalloon = [CCSprite spriteWithImageNamed:@"Balloon2.png"];
            [self setScaleFactorForSprite:newBalloon];
            newBalloon.positionType = CCPositionTypeNormalized;
            [self.balloons addObject:newBalloon];
        }
        ((CCSprite *)[self.balloons objectAtIndex:0]).position = ccp(0.54f,0.5f);
        ((CCSprite *)[self.balloons objectAtIndex:1]).position = ccp(0.60f,0.6f);
        ((CCSprite *)[self.balloons objectAtIndex:2]).position = ccp(0.66,0.5f);
        
        for (CCSprite* myBalloon in self.balloons) {
            [self addChild:myBalloon];
        };
        
        
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 0; i <= 1; ++i)
        {
            [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"sam_right_%d.png", i]]];
        }
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:walkAnimFrames delay:1.0f]; //Speed in which the frames will go at
        
        //Adding png to sprite
        sam = [CCSprite spriteWithImageNamed:@"sam_right_0.png"];
        
        //Positioning the sprite
        sam.position  = ccp(0.0f, 0.0f);
        [self setScaleFactorForSprite:sam];
        sam.positionType = CCPositionTypeNormalized;
        
        //Repeating the sprite animation
        CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:walkAnim];
        CCActionRepeatForever *repeatingAnimation = [CCActionRepeat actionWithAction:animationAction times:1];
        
        //Animation continuously repeating
        [sam runAction:repeatingAnimation];
        
        //Adding the Sprite to the Scene
        [self addChild:sam];
        
        [self setLevelName:@"PopABalloonEvaluation"];
        
        // BEGIN ACTIONS
        [self intro];
    }
    return self;
}

//Initializer methods

- (NSMutableArray *)balloons
{
    if (_balloons == nil)
    {
        _balloons = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _balloons;
}

#pragma mark -
#pragma mark Acts within the stage

- (void)intro
{
    //animate sam2
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:2.0f position:ccp(0.25f, 0.25f)];
    [sam runAction:actionMove];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"S1Prompt"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self scheduleOnce:@selector(sentence1:) delay:6];
}

-(void) sentence1:(CCTime)dt
{
    // DISPLAY THE ALL-LISTENING EAR.
    
    [[OEManager sharedManager] startListening];
    [self showListeningEar];
    [self showBackButton];
    [self setTargetSentence:@"POP A BALLOON"];
    [self displayPhrase:@"Pop a balloon" wordsToHighLight:nil];
}

-(void) sentence2:(CCTime)dt
{
    [self setTargetSentence:@"CROSS THE BRIDGE"];
    [self displayPhrase:@"Cross the bridge" wordsToHighLight:nil];
}

- (void)sentence1Action
{
    //Stat Collection
    
    //remove a balloon & play a sound
    [((CCSprite*)[self.balloons lastObject]) runAction:[CCActionHide action]];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:@"PoppingBalloon1"
                                                   ofType:@"wav"]];
    [self pauseListeningAndPlaySound: soundFile];
    [self.balloons removeLastObject];
    [self setHighlightedWordsInPhraseBox:nil];
    //trigger exit if done
    if (self.balloons.count == 0) {
        [self scheduleOnce:@selector(reward1:) delay:1.5];
    }
}

- (void)sentence2Action
{
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:2.0f position:ccp(300, 100)];
    [sam runAction:actionMove];
    [self reward2];
}

- (void)reward1:(CCTime)dt
{
    //[self.sam runAction:exitAction];
    //[self.samCharacter reward];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"S1Reward"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    [self scheduleOnce:@selector(sentence2:) delay:3];
}

- (void)reward2
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"S1Reward"
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
    [self showPhraseBox];
    NSString *obstacleText = @"Say \"";
    obstacleText = [obstacleText stringByAppendingString:phrase];
    obstacleText = [obstacleText stringByAppendingString:@"\"!"];
    [self setSentenceInPhraseBox:obstacleText];
    [self setHighlightedWordsInPhraseBox:highlightedWords];
}

//get playername, date, levelname, and target sentence
-(void) nextScene:(CCTime)dt
{
    // Get time interval, update levels played
    [self addLevelToStatistics];
    [StatManager sharedManager].timePlayedThisSession += 10;
    [[StatManager sharedManager] updateTimeScoreLevelsForThisSession];
    [[OEManager sharedManager] stopListening];
    [[OEManager sharedManager] removeDelegate:self];
    [[CCDirector sharedDirector] popToRootScene];
}

#pragma mark -
#pragma mark Voice input handling


- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
}

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    
    //NSLog(@"PopABalloonEval received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:speechEvent.text];
        
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        
        [self highlightPhraseParts:phraseParts];
        
        BOOL phraseSaid = NO;
        phraseParts = [phraseParts uppercaseString];
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            // Check which sentence
            if([self.targetSentence isEqualToString:@"POP A BALLOON"]) {
                [self sentence1Action];
                [self addSentenceToStatistics];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self showCheckmark];
                phraseSaid = YES;
            } else if ([self.targetSentence isEqualToString:@"CROSS THE BRIDGE"]) {
                [self sentence2Action];
                [self addSentenceToStatistics];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self showCheckmark];
                phraseSaid = YES;
            } else {
                
            }
            [self addUtteranceToStatistics:speechEvent.text];
        } else {
            
        }
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
	PopABalloonEvaluation *layer = [PopABalloonEvaluation node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    // return the scene
	return scene;
}

@end
