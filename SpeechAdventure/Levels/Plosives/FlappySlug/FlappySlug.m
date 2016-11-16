//
//  FlappySlug.m
//  A clone of the rooftop runner web games
//
//  Created by Zak Rubin on 10/23/14.
//  Copyright 2014 Zak Rubin. All rights reserved.
//

#import "FlappySlug.h"


@implementation FlappySlug
{
    CCTimer *wallSpawnTimer;
    CCTimer *wallJumpTimer;
    BOOL gameStarted;
    CCSprite *slug;
    CCSprite *firework;
    CCPhysicsNode *physicsWorld;
    CCNode *startingGround;
    
    
    NSMutableArray * randomWordSelection;
    NSMutableArray * wordList;
    
    AVAudioPlayer * jumpSound;
}



+ (FlappySlug *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    gameStarted = NO;
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"flappyslug"];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    [[OEManager sharedManager] setSecondsOfSilence:20.0f];
    
    jumpSound = [AVAudioPlayer alloc];
    NSURL* soundFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"jump"
                                               ofType:@"wav"]];
    jumpSound = [jumpSound initWithContentsOfURL:soundFile error:nil];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    //adding physics
    physicsWorld = [CCPhysicsNode node];
    //physicsWorld.gravity = ccp(0, -400); // Add gravity after the first utterance
    physicsWorld.debugDraw = YES;
    [self addChild:physicsWorld];
    physicsWorld.collisionDelegate = self;
    
    //Add Sam
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sam_sprite_sheet.plist"];
    slug = [CCSprite spriteWithImageNamed:@"sam_right_0.png"];
    slug.scale = (0.6);
    slug.position  = ccp(self.contentSize.width/8, self.contentSize.height/2);
    slug.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, slug.contentSize} cornerRadius:0];
    slug.physicsBody.collisionType = @"slug";
    slug.physicsBody.elasticity = 0.0f;
    [physicsWorld addChild:slug];
    
    // Add left wall and floor;
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    [self addWallWithRect:CGRectMake(0, 0, 0, viewSize.height)];
    [self addTopWall];
    [self addWallWithRect:CGRectMake(0, -0.1f, viewSize.width, 0)];
    [self addStartingGround];
    
    [self setLevelName:@"FlappySlug"];
    [self setTargetSentence:@"BOUNCE SLUG"];
    
    [self intro];
    
    
    // done
    return self;
}

