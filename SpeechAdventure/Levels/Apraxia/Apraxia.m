//
//  Apraxia.m
//  speechadventure
//
//  Created by Zak Rubin on 2/20/16.
//  Copyright (c) 2016 Zak Rubin. All rights reserved.
//

#include "Apraxia.h"

@implementation Apraxia

static NSArray *levelList = nil;

- (id)init
{
    
    return self;
}

+ (NSArray *)getGameList
{
    if (levelList == nil) {
        levelList = [NSArray arrayWithObjects:@"ApraxiaLevel1", @"ApraxiaLevel2", nil];
        //levelList = [NSArray arrayWithObjects:@"TemplateLevel", nil];
    }
    return levelList;
}

+ (NSArray *)getGameDescription
{
    NSArray * apraxiaLevel1Description = [NSArray arrayWithObjects:@"Card Flip", @"Touch the cards to flip them", @"Say the word to get points", @" ",  nil];
    NSArray * apraxiaLevel2Description = [NSArray arrayWithObjects:@"Wheel Spin", @"Touch the button to spin the wheel.", @"Say the word to get points", @" ",  nil];
    NSArray * levelList = [NSArray arrayWithObjects:apraxiaLevel1Description, apraxiaLevel2Description, nil];
    return levelList;
}

@end
