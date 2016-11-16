//
//  SpaceInvaders.m
//  speechadventure
//
//  Created by Taylor Gotfrid on 7/14/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "SpaceInvaders.h"

@implementation SpaceInvaders {
    BOOL gameStarted;
    CCTimer * enemyFireTimer;
    CCPhysicsNode *physicsWorld;
    
    int enemyNumber;
    NSMutableArray *enemyShips;
    BOOL speechEnabled;
    
    AVAudioPlayer * explodeSound;
}

+ (SpaceInvaders *)scene {
    
    return [[self alloc] init];
}

- (id)init {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    speechEnabled = NO;
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    gameStarted = NO;
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"fireworks"];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"PoppingBalloon1"
                                               ofType:@"wav"]];
    explodeSound = [AVAudioPlayer alloc];
    explodeSound = [explodeSound initWithContentsOfURL:soundFile error:nil];
    
    //_collision = FALSE;
    physicsWorld = [CCPhysicsNode node];
    enemyShips = [NSMutableArray array];
    
    // Create a colored background
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    background = [CCSprite spriteWithImageNamed:@"space.png"];
    background.scale = 3;
    background.position = ccp(viewSize.width*.1f, viewSize.height*.1f);
    //background.anchorPoint = ccp(0,0);
    physicsWorld.collisionDelegate = self;
    [self.backgroundLayer addChild:background];
    
    spaceshipImage = [CCTexture textureWithFile:@"spaceship.png"];
    fireBlastImageFromSpaceShip = [CCTexture textureWithFile:@"dot.png"];
    fireBlastImageFromEnemyShip = [CCTexture textureWithFile:@"dot2.png"];
    enemyShipImage = [CCTexture textureWithFile:@"alienship.png"];
    
    
    //adding physics
    physicsWorld = [CCPhysicsNode node];
    physicsWorld.gravity = ccp(0,0);
    //physicsWorld.debugDraw = YES;
    physicsWorld.debugDraw = NO;
    physicsWorld.collisionDelegate = self;
    ///////////////////////////////////[physicsWorld collisionDelegate]
    [self addChild:physicsWorld];
    
    //spaceship
    spaceship = [CCSprite spriteWithTexture:spaceshipImage];
    spaceship.scale = (0.125);
    spaceship.position  = ccp(290,35);
    spaceship.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, spaceship.contentSize} cornerRadius:0];
    spaceship.physicsBody.collisionGroup = @"ship";
    spaceship.physicsBody.collisionType = @"spaceshipCollision";
    [physicsWorld addChild:spaceship];
    
    //boundary for ground
    //[self addWallWithRect:CGRectMake(0, 0, viewSize.width, 0)];
    //boundary for left wall
    [self addWallWithRect:CGRectMake(0, 0, 0, viewSize.height)];
    //boundary for right wall
    [self addWallWithRect:CGRectMake(0, viewSize.width, 0, viewSize.height)];
    //boundary for ceiling
    //[self addWallWithRect:CGRectMake(0, viewSize.height,viewSize.width, viewSize.height)];
    
    _gameOver = false;
    
    [self intro];
    
    // done
    return self;
}

//function to define walls as boundaries
-(void)addWallWithRect:(CGRect)rect {
    CCPhysicsBody *walls = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    walls.type = CCPhysicsBodyTypeStatic;
    CCNode *theWalls = [CCNode node];
    theWalls.physicsBody = walls;
    walls.collisionType = @"walls";
    [physicsWorld addChild:theWalls];
}

-(void)spawnEnemy:(CCTime)dt {
    float enemyHeight = (arc4random()%50)/100.0f + 0.3f; // This sets the height to the upper 60% of the screen, 0.3f-0.8f valid numbers.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    int enemyY = viewSize.height * enemyHeight;
    int enemyX = viewSize.width * 1.0f;
    CGPoint enemyStart = ccp(enemyX,enemyY);
    enemyShip = [CCSprite spriteWithTexture:enemyShipImage];
    enemyShip.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, enemyShip.contentSize} cornerRadius:0];
    enemyShip.physicsBody.collisionType = @"enemyShip";
    enemyShip.physicsBody.collisionGroup = @"enemy";
    enemyShip.scale = .04;
    enemyShip.position = enemyStart;
    [physicsWorld addChild:enemyShip];
    [enemyShips addObject:enemyShip];
    int time = 3;
    CGPoint screenLeft = ccp(0,enemyY);
    CCActionMoveTo *moveToLeftEdge = [CCActionMoveTo actionWithDuration:time  position:screenLeft];
    CCActionMoveTo *moveToRightEdge = [CCActionMoveTo actionWithDuration:time  position:enemyStart];
    CCActionSequence *moveLeftToRight = [CCActionSequence actions: moveToLeftEdge, moveToRightEdge, nil];
    CCActionRepeatForever *repeatMoveSequence = [CCActionRepeatForever actionWithAction:moveLeftToRight];
    [enemyShip runAction:repeatMoveSequence];
    
    // Spawn another enemy
    enemyNumber--;
    float randomDelay = (arc4random()%5)/10.0f + 0.2f; // Delay from 0.2 seconds to 0.7 seconds.
    if(enemyNumber > 0) {
        [self scheduleOnce:@selector(spawnEnemy:) delay:randomDelay];
    } else {
        [self setAndStartGameTimer:20]; // All enemies spawned, start the game.
        //[self setUserInteractionEnabled:YES];
        speechEnabled = YES;
        [self setRandomTargetSentence];
        [[OEManager sharedManager] startListening];
        enemyFireTimer = [self scheduleOnce:@selector(fireFromEnemyShip:) delay:randomDelay];
    }
    
}

