//
//  BouncyBalls.m
//  speechadventure
//
//  Created by Steven Cruz on 3/14/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "BouncyBalls.h"

@implementation BouncyBalls {
    CCSprite *balls[3];
    CCTexture *litBall;
    CCTexture *ball;
    BOOL isBallBouncing[3];
    CCPhysicsNode *physicsWorld;
    BOOL * gameStarted;
    int basketCount;
    
    AVAudioPlayer * bounceSound, * basketSound;
}

+ (BouncyBalls *)scene
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
    basketCount = 0;
    
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"ballbounce"
                                               ofType:@"wav"]];
    bounceSound = [AVAudioPlayer alloc];
    bounceSound = [bounceSound initWithContentsOfURL:soundFile error:nil];
    soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                        pathForResource:@"reward"
                                        ofType:@"wav"]];
    basketSound = [AVAudioPlayer alloc];
    basketSound = [basketSound initWithContentsOfURL:soundFile error:nil];
    
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    [[OEManager sharedManager] swapModel:@"ballwords"];
    [[OEManager sharedManager] startListening];
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.4f green:0.0f blue:0.1f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    ball = [CCTexture textureWithFile:@"ball.png"];
    litBall = [CCTexture textureWithFile:@"ball_highlighted.png"];
    
    //adding physics
    physicsWorld = [CCPhysicsNode node];
    physicsWorld.contentSize = CGSizeMake(self.contentSize.width ,self.contentSize.height);
    //physicsWorld.positionType = CCPositionTypeNormalized;
    physicsWorld.gravity = ccp(0, -500);
    physicsWorld.debugDraw = YES;
    [self addChild:physicsWorld];
    physicsWorld.collisionDelegate = self;
    
    //add the area
    [self addCourtArea];
    [self addBasket];
    [self addBalls];
    
    [self setTargetSentence:@" "];
    [self intro];
    
    // done
    return self;
}

- (void) addBalls {
    //Add the three balls to the screen initially
    balls[0] = [CCSprite spriteWithTexture:ball];
    //balls[0].scale = (0.6);
    //balls[0].positionType = CCPositionTypeNormalized;
    balls[0].position  = ccp(self.contentSize.width/8,self.contentSize.height/2);
    balls[0].physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:balls[0].contentSize.height/3 andCenter:CGPointMake(balls[0].contentSize.width/2, balls[0].contentSize.height/2)];
    balls[0].physicsBody.collisionType = @"ball";
    balls[0].physicsBody.collisionGroup = @"ball";
    balls[0].physicsBody.elasticity = 1.6f;
    
    balls[1] = [CCSprite spriteWithTexture:ball];
    //balls[1].scale = (0.6);
    //balls[1].positionType = CCPositionTypeNormalized;
    balls[1].position  = ccp(self.contentSize.width*2/32,self.contentSize.height/2);
    balls[1].physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:balls[1].contentSize.height/3 andCenter:CGPointMake(balls[0].contentSize.width/2, balls[0].contentSize.height/2)];
    balls[1].physicsBody.collisionType = @"ball";
    balls[1].physicsBody.collisionGroup = @"ball";
    balls[1].physicsBody.elasticity = 1.6f;
    
    balls[2] = [CCSprite spriteWithTexture:ball];
    //balls[2].scale = (0.6);
    //balls[2].positionType = CCPositionTypeNormalized;
    balls[2].position  = ccp(self.contentSize.width*3/32,self.contentSize.height/2);
    balls[2].physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:balls[2].contentSize.height/3 andCenter:CGPointMake(balls[0].contentSize.width/2, balls[0].contentSize.height/2)];
    balls[2].physicsBody.collisionType = @"ball";
    balls[2].physicsBody.collisionGroup = @"ball";
    balls[2].physicsBody.elasticity = 1.6f;
    
    //add the balls
    [physicsWorld addChild:balls[0]];
    [physicsWorld addChild:balls[1]];
    [physicsWorld addChild:balls[2]];
}

- (void) addCourtArea {
    // Add Floor
    [self addWallWithRectAndElasticity:CGRectMake(0, 0, self.contentSize.width, 1) andElasticity:0.5f];
    
    // Add walls
    [self addWallWithRectAndElasticity:CGRectMake(0, 0, 2, self.contentSize.height) andElasticity:0.0f];
    [self addWallWithRectAndElasticity:CGRectMake(self.contentSize.width, 0, 2, self.contentSize.height) andElasticity:0.0f];
    
    // Add Ceiling
    [self addWallWithRectAndElasticity:CGRectMake(0, self.contentSize.height, self.contentSize.width, 1) andElasticity:0.0f];
    
    // Add basket physics components
    [self addShootLine:CGRectMake(0, self.contentSize.height*6/10, self.contentSize.width*3/10, 5)];
    [self addBasketLine:CGRectMake(self.contentSize.width*7/10, self.contentSize.height*6/10, self.contentSize.width, 1)];
}

