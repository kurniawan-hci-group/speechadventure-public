//
//  ApraxiaLevel1.m
//  speechadventure
//  memory match game
//
//  Created by Annie Pugliese on 4/15/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//  rain (/r/), rocket (/r/), seal (/s/), lock (/l/), ladder (/er/) and hammer (/er/)
//

#import "ApraxiaLevel1.h"
#import <OpenEars/OEAcousticModel.h>

@implementation ApraxiaLevel1
{
    CCSprite *cards[12];
    NSString *cardWord[12];
    NSString *lastCardWord;
    int currentCardFlipped, lastCardFlipped;
    NSMutableArray * nonRandomCardWords;
    int cardsFlipped;
    BOOL gameStarted;
    double cowSize;
}


+ (ApraxiaLevel1 *)scene
{
	return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    gameStarted = NO;
    // Initialize the starting wordlist
    nonRandomCardWords = [NSMutableArray arrayWithObjects:@"HAMMER", @"HAMMER", @"LADDER", @"LADDER", @"RAIN", @"RAIN", @"ROCKET", @"ROCKET", @"SEAL", @"SEAL", @"RABBIT", @"RABBIT", nil];
    
    nonRandomCardWords = [NSMutableArray arrayWithObjects:@"BOAT", @"BOAT", @"LADDER", @"LADDER", @"TEDDY", @"TEDDY", @"BALL", @"BALL", @"BIRD", @"BIRD", @"RABBIT", @"RABBIT", nil];
    
    cardsFlipped = 0;
    lastCardFlipped = -5;
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"apraxialevel1plosives"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self addChild:background];
    
    // Start the game
    [self intro];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    // Show all the HUD elements: Back button, score, timer, help box, and listening ear
    [self showAllUIElements];
    // Create the cards, randomize their placement, and add them to the game
    [self makeCards];
    // Set the phrase box to say Click Cards!
    [self setSentenceInPhraseBox:@"Click cards!"];
}

- (void)makeCards
{
    for(int i = 0; i < 12; i++){
        cards[i] = [CCSprite spriteWithImageNamed:@"cardback.png"];
        cards[i].scale *= .3;
        cards[i].positionType = CCPositionTypeNormalized;
        cards[i].position = ccp(0.25+0.25*(i%3),0.1+0.225*(i%4));
        [self setScaleFactorForSprite:cards[i]];
        [self addChild:cards[i]];
        
        // Pick a card out of what's left in the nonRandomWords array and add it to the cardWord array
        // This ensures we use all of the words.
        int randomCard = arc4random()%[nonRandomCardWords count];
        cardWord[i] = [nonRandomCardWords objectAtIndex:randomCard];
        // Remove the card chosen from the nonRandomCardWords array
        [nonRandomCardWords removeObjectAtIndex:randomCard];
    }
}

- (void)match
{
    NSLog(@"Matched");
    [self setTargetSentence:lastCardWord];
    NSString *formattedCardWord = [lastCardWord capitalizedString];
    NSString *formattedSentence = [NSString stringWithFormat:@"Say \"%@\"!", formattedCardWord];
    [self setSentenceInPhraseBox:formattedSentence];
    
}

- (void)setCardImage:(int)cardToFlip
{
    // Grab the string used
    NSString * wordOnCard = cardWord[cardToFlip];
    
    // Convert the string to lowercase so that we can grab the sprite
    wordOnCard = [wordOnCard lowercaseString];
    // Form the sprite name and set the card selected to the spriteName
    NSString * spriteName = [NSString stringWithFormat:@"%@.png", wordOnCard];
    cards[cardToFlip] = [CCSprite spriteWithImageNamed:spriteName];
}

