//
//  DuckDuckGoose
//  A simple duck duck goose game.
//
//  Created by Zak Rubin on 10/10/14.
//  Copyright 2014 Zak Rubin. All rights reserved.
//

#import "DuckDuckGoose.h"


@implementation DuckDuckGoose
{
    CCSprite *duck[12];
    CCSprite *player;
}

+ (DuckDuckGoose *)scene
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
    [[OEManager sharedManager] registerDelegate:self shouldReturnPartials:true];
    [[OEManager sharedManager] swapModel:@"TemplateLevel"];
    [[OEManager sharedManager] startListening];
    
    
    // Create a colored background (Dark Green)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:0.3f blue:0.1f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    CGPoint basePosition = ccp(0.5f, 0.5f);
    // Add a sprite
    for(int i = 0; i < 12; i++) {
        duck[i] = [CCSprite spriteWithImageNamed:@"Textbox_small.png"];
        duck[i].scale = 0.5f;
        duck[i].positionType = CCPositionTypeNormalized;
        duck[i].anchorPoint = ccp(2.0f, 0.5f);
        duck[i].position  = basePosition;
        [duck[i] setRotation:i*30];
        [self addChild:duck[i]];
    }
    
    player = [CCSprite spriteWithImageNamed:@"bunny.png"];
    player.scale = 0.5f;
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    CGPoint point = ccp(winSize.width/4, winSize.height/2);
    player.position  = ccp(point.x, point.y);
    [player setRotation:0];
    [self addChild:player];
    
    
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

- (void)intro
{
    // Add UI elements
    [self showAllUIElements];
    
    // Start game timer
    [self setAndStartGameTimer:20];
    
    [self setSentenceInPhraseBox:@"Say Corn or Grass!"];
}

- (int) getDuckClosestToPlayer {
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    CGPoint point = ccp(winSize.width/2, winSize.height/2);
    float angle = atan2([player position].y-point.y, [player position].x-point.x)* 180 / M_PI;
    angle = 180+ (-angle);
    int duckNum = ((int)round(angle)/30)%12;
    return duckNum;
}

- (void)launchRocket
{
    CCActionRotateTo *actionMove = [CCActionRotateTo actionWithDuration:4 angle:360];
    [player runAction:actionMove];
    [self scheduleOnce:@selector(explode:) delay:1];
}

- (void)duck
{
    int closeDuck = [self getDuckClosestToPlayer];
    [duck[closeDuck] setTexture:[CCTexture textureWithFile:@"Textbox_small_sel.png"]];
}

- (void)goose
{
    int closeDuck = [self getDuckClosestToPlayer];
    CCActionRotateBy *actionMove = [CCActionRotateBy actionWithDuration:3 angle:360];
    [duck[closeDuck] runAction:actionMove];
}

- (void)explode:(CCTime)dt
{
    [self removeChild:duck[0]];
    [self scheduleOnce:@selector(timeUp:) delay:10];
}

-(void) timeUp:(CCTime)dt{
    //[self.conten
    [[OEManager sharedManager] pauseListening];
    [[OEManager sharedManager] recordingCutoff];
    [self changeLevel];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    player.position = touchLoc;
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:(SKNode *) self];
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    player.position = touchLoc;
}

// -----------------------------------------------------------------------
#pragma mark - Open Ears Handler
// -----------------------------------------------------------------------

- (void)receiveOEEvent:(OEEvent*) speechEvent
{
    //NSLog(@"Received speechEvent.\ntext:%@\nscore:%@",speechEvent.text,speechEvent.recognitionScore);
    NSString * filteredSpeechText = [[NSString alloc] initWithString:[self truncateFromPreviousValidSpeech:speechEvent.text]];
    //NSString * filteredSpeechText = [[NSString alloc] initWithString:speechEvent.text];
    NSLog(@"Filtered speechEvent.\ntext:%@",filteredSpeechText);
    if(speechEvent.eventType == RapidEarsPartial) {
        if (([filteredSpeechText rangeOfString:@"CORN"].location != NSNotFound)) {
            [self duck];
            [self updatePreviousValidSpeech:speechEvent.text];
        } else if (([filteredSpeechText rangeOfString:@"GRASS"].location != NSNotFound)) {
            [self goose];
            [self updatePreviousValidSpeech:speechEvent.text];
        } else {
            
        }
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
