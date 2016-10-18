//
//  ApraxiaLevel3.m
//  speechadventure
//  word scramble game
//
//  Created by Zak Rubin on 4/15/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "ApraxiaLevel3.h"

@implementation ApraxiaLevel3
{
    //find a way to have buckets be automatically right size
    CCSprite *buckets[1];
    CCSprite *letters[26];
    NSMutableArray *dictionary[10];
}


+ (ApraxiaLevel3 *)scene
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
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"ApraxiaLevel3"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self addChild:background];
    
    [self intro];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    [self showListeningEar];
    [self showBackButton];
    /*NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"TemplatePrompt"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile delay:2];*/
    //[self makeCorn];
    //[self makeGrass];
    [self setAndStartGameTimer:20];
    [self showGameTimer];
    //[self scheduleOnce:@selector(timeUp:) delay:20];
}

- (void)makeDictionary
{
    //dictionary[10] = [@"rope" , @"sandal", @"think", @"third", @"shake", @"shower", @"laugh", @"lemon", @"tiger", @"pepper", nil];
    
}


- (void)makeBuckets
{
    //word = dictionary[i].length;
    //spaces for letters to be dragged to
    for(int i = 0; i <= 12; i++){
        buckets[i] = [CCSprite spriteWithImageNamed:@"smallBox.png"];
        //cards[i].scale = .04;
        buckets[i].positionType = CCPositionTypeNormalized;
        buckets[i].position = ccp(0.25+0.25*(i%3),0.2+0.2*(i%4));
        [self setScaleFactorForSprite:buckets[i]];
        [self addChild:buckets[i]];
    }
}


- (void)makeLetters
{
//    //take in from an array of words.
//    for(int i = 0; i <= 26; i++){
//        //letters[26] = [CCSprite spriteWithImageNamed:@"A.png", @"B.png", @"C.png", @"D.png", @"E.png", @"F.png", @"G.png", @"H.png", @"I.png", @"J.png", @"K.png", @"L.png", @"M.png", @"N.png", @"O.png", @"P.png", @"Q.png", @"R.png", @"S.png", @"T.png", @"U.png",@"V.png", @"W.png", @"X.png", @"Y.png", @"Z.png", nil ];
//        //cards[i].scale = .04;
//        letters[i].positionType = CCPositionTypeNormalized;
//        letters[i].position = ccp(0.25+0.25*(i%3),0.2+0.2*(i%4));
//        [self setScaleFactorForSprite:letters[i]];
//        [self addChild:letters[i]];
//
    
}




- (void)eatCorn
{
   
}

- (void)eatGrass
{
  
}

- (void)displaySentenceIfCowNearFood {
    
    
}

- (void)moo
{
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"moo"
                                               ofType:@"wav"]];
    [self pauseListeningAndPlaySound:soundFile];
    
}

-(void) timeUp:(CCTime)dt{
    [[OEManager sharedManager] pauseListening];
    [[OEManager sharedManager] recordingCutoff];
    [self changeLevel];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //CGPoint touchLoc = [touch locationInNode:(SKNode *)self];
    // Log touch location
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    //[self displaySentenceIfCowNearFood];
    //[cow setPosition:touchLoc];
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //CGPoint touchLoc = [touch locationInNode:(SKNode *)self];
    // Log touch location
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    //[self displaySentenceIfCowNearFood];
    //[cow setPosition:touchLoc];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    
    if(speechEvent.eventType == RapidEarsPartial) {
        if (([speechEvent.text rangeOfString:@"EAT CORN"].location != NSNotFound)) {
            [self eatCorn];
            [self showCheckmark];
        } else if (([speechEvent.text rangeOfString:@"EAT GRASS"].location != NSNotFound)) {
            [self eatGrass];
            [self showCheckmark];
        } else {
            
        }
    }
    
    if(speechEvent.eventType == OpenEarsStateChange) {
        
    }
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

@end