- (void)flipCard:(int)cardToFlip {
    //for (int i =0; i<2; i++){
    NSLog(@"Flipping Card %d",cardToFlip);
    CCActionFlipY *flipAction = [CCActionFlipY actionWithFlipY:YES];
    [cards[cardToFlip] runAction:flipAction];
    if([[self children] containsObject:cards[cardToFlip]]){
        [self removeChild:cards[cardToFlip]];
    }
    [self setCardImage:cardToFlip];
    //cards[i].positionType = CCPositionTypeNormalized;
    cards[cardToFlip].positionType = CCPositionTypeNormalized;
    cards[cardToFlip].scale = M_PI/10;
    cards[cardToFlip].position = ccp(0.25+0.25*(cardToFlip%3),0.1+0.225*(cardToFlip%4));
    [self setScaleFactorForSprite:cards[cardToFlip]];
    [self addChild:cards[cardToFlip]];
    
    currentCardFlipped = cardToFlip;
    NSString * wordOnCard = cardWord[cardToFlip];
    cardsFlipped++;
    if (cardsFlipped == 1){
        lastCardWord = cardWord[cardToFlip];
        lastCardFlipped = cardToFlip;
    } else if (cardsFlipped == 2){
        if([wordOnCard isEqualToString:lastCardWord]) {
            [self match];
            self.userInteractionEnabled = NO;
        } else {
            NSLog(@"No Match");
            [self setSentenceInPhraseBox:@"Try again!"];
            cardsFlipped = 0;
            [self setTargetSentence:@" "];
            [self scheduleOnce:@selector(scheduledUnflip:) delay:0.5f];
            self.userInteractionEnabled = NO;
        }
    }
}

- (void)scheduledUnflip:(CCTime) dt {
    [self unflip:currentCardFlipped];
    [self unflip:lastCardFlipped];
    lastCardFlipped = -5;
    [self setSentenceInPhraseBox:@"Click cards!"];
    self.userInteractionEnabled = YES;
}

- (void)unflip:(int) cardToUnflip {
    if([[self children] containsObject:cards[cardToUnflip]]){
        [self removeChild:cards[cardToUnflip]];
    }
    cards[cardToUnflip] = [CCSprite spriteWithImageNamed:@"cardback.png"];
    cards[cardToUnflip].scale *= .3;
    cards[cardToUnflip].positionType = CCPositionTypeNormalized;
    cards[cardToUnflip].position = ccp(0.25+0.25*(cardToUnflip%3),0.1+0.225*(cardToUnflip%4));
    [self setScaleFactorForSprite:cards[cardToUnflip]];
    [self addChild:cards[cardToUnflip]];
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
    if(!gameStarted){
        // Start the game timer at 20 seconds
        [self setAndStartGameTimer:20];
        gameStarted = YES;
    }
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGPoint touchLoc = [touch locationInNode:(SKNode *)self];
    touchLoc.x = touchLoc.x/winSize.width;
    touchLoc.y = touchLoc.y/winSize.height;
    // Log touch location
    for(int i = 0; i <= 11; i++){
        if(sqrt(pow((touchLoc.x - cards[i].position.x),2) + pow((touchLoc.y - cards[i].position.y),2)) <= 0.07) {
            if(i != lastCardFlipped) [self flipCard:i];
        }
    }
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    //[cow setPosition:touchLoc];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    [self updatePreviousValidSpeech:speechEvent.text];
    if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool phraseSaid = NO;
        if (phraseParts!= nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            //[self eatGrass];
            [cards[currentCardFlipped] removeFromParent];
            [cards[lastCardFlipped] removeFromParent];
            cards[currentCardFlipped] = nil;
            cards[lastCardFlipped] = nil;
            [self setTargetSentence:@" "];
            //[self setSentenceInPhraseBox:@"Click cards!"];
            cardsFlipped = 0;
            [self showCheckmark];
            self.userInteractionEnabled = YES;
            phraseSaid = YES;
            [self addSentenceToStatistics];
            [self addToScore:[NSNumber numberWithInteger:1]];
            NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                       pathForResource:@"reward"
                                                       ofType:@"wav"]];
            [self playSound:soundFile];
        } else if (([speechEvent.text rangeOfString:@"EAT GRASS"].location != NSNotFound)) {
            //[self eatGrass];
            [self showCheckmark];
        } else {
            
        }
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        [self highlightPhraseParts:phraseParts];
        if(phraseSaid) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f ];
    }
}

- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
    [self setSentenceInPhraseBox:@"Click cards!"];
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
