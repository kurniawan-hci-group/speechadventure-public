//
//  StatDatabase.h
//  speechadventure
//
//  Created by Zak Rubin on 10/23/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface StatDatabase : NSObject

- (BOOL) openDatabase;
- (NSData *) getDatabaseFile;
- (NSArray *) queryDatabase:(NSString *) query;
- (NSArray *) selectFromLevel:(NSString *) query;
- (NSMutableArray *) getSessionsByName:(NSString *) query;
- (NSMutableArray *) getLevelsBySession:(int) session;
- (NSMutableArray *) getSentencesBySession:(int) session;
- (int) insertIntoLevels:(NSString *) dataString;
+ (StatDatabase *)database;
- (int) getSessionCount;
- (int) getLevelCount;
- (int) getSentenceCount;
- (int) getUtteranceCount;
- (int) getTimePlayedToday;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *speechgameDB;

@end