-(void)addWallWithRectAndElasticity:(CGRect)rect andElasticity:(CGFloat) elasticity {
    CCPhysicsBody *floorBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    floorBody.type = CCPhysicsBodyTypeStatic;
    floorBody.elasticity = elasticity;
    CCNode *theFloor = [CCNode node];
    theFloor.physicsBody = floorBody;
    floorBody.collisionType = @"floor";
    [physicsWorld addChild:theFloor];
}

-(void)addBasket {
    CGRect rect = CGRectMake(0, 0, self.contentSize.width*3/10, 5);
    CCPhysicsBody *floorBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    floorBody.type = CCPhysicsBodyTypeStatic;
    floorBody.elasticity = 0.0f;
    CCSprite *theFloor = [CCSprite emptySprite];
    theFloor.contentSize = CGSizeMake(rect.size.width, rect.size.height);
    theFloor.physicsBody = floorBody;
    floorBody.collisionType = @"basket";
    theFloor.rotation = -60;
    theFloor.position = ccp(self.contentSize.width*9.5/10, self.contentSize.height*4.25/10);
    [physicsWorld addChild:theFloor];
    
    theFloor = nil;
    theFloor = [CCSprite emptySprite];
    theFloor.contentSize = CGSizeMake(rect.size.width, rect.size.height);
    floorBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    floorBody.type = CCPhysicsBodyTypeStatic;
    floorBody.elasticity = 0.0f;
    theFloor.physicsBody = floorBody;
    floorBody.collisionType = @"basket";
    theFloor.rotation = 60;
    theFloor.position = ccp(self.contentSize.width*7.75/10, self.contentSize.height*4.25/10);
    [physicsWorld addChild:theFloor];
    
}

-(void)addShootLine:(CGRect)rect {
    CCPhysicsBody *floorBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    floorBody.type = CCPhysicsBodyTypeStatic;
    floorBody.elasticity = .0f;
    CCNode *theFloor = [CCNode node];
    theFloor.physicsBody = floorBody;
    floorBody.collisionType = @"shootline";
    floorBody.collisionGroup = @"shootline";
    [physicsWorld addChild:theFloor];
    
}

-(void)addBasketLine:(CGRect)rect {
    CCPhysicsBody *floorBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    floorBody.type = CCPhysicsBodyTypeStatic;
    floorBody.elasticity = 0.0f;
    CCNode *theFloor = [CCNode node];
    theFloor.physicsBody = floorBody;
    floorBody.collisionType = @"basketLine";
    floorBody.collisionGroup = @"basketLine";
    [physicsWorld addChild:theFloor];
}


// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro
{
    // Add UI elements
    [self showAllUIElements];
    
    [self setSentenceInPhraseBox:@"Touch a ball!"];
}

-(void)killVelocity:(NSTimeInterval) dt {
    physicsWorld.gravity = ccp(0,-9.8f);
}

-(CCSprite *) getSelectedBall {
    CCSprite * returnBall;
    if(_ballZero == TRUE){
        returnBall = balls[0];
    }
    if(_ballOne == TRUE){
        returnBall = balls[1];
    }
    if(_ballTwo == TRUE){
        returnBall = balls[2];
    }
    return returnBall;
}

-(void) bounce {
    CCSprite * selectedBall = [self getSelectedBall];
    
    [selectedBall.physicsBody applyImpulse:CGPointMake(0, -500)];
}

-(void) setBallShootable {
    CCSprite * selectedBall = [self getSelectedBall];
    selectedBall.physicsBody.collisionType = @"ballShoot";
    selectedBall.physicsBody.collisionGroup = @"ballShoot";
    [selectedBall.physicsBody applyImpulse:CGPointMake(0, 400)];
    //selectedBall.position = ccp(self.contentSize.width*1/8,self.contentSize.height*6/8);
}

-(void) shoot {
    CCSprite * selectedBall = [self getSelectedBall];
    [selectedBall.physicsBody applyImpulse:CGPointMake(700, 250)];
}

-(void) resetBall {
    CCSprite * selectedBall = [self getSelectedBall];
    selectedBall.physicsBody.collisionType = @"ball";
    selectedBall.physicsBody.collisionGroup = @"ball";
}

-(void) unselectBall {
    _ballZero = FALSE;
    _ballOne = FALSE;
    _ballTwo = FALSE;
    
    balls[0].texture = ball;
    balls[1].texture = ball;
    balls[2].texture = ball;
    [self setTargetSentence:@" "];
    [self setSentenceInPhraseBox:@"Touch a ball!"];
    
}


// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    
    // Wait for user touch something
    if(!gameStarted) {
        // Start game timer
        [self setAndStartGameTimer:30];
        gameStarted = YES;
    }
    
    //If ball is touched, highlight for user
    if (CGRectContainsPoint(balls[0].boundingBox, touchLoc)) {
        balls[0].texture = litBall;
        balls[1].texture = ball;
        balls[2].texture = ball;
        _ballZero = TRUE;
        _ballOne = FALSE;
        _ballTwo = FALSE;
        if([[[balls[0] physicsBody] collisionType] isEqualToString:@"ballShoot"]) {
            [self setTargetSentence:@"BASKET BALL"];
            [self setSentenceInPhraseBox:@"Say \"Basket ball!\""];
        } else {
            [self setTargetSentence:@"BOUNCE BALL"];
            [self setSentenceInPhraseBox:@"Say \"Bounce ball!\""];
        }
        
    } else if (CGRectContainsPoint(balls[1].boundingBox, touchLoc)) {
        balls[0].texture = ball;
        balls[1].texture = litBall;
        balls[2].texture = ball;
        _ballZero = FALSE;
        _ballOne = TRUE;
        _ballTwo = FALSE;
        if([[[balls[1] physicsBody] collisionType] isEqualToString:@"ballShoot"]) {
            [self setTargetSentence:@"BASKET BALL"];
            [self setSentenceInPhraseBox:@"Say \"Basket ball!\""];
        } else {
            [self setTargetSentence:@"BOUNCE BALL"];
            [self setSentenceInPhraseBox:@"Say \"Bounce ball!\""];
        }
    } else if (CGRectContainsPoint(balls[2].boundingBox, touchLoc)) {
        balls[0].texture = ball;
        balls[1].texture = ball;
        balls[2].texture = litBall;
        _ballZero = FALSE;
        _ballOne = FALSE;
        _ballTwo = TRUE;
        if([[[balls[2] physicsBody] collisionType] isEqualToString:@"ballShoot"]) {
            [self setTargetSentence:@"BASKET BALL"];
            [self setSentenceInPhraseBox:@"Say \"Basket ball!\""];
        } else {
            [self setTargetSentence:@"BOUNCE BALL"];
            [self setSentenceInPhraseBox:@"Say \"Bounce ball!\""];
        }
    } else {
        [self unselectBall];
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA ball:(CCNode *)nodeB {
    NSLog(@"Ball hit ball");
    return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA ballShoot:(CCNode *)nodeB {
    NSLog(@"Ball hit ballshoot");
    //
    return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ballShoot:(CCNode *)nodeA basketLine:(CCNode *)nodeB {
    NSLog(@"Ball hit Basket Line");
    //[self resetBall];
    
    [self addToScore:[NSNumber numberWithInt:1]];
    nodeA.physicsBody.collisionType = @"basketLine";
    basketCount++;
    [basketSound play];
    if(basketCount ==3) [self changeLevel];
    return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ballShoot:(CCNode *)nodeA shootline:(CCNode *)nodeB {
    NSLog(@"Ballshoot hit line");
    [bounceSound play];
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA shootline:(CCNode *)nodeB {
    NSLog(@"Ball hit line");
    [self setTargetSentence:@"BASKET BALL"];
    [self setSentenceInPhraseBox:@"Say \"Basket ball!\""];
    [self setBallShootable];
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA shootline:(CCNode *)nodeB {
    NSLog(@"Ball solve");
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA floor:(CCNode *)nodeB {
    /*NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"ballbounce"
                                               ofType:@"wav"]];
    [self playSound:soundFile];*/
    return YES;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ballShoot:(CCNode *)nodeA floor:(CCNode *)nodeB {
    /*NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"ballbounce"
                                               ofType:@"wav"]];
    [self playSound:soundFile];*/
    return YES;
}



- (void) timedUnselect:(CCTime) dt {
    [self unselectBall];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    NSLog(@"Filtered Speech: %@", filteredSpeechText);
    if([self targetSentence].length > 1 && speechEvent.eventType == RapidEarsPartial) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool bounced = NO;
        if(phraseParts != nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            // Check which sentence
            if([self.targetSentence isEqualToString:@"BOUNCE BALL"]) {
                [self bounce];
                [self addSentenceToStatistics];
                [self showCheckmark];
                [self updatePreviousValidSpeech:speechEvent.text];
                [self addToScore:[NSNumber numberWithInt:1]];
                bounced = YES;
            } else if([self.targetSentence isEqualToString:@"BASKET BALL"]) {
                [self shoot];
                [self addSentenceToStatistics];
                [self showCheckmark];
                [self addToScore:[NSNumber numberWithInt:1]];
                [self updatePreviousValidSpeech:speechEvent.text];
                bounced = YES;
                [self scheduleOnce:@selector(timedUnselect:) delay:0.3f];
                //[self addSen:speechEvent.text];
            } else {
                
            }
            [self addUtteranceToStatistics:speechEvent.text];
        } else {
            
        }
        // Convert all uppercase strings to standard sentence format for display (first letter of phrase uppercase)
        //if(![self.targetSentence isEqual:@""]);
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        
        [self highlightPhraseParts:phraseParts];
        if(bounced) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f ];
    }
    // Convert all uppercase strings to standard sentence format for display (first letter of phrase uppercase)
    //if(![self.targetSentence isEqual:@""]);
    
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
    if ([basketSound isPlaying]) [basketSound stop];
    if ([bounceSound isPlaying]) [bounceSound stop];
    if (physicsWorld)[physicsWorld removeFromParentAndCleanup:YES];
    physicsWorld = nil;
    
    [super onExit];
}


@end