- (void) setRandomTargetSentence {
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
}

//function to create the fire ball coming from enemyship
-(void)fireFromEnemyShip:(CCTime)dt {
    int shotsToFire = arc4random()%enemyShips.count / 2;
    for(int i = 0; i<shotsToFire; i++) {
        int shipNumber = arc4random()%enemyShips.count;
        CCSprite * chosenEnemyShip = [enemyShips objectAtIndex:shipNumber];
        
        fireBlastFromEnemyShip = [CCSprite spriteWithTexture:fireBlastImageFromEnemyShip];
        fireBlastFromEnemyShip.scale = (0.4);
        fireBlastFromEnemyShip.position = ccp(chosenEnemyShip.position.x,chosenEnemyShip.position.y - 40);
        fireBlastFromEnemyShip.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, fireBlastFromEnemyShip.contentSize} cornerRadius:0];
        fireBlastFromEnemyShip.physicsBody.collisionType = @"enemyShip";
        fireBlastFromEnemyShip.physicsBody.collisionGroup = @"enemy";
        [physicsWorld addChild:fireBlastFromEnemyShip];
        [fireBlastFromEnemyShip.physicsBody applyImpulse:CGPointMake(0, -100)];
        //CCColor *shotColor = [CCColor colorWithRed:0 green:0.2 blue:255];
    }
    [enemyFireTimer invalidate];
    float randomDelay = (arc4random()%5)/10.0f + 1.0; // Delay from 1.0 seconds to 1.5 seconds.
    enemyFireTimer = [self scheduleOnce:@selector(fireFromEnemyShip:) delay:randomDelay];
}

//function to create the fire ball coming from spaceship
-(void)fire {
    fireBlastFromSpaceShip = [CCSprite spriteWithTexture:fireBlastImageFromSpaceShip];
    fireBlastFromSpaceShip.scale = (0.4);
    fireBlastFromSpaceShip.position = ccp(spaceship.position.x,100);
    fireBlastFromSpaceShip.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, fireBlastFromSpaceShip.contentSize} cornerRadius:0];
    fireBlastFromSpaceShip.physicsBody.collisionGroup = @"ship";
    fireBlastFromSpaceShip.physicsBody.collisionType = @"fireBlastFromSpaceShip";
    [physicsWorld addChild:fireBlastFromSpaceShip];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair enemyFire:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    NSLog(@"Blast hit");
    return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fireBlastFromSpaceShip:(CCNode *)nodeA enemyShip:(CCNode *)nodeB {
    // Remove both
    [enemyShips removeObject:nodeB];
    [nodeB removeFromParentAndCleanup:YES];
    [nodeA removeFromParentAndCleanup:YES];
    [self addToScore:[NSNumber numberWithInt:1]];
    NSLog(@"Enemy Ship hit");
    [explodeSound play];
    // Are all enemies dead?
    if(enemyShips.count == 0) {
        [enemyFireTimer invalidate];
        [self changeLevel];
    }
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair spaceshipCollision:(CCNode *)nodeA enemyShip:(CCNode *)nodeB {
    // Remove both
    [nodeB removeFromParentAndCleanup:YES];
    [nodeA removeFromParentAndCleanup:YES];
    NSLog(@"Ship hit");
    [self changeLevel];
    return YES;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!gameStarted) {
        // BEGIN Zak Rewrite. Make everything a little more random.
        enemyNumber = arc4random()%6+4; // Between 4 and 10 enemies
        float randomDelay = (arc4random()%10)/10.0f + 0.2f; // Delay from 0.2 seconds to 1.2 seconds.
        [self scheduleOnce:@selector(spawnEnemy:) delay:randomDelay];
        gameStarted = YES;
    }
    CGPoint touchLoc = [touch locationInNode:(SKNode *)self];
    touchLoc.y = 25;
    [spaceship setPosition:touchLoc];
}

//function to move spaceship on x axis
-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:(SKNode *)self];
    touchLoc.y = 25;
    [spaceship setPosition:touchLoc];
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro {
    [self showAllUIElements];
    [self startDisplayingLevels];
    [self setSentenceInPhraseBox:@"Touch to move the ship!"];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent {
    if(self.userInteractionEnabled) {
        //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
        NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
        NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
        if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
            NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
            bool phraseSaid = NO;
            if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts])  {
                // Check which sentence
                if(_gameOver == false){
                    [self fire];
                    [self setRandomTargetSentence];
                    [self showCheckmark];
                    [self addSentenceToStatistics];
                    [self updatePreviousValidSpeech:speechEvent.text];
                    [fireBlastFromSpaceShip.physicsBody applyImpulse:CGPointMake(0, 200)];
                    fireBlastFromSpaceShip.physicsBody.affectedByGravity = NO;
                    [self addToScore:[NSNumber numberWithInt:1]];
                    phraseSaid = YES;
                    [self addUtteranceToStatistics:speechEvent.text];
                }
            } else {
                
            }
            // Convert all uppercase strings to standard sentence format for display (first letter of phrase uppercase)
            //if(![self.targetSentence isEqual:@""]);
            NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
            currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
            [self highlightPhraseParts:phraseParts];
            if(phraseSaid) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f ];
        }
    }
}

- (void) blankHighlightedWords:(CCTime)dt {
    [self setHighlightedWordsInPhraseBox:@" "];
}

// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender {
    // start spinning scene with transition
    [self changeLevel];
}

- (void)onExit {
    if (physicsWorld)[physicsWorld removeFromParentAndCleanup:true];
    physicsWorld = nil;
    if([explodeSound isPlaying]) [explodeSound stop];
    [enemyFireTimer invalidate];
    [super onExit];
}

@end
