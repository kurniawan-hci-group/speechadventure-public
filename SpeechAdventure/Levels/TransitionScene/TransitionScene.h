//
//  TransitionScene.h
//  speechadventure
//  TransitionScene serves as the middleman between games. Currently it is a grey screen.
//  In the future it will show instructions, scores, and additional information
//
//  Created by Zak Rubin on 4/24/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface TransitionScene : CCScene

+ (TransitionScene *)scene;
+ (TransitionScene *)sceneWithNextLevel:(NSString*) levelName;
+ (TransitionScene *)sceneWithNextLevel:(NSString*) levelName;
- (id)init;

@property (nonatomic, strong) NSString *nextLevelName;
@property (nonatomic, strong) CCScene *nextScene;

@end
