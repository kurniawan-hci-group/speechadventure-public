//
//  Fireworks.m
//  speechadventure
//
//  Created by Zak Rubin on 10/10/14.
//  Copyright 2014 Zak Rubin. All rights reserved.
//


// Rockets->launchedRockets->Removed from play.
// Spawning moves openRocketLocations to rocketLocations
//
#import "Fireworks.h"

@implementation Fireworks
{
    NSMutableArray *rockets;
    NSMutableArray *launchedRockets;
    NSMutableArray *rocketLocations;
    NSMutableArray *openRocketLocations;
    NSNumber * rocketIndex;
    BOOL gameStarted;
    NSMutableArray *smokeTrails;
    CCSprite *word[3];
    NSMutableArray *rocketTextures;
    NSMutableArray *highlightedRocketTextures;
    
    NSMutableArray * rocketSmokes;
    
    AVAudioPlayer * whistleSound, * popSound;
}

+ (Fireworks *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    gameStarted = NO;
    smokeTrails = [NSMutableArray array];
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"fireworkwhistle"
                                               ofType:@"wav"]];
    whistleSound = [AVAudioPlayer alloc];
    whistleSound = [whistleSound initWithContentsOfURL:soundFile error:nil];
    soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                        pathForResource:@"PoppingBalloon1"
                                        ofType:@"wav"]];
    popSound = [AVAudioPlayer alloc];
    popSound = [popSound initWithContentsOfURL:soundFile error:nil];
    
    [whistleSound prepareToPlay];
    [popSound prepareToPlay];
    
    
    rockets = [NSMutableArray arrayWithCapacity:3];
    launchedRockets = [NSMutableArray array];
    rocketTextures = [NSMutableArray arrayWithObjects:[CCTexture textureWithFile:@"fireworks_rocket_red.png"], [CCTexture textureWithFile:@"fireworks_rocket_green.png"], [CCTexture textureWithFile:@"fireworks_rocket_blue.png"], nil];
    highlightedRocketTextures = [NSMutableArray arrayWithObjects:[CCTexture textureWithFile:@"fireworks_rocket_red_explode.png"], [CCTexture textureWithFile:@"fireworks_rocket_green_explode.png"], [CCTexture textureWithFile:@"fireworks_rocket_blue_explode.png"], nil];
    
    openRocketLocations = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], nil];
    rocketLocations = [NSMutableArray array];
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"fireworks"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sam_sprite_sheet.plist"];
    CCSprite * sam = [CCSprite spriteWithImageNamed:@"sam_right_0.png"];
    //Positioning the sprite
    sam.positionType = CCPositionTypeNormalized;
    sam.position  = ccp(0.2f, 0.25f);
    
    //Adding the Sprite to the Scene
    [self addChild:sam];
    
    // Add a rockets
    [self setupWordRockets];
    //rocketGroup = 0;
    
    [self intro];
    
    // done
    return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    [self showAllUIElements];
    //[self setTargetSentence:@"GO"];
    [self setSentenceInPhraseBox:@"Touch a Rocket!"];
}

- (void)setupWordRockets {
    while([openRocketLocations count] > 0) {
        CCSprite * newRocket;
        NSInteger newRocketColor = arc4random()%3;
        newRocket = [CCSprite spriteWithTexture:[rocketTextures objectAtIndex:newRocketColor]];
        //[rocket[0] setRotation:90.0];
        newRocket.scale = 0.15;
        [self setScaleFactorForSprite:newRocket];
        NSNumber * rocketPosition = [openRocketLocations objectAtIndex:0];
        int rocketIntPosition = [rocketPosition intValue];
        newRocket.positionType = CCPositionTypeNormalized;
        newRocket.position  = ccp(0.2*rocketIntPosition+0.45f,0.2f);
        [openRocketLocations removeObject:rocketPosition];
        [rocketLocations addObject:rocketPosition];
        [rockets addObject:newRocket];
        [self.activityLayer addChild:newRocket];
    }
    
}

- (void)launchRocket
{
    CCActionMoveTo *actionMove;
    actionMove = [CCActionMoveTo actionWithDuration:0.50f position:ccp(0.65f, 1.75f)];
    int rocketObjectIndex = [rocketLocations indexOfObject:rocketIndex];
    if([rockets count] > rocketObjectIndex) {
        CCSprite * rocket = [rockets objectAtIndex:rocketObjectIndex];
        [openRocketLocations addObject:rocketIndex];
        [rocketLocations removeObject:rocketIndex];
        [rocket runAction:actionMove];
        [launchedRockets addObject:rocket];
        [rockets removeObject:rocket];
        [whistleSound play];
        [self schedule:@selector(spawnRocketSmoke:) interval:0.1f repeat:2 delay:0.1f];
        [self scheduleOnce:@selector(explode:) delay:0.50f];
    }
}

