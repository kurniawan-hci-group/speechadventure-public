//
//  TemplateLevel.m
//  speechadventure
//  This file is a base template level that demonstrates basic game features that use speech recognition.
//  It's recommended to start with this game as a base and understand how everything works.
//
//  Created by Zak Rubin on 4/15/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "TemplateLevel.h"

@implementation TemplateLevel
{
    CCSprite *cow;
    
    CCSprite *corn;
    CCSprite *grass;
    CCSprite *boat;
    CCSprite *ball;
    CCSprite *ladder;
    double cowSize;
    bool gameStarted;
    AVAudioPlayer * moo;
}


+ (TemplateLevel *)scene
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
    
    gameStarted = NO;
    
    moo = [AVAudioPlayer alloc];
    moo = [moo initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                                pathForResource:@"moo"
                                                                                ofType:@"wav"]]
                               error:nil];
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"templateplosives"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self addChild:background];
    [self startGame];
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)startGame
{
    
    // Add a sprite
    cow = [CCSprite spriteWithImageNamed:@"cow.png"];
    cowSize = 0.5f;
    cow.scale = cowSize;
    cow.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:cow];
    
    // Add game elements
    //[self makeCorn];
    //[self makeGrass];
    
    // Add plosive game elements
    [self makeBall];
    [self makeLadder];
    [self makeBoat];
    
    // Add UI elements
    [self showAllUIElements];
    
    // Add sentence
    [self setSentenceInPhraseBox:@"Drag the cow!"];
}

- (void) makeLadder {
    ladder = [CCSprite spriteWithImageNamed:@"ladder.png"];
    CGFloat x = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.width*2/3;
    CGFloat y = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.height*2/3;
    ladder.position  = ccp(x,y);
    ladder.scale = 0.75f;
    [self addChild:ladder];
}
- (void) makeBoat {
    boat = [CCSprite spriteWithImageNamed:@"boat.png"];
    CGFloat x = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.width*2/3;
    CGFloat y = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.height*2/3;
    boat.position  = ccp(x,y);
    boat.scale = 0.75f;
    [self addChild:boat];
}
- (void) makeBall {
    ball = [CCSprite spriteWithImageNamed:@"ball.png"];
    CGFloat x = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.width*2/3;
    CGFloat y = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.height*2/3;
    ball.position  = ccp(x,y);
    ball.scale = 0.75f;
    [self addChild:ball];
}

- (void)makeCorn
{
    // Add corn
    corn = [CCSprite spriteWithImageNamed:@"corn.png"];
    CGFloat x = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.width*2/3;
    CGFloat y = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.height*2/3;
    corn.position  = ccp(x,y);
    corn.scale = 0.75f;
    [self addChild:corn];
}

- (void)makeGrass
{
    // Add grass
    grass = [CCSprite spriteWithImageNamed:@"grass.png"];
    CGFloat x = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.width*2/3;
    CGFloat y = (CGFloat) random()/(CGFloat) RAND_MAX * self.contentSize.height*2/3;
    grass.position  = ccp(x,y);
    [self addChild:grass];
}


- (void)eatCorn
{
    if(sqrt(pow((cow.position.x - corn.position.x),2) + pow((cow.position.y - corn.position.y),2)) <= 50)
    {
        [self removeChild:corn cleanup:YES];
        [self moo];
        [self makeCorn];
    }
}

- (void)eatGrass
{
    if(sqrt(pow((cow.position.x - grass.position.x),2) + pow((cow.position.y - grass.position.y),2)) <= 50)
    {
        [self removeChild:grass cleanup:YES];
        [self moo];
        [self makeGrass];
    }
}

- (void)eatBall
{
    if(sqrt(pow((cow.position.x - ball.position.x),2) + pow((cow.position.y - ball.position.y),2)) <= 50)
    {
        [self removeChild:ball cleanup:YES];
        [self moo];
        [self makeBall];
    }
}

- (void)eatBoat
{
    if(sqrt(pow((cow.position.x - boat.position.x),2) + pow((cow.position.y - boat.position.y),2)) <= 50)
    {
        [self removeChild:boat cleanup:YES];
        [self moo];
        [self makeBoat];
    }
}

