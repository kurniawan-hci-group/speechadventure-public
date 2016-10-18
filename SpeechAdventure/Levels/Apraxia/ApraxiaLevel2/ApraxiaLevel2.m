//
//  ApraxiaLevel2.m
//  prize wheel game
//  speechadventure
//
//  Created by Zak Rubin on 4/15/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "ApraxiaLevel2.h"

@implementation ApraxiaLevel2
{
    CCNode * wheel;
    CCSprite *wheelBack;
    CCSprite * highlight;
    NSMutableArray *wordOptions;
    NSMutableArray *wheelWords;
    NSMutableArray *wheelObjects;
    NSMutableArray *completedObjects;
    NSMutableArray *objectsOut;
    NSString *slotWord[3];
    int distance;
    int currentWheelSlice;
    BOOL gameStarted;
    BOOL spinAllowed;
    AVAudioPlayer * spinSound, * shortSpinSound, * rewardSound;
}

+ (ApraxiaLevel2 *)scene
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
    spinAllowed = YES;
    
    wordOptions = [NSMutableArray arrayWithObjects:@"BOAT", @"LADDER", @"TEDDY", @"BALL", @"BIRD", @"RABBIT", nil];
    wheelObjects = [NSMutableArray array];
    wheelWords = [NSMutableArray array];
    objectsOut = [NSMutableArray array];
    
    
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"longspin"
                                               ofType:@"wav"]];
    spinSound = [AVAudioPlayer alloc];
    spinSound = [spinSound initWithContentsOfURL:soundFile error:nil];
    soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                        pathForResource:@"singlespin"
                                        ofType:@"wav"]];
    shortSpinSound = [AVAudioPlayer alloc];
    shortSpinSound = [shortSpinSound initWithContentsOfURL:soundFile error:nil];
    soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                        pathForResource:@"reward"
                                        ofType:@"wav"]];
    rewardSound = [AVAudioPlayer alloc];
    rewardSound = [rewardSound initWithContentsOfURL:soundFile error:nil];
    
    [spinSound prepareToPlay];
    [shortSpinSound prepareToPlay];
    [rewardSound prepareToPlay];
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"apraxialevel1plosives"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self addChild:background];
    
    [self makeWheel];
    [self addButtons];
    
    [self intro];
    
    // So it took Zak 9 hours to realize that this is the only line that's needed to determine what part of the circle is currently selected.
    currentWheelSlice = 1;
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    [self showAllUIElements];
    [self setSentenceInPhraseBox:@"Touch the Spin Button!"];
    
}

- (void)addButtons {
    CCButton *spinButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_small.png"]];
    [spinButton setTarget:self selector:@selector(spinButtonPushed:)];
    spinButton.positionType = CCPositionTypeNormalized;
    spinButton.position = ccp(0.9f, 0.3f);
    spinButton.scaleY *= 2.0f;
    [self addChild:spinButton];
    
    CCLabelTTF * spinLabel;
    spinLabel = [CCLabelTTF labelWithString:@"Spin" fontName:@"ArialMT" fontSize:48.0];
    spinLabel.color = [CCColor colorWithCcColor3b:ccBLACK];
    spinLabel.positionType = CCPositionTypeNormalized;
    spinLabel.position = ccp(0.85f, 0.3f);
    spinLabel.anchorPoint = ccp(0,0.5f);
    [self addChild: spinLabel];
}

- (void) addRotationButtons {
    CCButton *rotateLeftButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow_selected.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"]];
    [rotateLeftButton setTarget:self selector:@selector(rotateLeftButtonPushed:)];
    rotateLeftButton.positionType = CCPositionTypeNormalized;
    rotateLeftButton.position = ccp(0.2f, 0.5f);
    [self addChild:rotateLeftButton];
    
    CCButton *rotateRightButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow_selected.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"backarrow.png"]];
    [rotateRightButton setTarget:self selector:@selector(rotateRightButtonPushed:)];
    rotateRightButton.positionType = CCPositionTypeNormalized;
    rotateRightButton.position = ccp(0.8f, 0.5f);
    rotateRightButton.rotation = 180.0f;
    [self addChild:rotateRightButton];
}

- (void)makeWheel
{
    // First add the wheel
    wheel = [CCNode node];
    wheelBack = [CCSprite spriteWithImageNamed:@"spinWheel.png"];
    wheel.contentSize = wheelBack.contentSize;
    [wheel addChild:wheelBack];
    wheel.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:wheel];
    
}

- (void) moveInNewObjectsToWheel {
    // Add new objects to the wheel until there are 3.
    while([wheelObjects count] < 3) {
        CGPoint destination;
        CCSprite *newWheelImage;
        
        distance = 120;
        NSString * targetWord = [wordOptions objectAtIndex:arc4random()%wordOptions.count];
        
        [wheelWords addObject:targetWord];
        
        // Convert the string to lowercase so that we can grab the sprite
        targetWord = [targetWord lowercaseString];
        // Form the sprite name and set the card selected to the spriteName
        NSString * spriteName = [NSString stringWithFormat:@"%@.png", targetWord];
        newWheelImage = [CCSprite spriteWithImageNamed:spriteName];
        
        //int angularDestination = 60*
        
        destination.x = sinf(CC_DEGREES_TO_RADIANS(60+120*[wheelObjects count])) * distance;
        destination.y = cosf(CC_DEGREES_TO_RADIANS(60+120*[wheelObjects count])) * distance;
        destination = ccpAdd(wheelBack.position, destination);
        CGPoint offScreen = CGPointMake(destination
                                        .x*15, destination.y*15);
        
        [newWheelImage setPosition: offScreen];
        newWheelImage.scale = 0.5;
        [wheelObjects addObject:newWheelImage];
        [wheel addChild:newWheelImage];
    
        //[object removeFromParent];
        CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.5f position:destination];
        [newWheelImage runAction:actionMove];
    }
}