- (void)launchRocket2
{
    //CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:ccp(0.5f, 0.9f)];
    //[rocket[0] runAction:actionMove];
    [self scheduleOnce:@selector(explode2:) delay:1];
}

- (void)spawnRocketSmoke:(CCTime)dt {
        //int index = i+(3*rocketGroup);
    CCSprite * rocket = [launchedRockets objectAtIndex:0];
    CCSprite *smokeTrail = [CCSprite spriteWithImageNamed:@"fireworks_cloud1.png"];
    smokeTrail.scale = 0.15;
    [self setScaleFactorForSprite:smokeTrail];
    smokeTrail.positionType = CCPositionTypeNormalized;
    smokeTrail.position = rocket.position;
    [smokeTrails addObject:smokeTrail];
    [self.activityLayer addChild:smokeTrail];
}

- (void)explode:(CCTime)dt
{
    for(int i=0; i<3; i++) {
        //int index = i+(3*rocketGroup);
        //[self.activityLayer removeChild:rocket[index] cleanup:YES];
    }
    CCSprite * rocket = [launchedRockets objectAtIndex:0];
    [rocket removeFromParent];
    [launchedRockets removeObject:rocket];
    //
    //rocketGroup = !rocketGroup;
    [self setupWordRockets];
    [popSound play];
    [self scheduleOnce:@selector(removeSmoke:) delay:0.0f];
}

- (void)removeSmoke:(CCTime)dt {
    NSMutableArray *toDelete = [NSMutableArray array];
    for (CCSprite*  smoke in smokeTrails) {
        [self.activityLayer removeChild:smoke];
        [toDelete addObject:smoke];
    }
    [smokeTrails removeObjectsInArray:toDelete];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    if(!gameStarted) {
        gameStarted = YES;
        
        // Start game timer
        [self setAndStartGameTimer:30];
    }
    
    for(int i=0; i<[rockets count]; i++) {
        CCSprite * rocket = [rockets objectAtIndex:i];
        if (CGRectContainsPoint(rocket.boundingBox, touchLoc)) {
            int randomPhrase = arc4random_uniform(3);
            switch(randomPhrase) {
                case 0:
                    [self setTargetSentence:@"BURST"];
                    break;
                case 1:
                    [self setTargetSentence:@"BOOM"];
                    break;
                case 2:
                    [self setTargetSentence:@"BLAST"];
                    break;
                default:
                    [self setTargetSentence:@"BOOM"];
                    break;
            }
            
            NSString * capitalizedTargetSentence = [[self targetSentence] capitalizedString];
            NSString * sentenceString = [NSString stringWithFormat:@"Say \"%@\"", capitalizedTargetSentence];
            [self setSentenceInPhraseBox:sentenceString];
            //NSLog(@"RocketColor");
            int rocketColor = [rocketTextures indexOfObject:[rocket texture]];
            if ([highlightedRocketTextures count] > rocketColor) rocket.texture = [highlightedRocketTextures objectAtIndex:rocketColor];
            int objectLocation = [rockets indexOfObject:rocket];
            if([rocketLocations count] > objectLocation) {
                //NSLog(@"RocketLocation");
                NSNumber * rocketLocation = [rocketLocations objectAtIndex:objectLocation];
                rocketIndex = rocketLocation;
                [rockets replaceObjectAtIndex:i withObject:rocket];
                //[self.foregroundLayer addChild:rocket];
                //[self launchRocket];
            }
            
        } else {
            int rocketColorIndex = [highlightedRocketTextures indexOfObject:[rocket texture]];
            if(rocketColorIndex < [highlightedRocketTextures count]) {
                rocket.texture = [rocketTextures objectAtIndex:rocketColorIndex];
                [rockets replaceObjectAtIndex:i withObject:rocket];
                [self setSentenceInPhraseBox:@"Touch a Rocket!"];
                [self setTargetSentence:@" "];
            }
        }
    }
    // Load word
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    if([self targetSentence].length > 1 && speechEvent.eventType == RapidEarsPartial) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool phraseSaid = NO;
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            [self launchRocket];
            [self showCheckmark];
            [self setTargetSentence:@" "];

            [self updatePreviousValidSpeech:speechEvent.text];
            [self addToScore:[NSNumber numberWithInt:1]];
            phraseSaid = YES;
            [self addSentenceToStatistics];
            [self addUtteranceToStatistics:speechEvent.text];
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

- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
    [self setSentenceInPhraseBox:@"Touch a Rocket!"];
    [self setTargetSentence:@" "];
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
    if([whistleSound isPlaying]) [whistleSound stop];
    if([popSound isPlaying]) [popSound stop];
    [super onExit];
}

@end
