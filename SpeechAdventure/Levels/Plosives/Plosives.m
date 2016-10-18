//
//  Plosives.m
//  speechadventure
//
//  Created by Zak Rubin on 5/27/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#include "Plosives.h"

@implementation Plosives

static NSArray *levelList = nil;

- (id)init
{
    
    return self;
}

+ (NSArray *)getGameList
{
    if (levelList == nil) {
        levelList = [NSArray arrayWithObjects:@"TemplateLevel", @"Fireworks", @"BouncyBalls", @"FlappySlug", @"SpaceInvaders", nil];
        //levelList = [NSArray arrayWithObjects:@"TemplateLevel", nil];
    }
    return levelList;
}

+ (NSArray *)getGameDescription
{
    NSArray * templateLevelDescription = [NSArray arrayWithObjects:@"Help Mr. Cow Grow", @"Move Mr. Cow with your finger", @"Say the word to help Mr. Cow grow and get points", @" ",  nil];
    //NSArray * slotMachineDescription = [NSArray arrayWithObjects:@"Slot Machine", @"Say the things on the screen",@"Push the button to change the objects", @" ", nil];
    NSArray * fireworksDescription = [NSArray arrayWithObjects:@"Fireworks", @"Say the words to launch the fireworks",@" ", @" ", nil];
    NSArray * bouncyBallsDescription = [NSArray arrayWithObjects:@"BouncyBalls", @"Say the word to bounce the ball onto the ledge",@"Say the other word to shoot the ball into the basket", @" ", nil];
    NSArray * flappySlugDescription = [NSArray arrayWithObjects:@"Flappy Slug", @"Say the word to make the slug fly over the gates",@" ", @" ", nil];
    NSArray * spaceInvadersDescription = [NSArray arrayWithObjects:@"Space Invaders", @"Say the word to fire your laser",@"Move your ship with your finger", @" ", nil];
    //NSArray * guessPicDescription = [NSArray arrayWithObjects:@"Card Matching", @"Touch two cards. If they are the same",@"Say the word to get points", @" ", nil];
    //NSArray * guessWordDescription = [NSArray arrayWithObjects:@"Eat Balloons", @"Eat Balloons!",@" ", @" ", nil];
    NSArray * levelList = [NSArray arrayWithObjects:templateLevelDescription, fireworksDescription, bouncyBallsDescription, flappySlugDescription, spaceInvadersDescription, nil];
    return levelList;
}

@end
