//
//  TransitionScene.m
//  speechadventure
//
//  Created by Zak Rubin on 4/24/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "TransitionScene.h"
#import "TemplateLevel.h"
#import "Plosives.h"
#import "Apraxia.h"
#import "LivingRoomEvaluation.h"
#import "PopABalloonEvaluation.h"

@implementation TransitionScene {
    CCTimer * runningSceneTimer;
    CCLabelTTF *gameDescription[4];
    NSMutableArray * currentLevelList;
    NSMutableArray * gameDescriptionList;
    NSMutableArray * levelList;
}

@synthesize nextLevelName;
@synthesize nextScene;




// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (TransitionScene *)scene
{
	return [[self alloc] init];
}

+ (TransitionScene *)sceneWithNextLevel:(NSString*) levelName
{
	return [[self alloc] initWithNextLevel:levelName];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    if([[OEManager sharedManager] listeningStarted]) {
        [[OEManager sharedManager] stopListening];
    }
    
    NSArray * gamesArray = [Apraxia getGameList];
    gamesArray = [gamesArray arrayByAddingObjectsFromArray:[Plosives getGameList]];
    levelList = [NSMutableArray arrayWithArray:gamesArray];
    currentLevelList = [NSMutableArray array];
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    runningSceneTimer = [self scheduleOnce:@selector(isRunningScene:) delay:0.25f];
    //[self selectRandomLevel];
    
    // done
	return self;
}

- (id)initWithNextLevel:(NSString*) levelName {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    if([[OEManager sharedManager] listeningStarted]) {
        [[OEManager sharedManager] stopListening];
    }
    
    NSArray * gamesArray = [Apraxia getGameList];
    gamesArray = [gamesArray arrayByAddingObjectsFromArray:[Plosives getGameList]];
    levelList = [NSMutableArray arrayWithArray:gamesArray];
    currentLevelList = [NSMutableArray arrayWithObject:levelName];
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    runningSceneTimer = [self scheduleOnce:@selector(isRunningScene:) delay:0.25f];
    
    
    // done
	return self;
}

- (void) selectRandomLevel {
    /*NSArray *plosiveList = [NSArray arrayWithArray:[Plosives getGameList]];
    NSArray *apraxiaList = [NSArray arrayWithArray:[Apraxia getGameList]];
    
    int randomLevel = arc4random_uniform(plosiveList.count + apraxiaList.count);
    int randomGameGroup = 0;
    if(randomLevel < plosiveList.count) {
        nextLevelName = [NSString stringWithString:[plosiveList objectAtIndex:randomLevel]];
    } else {
        randomLevel -= plosiveList.count;
        nextLevelName = [NSString stringWithString:[apraxiaList objectAtIndex:randomLevel]];
        randomGameGroup = 1;
    }
    
    [self displayNextLevelNameAndDescription:randomGameGroup andGameLevel:randomLevel];*/
    
    // Begin new list-based randomization
    NSArray *plosiveList = [NSArray arrayWithArray:[Plosives getGameList]];
    NSArray *apraxiaList = [NSArray arrayWithArray:[Apraxia getGameList]];
    if([currentLevelList count] == 0) {
        [self randomlyAddAllGamesToList];
    }
    NSString * levelString = [currentLevelList objectAtIndex:0];
    nextLevelName = [NSString stringWithString:levelString];
    [currentLevelList removeObjectAtIndex:0];
    int randomLevel = [plosiveList indexOfObject:levelString];
    int randomGameGroup = 0;
    if(randomLevel > [plosiveList count]) {
        randomLevel = [apraxiaList indexOfObject:levelString];
        randomGameGroup = 1;
    }
    [self displayNextLevelNameAndDescription:randomGameGroup andGameLevel:randomLevel];
    
}

- (void) translateGameNameToGroupAndLevel:(NSString *) gameName {
    
}

- (void) displayNextLevelNameAndDescription:(int)gameGroup andGameLevel:(int)level {
    NSArray * theGameDescription;
    if(gameGroup) {
        theGameDescription = [Apraxia getGameDescription];
    } else {
        theGameDescription = [Plosives getGameDescription];
    }
    
    gameDescription[0] = [CCLabelTTF labelWithString:theGameDescription[level][0] fontName:@"ArialMT" fontSize:36.0f];
    gameDescription[0].positionType = CCPositionTypeNormalized;
    gameDescription[0].color = [CCColor redColor];
    gameDescription[0].position = ccp(0.5f, 0.9f); // Middle of screen
    [self addChild:gameDescription[0]];
    
    gameDescription[1] = [CCLabelTTF labelWithString:theGameDescription[level][1] fontName:@"ArialMT" fontSize:20.0f];
    gameDescription[1].positionType = CCPositionTypeNormalized;
    gameDescription[1].color = [CCColor redColor];
    gameDescription[1].position = ccp(0.5f, 0.6f); // Middle of screen
    [self addChild:gameDescription[1]];
    
    gameDescription[2] = [CCLabelTTF labelWithString:theGameDescription[level][2] fontName:@"ArialMT" fontSize:20.0f];
    gameDescription[2].positionType = CCPositionTypeNormalized;
    gameDescription[2].color = [CCColor redColor];
    gameDescription[2].position = ccp(0.5f, 0.5f); // Middle of screen
    [self addChild:gameDescription[2]];
    
    gameDescription[3] = [CCLabelTTF labelWithString:theGameDescription[level][3] fontName:@"ArialMT" fontSize:20.0f];
    gameDescription[3].positionType = CCPositionTypeNormalized;
    gameDescription[3].color = [CCColor redColor];
    gameDescription[3].position = ccp(0.5f, 0.4f); // Middle of screen
    [self addChild:gameDescription[3]];
    [self scheduleOnce:@selector(transitionToNextlevel:) delay:5];
}

- (void) randomlyAddAllGamesToList {
    
    NSMutableArray * randomLevelList = [NSMutableArray arrayWithArray:levelList];
    while([randomLevelList count]) {
        int randomLevelNumber = arc4random()%[randomLevelList count];
        NSString * levelName = [randomLevelList objectAtIndex:randomLevelNumber];
        [randomLevelList removeObjectAtIndex:randomLevelNumber];
        [currentLevelList addObject:levelName];
    }
}


-(void) isRunningScene:(id)sender {
    if([[[CCDirector sharedDirector] runningScene] isEqual:self]) {
        [runningSceneTimer invalidate];
        NSLog(@"Transition is running");
        [gameDescription[0] removeFromParent];
        [gameDescription[1] removeFromParent];
        [gameDescription[2] removeFromParent];
        [self selectRandomLevel];
    }
}

- (void) displayTutorial {
    
    [self scheduleOnce:@selector(transitionToNextlevel:) delay:1];
}

- (void) checkIfPlayedForTime:(int) timeInSeconds {
    [self scheduleOnce:@selector(transitionToNextlevel:) delay:1];
}

- (void) transitionToNextlevel:(id)sender {
    if([[OEManager sharedManager] listeningStarted]) {
        [[OEManager sharedManager] stopListening];
    }
    
    [[CCDirector sharedDirector] pushScene:[NSClassFromString(nextLevelName) scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
    runningSceneTimer = [self schedule:@selector(isRunningScene:) interval:0.25f];
}

- (void) changeToLevel:(NSString*) nextLevelName {
    if([[OEManager sharedManager] listeningStarted]) {
        [[OEManager sharedManager] stopListening];
    }
    [[CCDirector sharedDirector] replaceScene:[PopABalloonEvaluation scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

@end
