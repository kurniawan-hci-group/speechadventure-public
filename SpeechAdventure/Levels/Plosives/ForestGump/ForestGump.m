//
//  ForestGump.m
//  speechadventure
//
//  Created by Taylor Gotfrid on 8/2/15.
//  Copyright (c) 2015 Zak Rubin. All rights reserved.
//

#import "ForestGump.h"


@implementation ForestGump
+ (ForestGump *)scene {
    
    return [[self alloc] init];
}

CCPhysicsNode *physicsWorld;

- (id)init {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Swap to dictionary for this level and return incomplete utterances
    [[OEManager sharedManager] swapModel:@"OpenEars1"];
    [[OEManager sharedManager] startListening];
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    
    //adding physics
    physicsWorld = [CCPhysicsNode node];
    physicsWorld.gravity = ccp(0,0);
    physicsWorld.debugDraw = YES;
    //physicsWorld.debugDraw = NO;
    [self addChild:physicsWorld];
    
    
    size = [[CCDirector sharedDirector]viewSize];
    background1 = [CCSprite spriteWithImageNamed:@"field.png"];
    background2 = [CCSprite spriteWithImageNamed:@"field.png"];
    background3 = [CCSprite spriteWithImageNamed:@"field.png"];
    
    background1.anchorPoint = ccp(0,0);
    background1.position = ccp(0,100);
    background1.scale = 2;
    [physicsWorld addChild:background1 z:0];
    
    background2.anchorPoint = ccp(0,0);
    background2.position = ccp([background1 boundingBox].size.width - 1, 100);
    background2.scale = 2;
    [physicsWorld addChild:background2 z:0];
    
    background3.anchorPoint = ccp(0,0);
    background3.position = ccp([background2 boundingBox].size.width - 1, 100);
    background3.scale = 2;
    [physicsWorld addChild:background3 z:0];
    
    car = [CCSprite spriteWithImageNamed:@"car.png"];
    car.anchorPoint = ccp(0,0);
    car.position = ccp(100,70);
    car.scale = .1;
    car.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, car.contentSize} cornerRadius:0];
    car.physicsBody.collisionType = @"car";
    [physicsWorld addChild:car z:1];
    
    _collision = FALSE;
    
    if(_collision == TRUE) {
        [self gameOver];
    }
    
    
    float randomTimeInterval;
    randomTimeInterval = arc4random() % 8;
    [self schedule:@selector(createCone:) interval:fabs(randomTimeInterval)];
    
    [self schedule:@selector(scroll:) interval:0.008];
    
    [self addWallWithRect:CGRectMake(0, 0, 600, 70)];
    
    [self intro];
    
    // done
    return self;
}

-(void)scroll:(CCTime*)dt {
    background1.position = ccp(background1.position.x - 1, background1.position.y);
    background2.position = ccp(background2.position.x - 1, background2.position.y);
    background3.position = ccp(background2.position.x - 1, background2.position.y);
    cone.position = ccp(cone.position.x - 1, cone.position.y);
    if(background1.position.x < -[background1 boundingBox].size.width){
        background1.position = ccp(background2.position.x + [background2 boundingBox].size.width, background1.position.y);
    }
    if(background2.position.x < -[background2 boundingBox].size.width){
        background2.position = ccp(background1.position.x + [background1 boundingBox].size.width, background2.position.y);
    }
    if(background3.position.x < -[background3 boundingBox].size.width){
        background3.position = ccp(background2.position.x + [background2 boundingBox].size.width, background3.position.y);
    }
}


-(void)addWallWithRect:(CGRect)rect {
    CCPhysicsBody *walls = [CCPhysicsBody bodyWithRect:rect cornerRadius:0];
    walls.type = CCPhysicsBodyTypeStatic;
    CCNode *theWalls = [CCNode node];
    theWalls.physicsBody = walls;
    walls.collisionType = @"walls";
    [physicsWorld addChild:theWalls];
}

-(void)createCone:(CCTime*)dt {
    cone = [CCSprite spriteWithImageNamed:@"cone.png"];
    cone.scale = .7;
    cone.position = ccp(500,80);
    cone.physicsBody.affectedByGravity = NO;
    cone.scale = .1;
    cone.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, cone.contentSize} cornerRadius:0];
    cone.physicsBody.collisionType = @"cone";
    [physicsWorld addChild:cone z:1];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair car:(CCNode *)car cone:(CCNode *)cone {
    _collision = TRUE;
    return YES;
}

-(void)gameOver {
    [self schedule:@selector(scroll:) interval:0];
    CCLabelTTF *gameOver = [CCLabelTTF labelWithString:@"Game Over" fontName:@"ArialMT" fontSize:48.0];
    gameOver.color = [CCColor blackColor];
    gameOver.position = ccp(150,150);
    [self addChild:gameOver];
}

// -----------------------------------------------------------------------
#pragma mark - Game Events
// -----------------------------------------------------------------------

- (void)intro {
    [self showListeningEar];
    [self showBackButton];
    [self startDisplayingLevels];
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent {
    if(speechEvent.eventType == OpenEarsResponse) {
        if (([speechEvent.text rangeOfString:@"GO"].location != NSNotFound)) /*|| ([speechEvent.text rangeOfString:@"HOUNCE"].location != NSNotFound))*/ {
            //add shit
            [car.physicsBody applyImpulse:ccp(10,40)];
            physicsWorld.gravity = ccp(0,-10.0);
        }
    }
}



// -----------------------------------------------------------------------
#pragma mark - Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender {
    // start spinning scene with transition
    [self changeLevel];
}



@end