-(CGPoint) rotateAroundPoint:(CGPoint)rotationPoint angle:(CGFloat)angle {
    CGFloat x = cos(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.x-rotationPoint.x) - sin(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.y-rotationPoint.y) + rotationPoint.x;
    CGFloat y = sin(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.x-rotationPoint.x) + cos(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.y-rotationPoint.y) + rotationPoint.y;
    
    return ccp(x, y);
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro {
    // Add UI elements
    [self showAllUIElements];
    
    [self setSentenceInPhraseBox:@"Say \"Bounce slug!\""];
    
    [[OEManager sharedManager] startListening];
    CCActionMoveBy *actionMove = [CCActionMoveBy actionWithDuration:3.0f position:ccp(self.contentSize.width/5, 0)];
    [slug runAction:actionMove];
    //timer for update method

}

- (void) jump {
    [slug.physicsBody setVelocity:CGPointMake(0, 0)];
    [slug.physicsBody applyImpulse:CGPointMake(0, 150)];
    [jumpSound play];
}

- (void) scheduleAddWalls:(CCTime*)dt {
    wallSpawnTimer = [self schedule:@selector(addWall:) interval:1.0f repeat:-1 delay:0];
    wallJumpTimer = [self schedule:@selector(addWallJumpScore:) interval:2.0f repeat:-1 delay:1.5f];
    // Start game timer
}

- (void)launchRocket {
    CCActionRotateTo *actionMove = [CCActionRotateTo actionWithDuration:4 angle:360];
    [slug runAction:actionMove];
    //[self scheduleOnce:@selector(explode:) delay:1];
}

- (void) addStartingGround {
    CCPhysicsBody *wall = [CCPhysicsBody bodyWithRect:CGRectMake(0, self.contentSize.height*15/32, self.contentSize.width/3, 5) cornerRadius:0];
    wall.type = CCPhysicsBodyTypeStatic;
    wall.elasticity = 0.0f;
    startingGround = [CCNode node];
    startingGround.physicsBody = wall;
    wall.collisionType = @"ceiling";
    [physicsWorld addChild:startingGround];
}

- (void) addTopWall {
    CCPhysicsBody *wall = [CCPhysicsBody bodyWithRect:CGRectMake(0, self.contentSize.height, self.contentSize.width, 0) cornerRadius:0];
    wall.type = CCPhysicsBodyTypeStatic;
    wall.elasticity = 0.0f;
    CCSprite *theFloor = [CCSprite node];
    theFloor.physicsBody = wall;
    wall.collisionType = @"ceiling";
    [physicsWorld addChild:theFloor];
}


-(void)addWall:(CCTime*)dt {
    int randomHeight = arc4random_uniform(self.contentSize.height*2/4) + self.contentSize.height*2/20;
    
    // Bottom wall
    CGRect rect = CGRectMake(self.contentSize.width*7/8, 0, self.contentSize.width/10, self.contentSize.height*3/4 - randomHeight);
    CCPhysicsBody *wall = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    wall.type = CCPhysicsBodyTypeStatic;
    wall.elasticity = .0f;
    //CCSprite *theFloor = [CCSprite spriteWithImageNamed:@"Textbox_medium.png"];
    CCNode *theFloor = [CCNode node];
    
    CCActionMoveTo *actionMove;
    actionMove = [CCActionMoveTo actionWithDuration:4.0f position:ccp(-self.contentSize.width, 0)];
    
    theFloor.physicsBody = wall;
    wall.collisionType = @"wall";
    [physicsWorld addChild:theFloor];
    [theFloor runAction:actionMove];
    
    
    // Top Wall
    rect = CGRectMake(self.contentSize.width*7/8, self.contentSize.height - randomHeight + self.contentSize.height/10, self.contentSize.width/10, self.contentSize.height);
    wall = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    wall.type = CCPhysicsBodyTypeStatic;
    wall.elasticity = .0f;
    //CCSprite *theFloor = [CCSprite spriteWithImageNamed:@"Textbox_medium.png"];
    theFloor = [CCNode node];
    
    actionMove = [CCActionMoveTo actionWithDuration:4.0f position:ccp(-self.contentSize.width, 0)];
    
    theFloor.physicsBody = wall;
    wall.collisionType = @"wall";
    //[physicsWorld addChild:theFloor];
    //[theFloor runAction:actionMove];
    
}

-(void)addWallJumpScore:(CCTime*)dt {
    [self addToScore:[NSNumber numberWithInt:1]];
}

-(CCNode *)addWallWithRect:(CGRect)rect {
    CCPhysicsBody *wall = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    wall.type = CCPhysicsBodyTypeStatic;
    wall.elasticity = .5f;
    CCSprite *theFloor = [CCSprite node];
    theFloor.physicsBody = wall;
    wall.collisionType = @"wall";
    [physicsWorld addChild:theFloor];
    return theFloor;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair slug:(CCNode *)nodeA wall:(CCNode *)nodeB {
    [self changeLevel];
    return YES;
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    //slug.position = touchLoc;
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    //slug.position = touchLoc;
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    //NSString * filteredSpeechText = [[NSString alloc] initWithString:speechEvent.text];
    //NSString * filteredSpeechText = speechEvent.text;
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    if([self targetSentence].length > 1 && speechEvent.eventType == OpenEarsResponse) {
        NSString * phraseParts = [self checkForPhraseParts:[self targetSentence] currentHypothesis:filteredSpeechText];
        bool phraseSaid = NO;
        if (phraseParts!= nil && [self checkIfPhraseExists:[self targetSentence] currentHypothesis:phraseParts]) {
            [self jump];
            [self updatePreviousValidSpeech:speechEvent.text];
            [self showCheckmark];
            [self addSentenceToStatistics];
            phraseSaid = YES;
            [self addToScore:[NSNumber numberWithInt:1]];
            if(!gameStarted) {
                CCActionMoveTo *actionMove;
                actionMove = [CCActionMoveTo actionWithDuration:4.0f position:ccp(-self.contentSize.width, 0)];
                [startingGround runAction:actionMove];
                physicsWorld.gravity = ccp(0, -100);
                [self scheduleOnce:@selector(scheduleAddWalls:) delay:3];
                gameStarted = YES;
                [self setAndStartGameTimer:20];
            }
        } else if (([filteredSpeechText rangeOfString:@"GRASS"].location != NSNotFound)) {
            //[self goose];
            [self updatePreviousValidSpeech:speechEvent.text];
            [self showCheckmark];
        } else {
            
        }
        
        NSString * currentSentenceFormatted = [[self targetSentence] lowercaseString];
        currentSentenceFormatted = [currentSentenceFormatted stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[currentSentenceFormatted substringToIndex:1] uppercaseString]];
        [self highlightPhraseParts:phraseParts];
        if(phraseSaid) [self scheduleOnce:@selector(blankHighlightedWords:) delay:0.3f];
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
    if (physicsWorld)[physicsWorld removeFromParentAndCleanup:YES];
    physicsWorld = nil;
    [wallJumpTimer invalidate];
    if([jumpSound isPlaying]) [jumpSound stop];
    wallJumpTimer = nil;
    [wallSpawnTimer invalidate];
    wallSpawnTimer = nil;
    [super onExit];
}

@end
