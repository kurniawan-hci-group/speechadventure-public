//
//  Apraxia.h
//  speechadventure
//  Provides games for plosives.
//
//  Created by Zak Rubin on 2/20/16.
//  Copyright (c) 2016 Zak Rubin. All rights reserved.
//

#include "ApraxiaLevel1.h"
#include "ApraxiaLevel2.h"
#include "ApraxiaLevel3.h"

@interface Apraxia : NSObject

- (id)init;
+ (NSArray *)getGameList;
+ (NSArray *)getGameDescription;

@end