- (void)eatLadder
{
    if(sqrt(pow((cow.position.x - ladder.position.x),2) + pow((cow.position.y - ladder.position.y),2)) <= 50)
    {
        [self removeChild:ladder cleanup:YES];
        [self moo];
        [self makeLadder];
    }
}

- (void)displaySentenceIfCowNearFood {
    [self hideListeningEar];
    [self showListeningEar];
    if(sqrt(pow((cow.position.x - corn.position.x),2) + pow((cow.position.y - corn.position.y),2)) <= 50) {
        [self setSentenceInPhraseBox:@"Say \"Eat corn!\""];
        [self setTargetSentence:@"EAT CORN"];
    } else if(sqrt(pow((cow.position.x - grass.position.x),2) + pow((cow.position.y - grass.position.y),2)) <= 50) {
        [self setSentenceInPhraseBox:@"Say \"Eat grass!\""];
        [self setTargetSentence:@"EAT GRASS"];
    } else if(sqrt(pow((cow.position.x - ladder.position.x),2) + pow((cow.position.y - ladder.position.y),2)) <= 50) {
        [self setSentenceInPhraseBox:@"Say \"Eat ladder!\""];
        [self setTargetSentence:@"EAT LADDER"];
    } else if(sqrt(pow((cow.position.x - boat.position.x),2) + pow((cow.position.y - boat.position.y),2)) <= 50) {
        [self setSentenceInPhraseBox:@"Say \"Eat boat!\""];
        [self setTargetSentence:@"EAT BOAT"];
    } else if(sqrt(pow((cow.position.x - ball.position.x),2) + pow((cow.position.y - ball.position.y),2)) <= 50) {
        [self setSentenceInPhraseBox:@"Say \"Eat ball!\""];
        [self setTargetSentence:@"EAT BALL"];
    } else {
        [self setSentenceInPhraseBox:@"Drag the cow!"];
        [self setTargetSentence:@" "];
    }
    
}

- (void)moo
{
    [self addToScore:[NSNumber numberWithInt:1]];
    cowSize += 0.05f;
    cow.scale = cowSize;
    [moo play];
}

-(void) timeUp:(CCTime)dt{
    [[OEManager sharedManager] pauseListening];
    [[OEManager sharedManager] recordingCutoff];
    [self setLevelName:@"EatCornGrass"];
    [self changeLevel];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!gameStarted){
        gameStarted = YES;
        // Start game timer
        [self setAndStartGameTimer:20];
        
    }
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    [self displaySentenceIfCowNearFood];
    [cow setPosition:touchLoc];
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    [self displaySentenceIfCowNearFood];
    [cow setPosition:touchLoc];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:speechEvent.text];
        bool phraseSaid = NO;
        if (phraseParts!= nil && [self checkIfPhraseExists:@"EAT CORN" currentHypothesis:phraseParts]) {
            [self eatCorn];
            [self addSentenceToStatistics];
            [self showCheckmark];
            phraseSaid = YES;
        } else if (phraseParts!= nil && [self checkIfPhraseExists:@"EAT GRASS" currentHypothesis:phraseParts]) {
            [self eatGrass];
            [self addSentenceToStatistics];
            [self showCheckmark];
            phraseSaid = YES;
        } else if (phraseParts!= nil && [self checkIfPhraseExists:@"EAT BOAT" currentHypothesis:phraseParts]) {
            [self eatBoat];
            [self addSentenceToStatistics];
            [self showCheckmark];
            phraseSaid = YES;
        } else if (phraseParts!= nil && [self checkIfPhraseExists:@"EAT LADDER" currentHypothesis:phraseParts]) {
            [self eatLadder];
            [self addSentenceToStatistics];
            [self showCheckmark];
            phraseSaid = YES;
        } else if (phraseParts!= nil && [self checkIfPhraseExists:@"EAT BALL" currentHypothesis:phraseParts]) {
            [self eatBall];
            [self addSentenceToStatistics];
            [self showCheckmark];
            phraseSaid = YES;
        } else {
            
        }
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        
        [self highlightPhraseParts:phraseParts];
        if(phraseSaid) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f ];
    }
    
    if(speechEvent.eventType == OpenEarsStateChange) {
        
    }
}

- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
}

// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [self changeLevel];
}


// -----------------------------------------------------------------------

- (void)onExit {
    if([moo isPlaying]) [moo stop];
    [super onExit];
}

@end
