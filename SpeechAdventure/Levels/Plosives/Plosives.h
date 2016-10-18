//
//  Plosives.h
//  speechadventure
//  Provides games for plosives.
//
//  Created by Zak Rubin on 4/25/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#include "PopABalloonEvaluation.h"
#include "LivingRoomEvaluation.h"
#include "BouncyBalls.h"
#include "SlotMachine.h"
#include "TemplateLevel.h"
#include "Fireworks.h"
#include "FlappySlug.h"
#include "DuckDuckGoose.h"
#include "GuessPic.h"
#include "GuessWord.h"

@interface Plosives : NSObject 

- (id)init;
+ (NSArray *)getGameList;
+ (NSArray *)getGameDescription;

@end