- (void) moveOutOldObjectsFromWheel {
    if(highlight) {
        [highlight removeFromParent];
        highlight = nil;
    }
    while([wheelObjects count]) {
        CCSprite * object = [wheelObjects objectAtIndex:0];
        //[object removeFromParent];
        CGPoint offScreen = CGPointMake(object.position.x*15, object.position.y*15);
        CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.5f position:offScreen];
        [object runAction:actionMove];
        [objectsOut addObject:object];
        [wheelObjects removeObjectAtIndex:0];
        [wheelWords removeObjectAtIndex:0];
    }
}

- (void) highlightObject {
    CCSprite * object = [wheelObjects objectAtIndex:currentWheelSlice];
    if(highlight) {
        [highlight removeFromParent];
        highlight = nil;
        [self setTargetSentence:@" "];
        [self setSentenceInPhraseBox:@"Rotate or Spin!"];
    }
    if(![objectsOut containsObject:object]) {
        highlight = [CCSprite spriteWithTexture:object.texture];
        highlight.scale = object.scale;
        highlight.position = object.position;
        highlight.scale *= 1.50;
        [highlight setColor:[CCColor colorWithCcColor3b:ccYELLOW]];
        
        [wheel addChild:highlight];
        [self showObjectTargetWord];
    }
}

- (void) showObjectTargetWord {
    NSString * targetWord = [wheelWords objectAtIndex:currentWheelSlice];
    [self setTargetSentence:targetWord];
    NSString * capitalizedTargetSentence = [[self targetSentence] capitalizedString];
    NSString * sentenceString = [NSString stringWithFormat:@"Say \"%@\"", capitalizedTargetSentence];
    [self setSentenceInPhraseBox:sentenceString];
}

-(void)spinWheel
{
    int randomRotation = 1080;
    CCActionRotateBy *actionMove = [CCActionRotateBy actionWithDuration:1 angle:randomRotation];
    [wheel runAction:actionMove];
    [spinSound play];
}

-(void)rotateWheelRight
{
    CCActionRotateBy *actionMove = [CCActionRotateBy actionWithDuration:0.25f angle:120];
    [wheel runAction:actionMove];
    [shortSpinSound play];
}

-(void)rotateWheelLeft
{
    CCActionRotateBy *actionMove = [CCActionRotateBy actionWithDuration:0.25f angle:-120];
    [wheel runAction:actionMove];
    [shortSpinSound play];
}

- (void) scheduledHighlight:(CCTime)dt {
    [self highlightObject];
}

- (void) spinEnable:(CCTime)dt {
    spinAllowed = YES;
}

- (void) moveCurrentObjectOffscreen {
    CCSprite * object = [wheelObjects objectAtIndex:currentWheelSlice];
    //[object removeFromParent];
    CGPoint offScreen = CGPointMake(object.position.x*15, object.position.y*15);
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.5f position:offScreen];
    [object runAction:actionMove];
    [objectsOut addObject:object];
    [rewardSound play];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    // We want only one word at a time
    [self updatePreviousValidSpeech:speechEvent.text];
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    if([self targetSentence].length > 1 && speechEvent.eventType == RapidEarsPartial) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool phraseSaid = NO;
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            [self moveCurrentObjectOffscreen];
            [self updatePreviousValidSpeech:speechEvent.text];
            [self showCheckmark];
            phraseSaid = YES;
            [self addSentenceToStatistics];
            [self addToScore:[NSNumber numberWithInteger:1]];
            [self highlightObject];
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

- (void)spinButtonPushed:(id)sender
{
    if(!gameStarted) {
        
        [self setAndStartGameTimer:30];
        gameStarted = YES;
        [self addRotationButtons];
    }
    if(spinAllowed) {
        spinAllowed = NO;
        [self moveOutOldObjectsFromWheel];
        [self spinWheel];
        [self moveInNewObjectsToWheel];
        [self scheduleOnce:@selector(scheduledHighlight:) delay:1.05f];
        [self scheduleOnce:@selector(spinEnable:) delay:1.0f];
    }
}

- (void)rotateLeftButtonPushed:(id)sender
{
    if(spinAllowed) {
        spinAllowed = NO;
        currentWheelSlice = (currentWheelSlice+1)%3;
        [self rotateWheelLeft];
        [self highlightObject];
        [self scheduleOnce:@selector(spinEnable:) delay:0.6f];
    }
}

- (void)rotateRightButtonPushed:(id)sender
{
    if(spinAllowed) {
        spinAllowed = NO;
        currentWheelSlice = (currentWheelSlice-1)%3;
        if(currentWheelSlice < 0) currentWheelSlice = 2;
        [self rotateWheelRight];
        [self highlightObject];
        [self scheduleOnce:@selector(spinEnable:) delay:0.6f];
    }
}


// -----------------------------------------------------------------------

- (void)onExit {
    if([rewardSound isPlaying]) [rewardSound stop];
    if([spinSound isPlaying]) [spinSound stop];
    if([shortSpinSound isPlaying]) [shortSpinSound stop];
    [super onExit];
}

@end
