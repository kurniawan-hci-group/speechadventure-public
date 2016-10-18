    //
//  StatDatabase.m
//  speechadventure
//
//  Created by Zak Rubin on 10/23/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatDatabase.h"

@implementation StatDatabase {
    
}

static StatDatabase *database;

+ (StatDatabase*)database
{
    if (database == nil) {
        database = [[StatDatabase alloc] init];
    }
    return database;
}

- (id)init
{
    if ((self = [super init])) {
        NSString *docsDir;
        NSArray *dirPaths;
    
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        _databasePath = [[NSString alloc]
                        initWithString: [docsDir stringByAppendingPathComponent:
                                         @"SpeechAdventure.db"]];
        NSFileManager *filemgr = [NSFileManager defaultManager];

        if ([filemgr fileExistsAtPath: _databasePath ] == NO)
        {
            [self createDatabase];
        }
//test query
    }
    [self openDatabase];
    return self;
}

- (BOOL) openDatabase {
    const char *dbpath = [_databasePath UTF8String];
    int openResult = sqlite3_open(dbpath, &_speechgameDB);
    if (openResult == SQLITE_OK) return YES;
    else NSLog(@"Error: %s", sqlite3_errstr(openResult));
    return NO;
}

- (void) closeDatabase {
    sqlite3_close(_speechgameDB);
}

- (void) createDatabase {
    NSLog(@"Attempting to create database");
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_speechgameDB) == SQLITE_OK)
    {
        char *errMsg;
        //add time for level played (sequal)
        //living room evaluation see stat lvl entry stuff
        //adjust time
        const char *sql_stmt = " ";
        if (sqlite3_prepare_v2(_speechgameDB,
                               sql_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sql_stmt =
            "CREATE TABLE IF NOT EXISTS Session (ID INTEGER PRIMARY KEY AUTOINCREMENT, PlayerName VARCHAR(100), Date DATETIME, TimePlayed INTEGER, LevelsPlayed INTEGER, SessionScore INTEGER)";
            
            if (sqlite3_exec(_speechgameDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table Session");
            }
            sql_stmt =
            "CREATE TABLE IF NOT EXISTS Level (ID INTEGER PRIMARY KEY AUTOINCREMENT, SessionID INTEGER, PlayerName VARCHAR(100), Date DATETIME, LevelName VARCHAR(100), TotalLevelTime INTEGER, LevelScore INTEGER)";
            if (sqlite3_exec(_speechgameDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table Level");
            }
            sql_stmt =
            "CREATE TABLE IF NOT EXISTS Sentence (ID INTEGER PRIMARY KEY AUTOINCREMENT, SessionID INTEGER, LevelID INTEGER, Sentence VARCHAR(100), TargetWords VARCHAR(100), TargetSyllables VARCHAR(100))";
            
            if (sqlite3_exec(_speechgameDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table Sentence");
            }
            
            sql_stmt =
            "CREATE TABLE IF NOT EXISTS Utterance (ID INTEGER PRIMARY KEY AUTOINCREMENT, SentenceID INTEGER, Utterance VARCHAR(1000))";
            
            if (sqlite3_exec(_speechgameDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table Sentence");
            }
        }
        sqlite3_close(_speechgameDB);
        NSLog(@"Database created succesfully");
    } else {
        NSLog(@"Failed to open/create database");
    }
}

- (NSData *) getDatabaseFile {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"SpeechAdventure.db"]];
    NSData * database = [[NSFileManager defaultManager] contentsAtPath:_databasePath];

    return database;
}


- (int) insertIntoLevels:(NSString*) dataString
{
    NSString * query  = [[NSString alloc]initWithFormat: @"INSERT INTO Level (SessionID, PlayerName, Date, LevelName, TotalLevelTime) VALUES (%@)", dataString];
    sqlite3_stmt    *statement;
    int sqlReturn = 1;
    if(_speechgameDB) {
        NSString *querySQL = [NSString stringWithString:query];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_speechgameDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlReturn = sqlite3_step(statement);
        } else {
            sqlReturn = sqlite3_prepare_v2(_speechgameDB,
                                           query_stmt, -1, &statement, NULL);
        }
        sqlite3_finalize(statement);
    }
    return sqlReturn;
}

- (NSArray *) queryDatabase:(NSString*) query
{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    sqlite3_stmt    *statement;
    int sqlReturn = 1;
    if(_speechgameDB) {
        NSString *querySQL = [NSString stringWithString:query];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_speechgameDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            sqlReturn = sqlite3_step(statement);
        } else {
            sqlReturn = sqlite3_prepare_v2(_speechgameDB, query_stmt, -1, &statement, NULL);
            NSLog(@"Error: %s", sqlite3_errstr(sqlReturn));
        }
        sqlite3_finalize(statement);
    }
    return retval;
}

- (int) getCountFromDatabase:(NSString*) query
{
    int count = -1;
    NSString *querySQL=[NSString stringWithString:query];
    if(_speechgameDB) {
        sqlite3_stmt *statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                count = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_finalize(statement);
    }
    return count;
}

- (NSMutableArray *) getArrayFromDatabase:(NSString *) query
{
    return 0;
}

- (int) getSessionCount
{
    return [self getCountFromDatabase:@"SELECT COUNT(ID) FROM Session"];
}

- (int) getLevelCount
{
    return [self getCountFromDatabase:@"SELECT COUNT(ID) FROM Level"];
}

- (int) getSentenceCount
{
    return [self getCountFromDatabase:@"SELECT COUNT(ID) FROM Sentence"];
}

- (int) getUtteranceCount
{
    return [self getCountFromDatabase:@"SELECT COUNT(ID) FROM Utterance"];
}

- (NSMutableArray *) selectFromLevel:(NSString*)query
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if(_speechgameDB) {
        NSString *querySQL=[NSString stringWithFormat:@"SELECT* FROM Level WHERE PlayerName = '%@'", query];
        sqlite3_stmt *statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSMutableArray *row = [[NSMutableArray alloc] init];
                NSNumber *ID = [NSNumber numberWithInteger:sqlite3_column_int(statement, 0)];
                NSNumber *SessionID = [NSNumber numberWithInteger:sqlite3_column_int(statement, 1)];
                NSString *PlayerName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,2)];
                NSNumber *Date = [NSNumber numberWithInteger:sqlite3_column_int(statement, 3)];
                NSString *LevelName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,4)];
                NSNumber *TotalLevelTime = [NSNumber numberWithInteger:sqlite3_column_int(statement,5)];
                
                [row addObject:ID];
                [row addObject:SessionID];
                [row addObject:PlayerName];
                [row addObject:Date];
                [row addObject:LevelName];
                [row addObject:TotalLevelTime];
                [result addObject:row];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_finalize(statement);
    }
    NSLog(@"This is the final table");
    //NSLog(@"%@", result);
    return result;
}

- (NSMutableArray *) getSessionsByName:(NSString*) query
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if(_speechgameDB) {
        NSString* querySQL=[NSString stringWithFormat:@"SELECT * FROM Session WHERE PlayerName = '%@'", query];
        sqlite3_stmt* statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSMutableArray* row = [[NSMutableArray alloc] init];
                NSNumber* ID = [NSNumber numberWithInteger:sqlite3_column_int(statement, 0)];
                NSString* PlayerName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                NSString* Date = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                NSNumber* TimePlayed = [NSNumber numberWithInteger:sqlite3_column_int(statement, 3)];
                NSNumber* LevelsPlayed = [NSNumber numberWithInteger:sqlite3_column_int(statement, 4)];
                NSNumber* Score = [NSNumber numberWithInteger:sqlite3_column_int(statement, 5)];
                
                [row addObject:ID];
                [row addObject:PlayerName];
                [row addObject:Date];
                [row addObject:TimePlayed];
                [row addObject:LevelsPlayed];
                [row addObject:Score];
                [result addObject:row];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_finalize(statement);
    }
    //NSLog(@"Sessions");
    //NSLog(@"%@", result);
    return result;
}

- (NSMutableArray *) getLevelsBySession:(int) session
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int sqlReturn = 1;
    if(_speechgameDB) {
        NSString* querySQL=[NSString stringWithFormat:@"SELECT * FROM Level WHERE SessionID=%d", session];
        sqlite3_stmt* statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSMutableArray* row = [[NSMutableArray alloc] init];
                NSString* Sentence = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                NSString* TargetWord = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                NSString* TargetSyllable = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
                
                [row addObject:Sentence];
                [row addObject:TargetWord];
                [row addObject:TargetSyllable];
                [result addObject:row];
            }
            
            sqlite3_finalize(statement);
        } else {
            sqlReturn = sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL);
            NSLog(@"Error: %s", sqlite3_errstr(sqlReturn));
        }
        sqlite3_finalize(statement);
    }
    //NSLog(@"Sessions");
    //NSLog(@"%@", result);
    return result;
}

- (NSMutableArray *) getSentencesBySession:(int) session
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int sqlReturn = 1;
    if(_speechgameDB) {
        NSString* querySQL=[NSString stringWithFormat:@"SELECT * FROM Sentence WHERE SessionID=%d", session];
        sqlite3_stmt* statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSMutableArray* row = [[NSMutableArray alloc] init];
                NSString* Sentence = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                NSString* TargetWord = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                NSString* TargetSyllable = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
                
                [row addObject:Sentence];
                [row addObject:TargetWord];
                [row addObject:TargetSyllable];
                [result addObject:row];
            }
            
            sqlite3_finalize(statement);
        } else {
            sqlReturn = sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL);
            NSLog(@"Error: %s", sqlite3_errstr(sqlReturn));
        }
        sqlite3_finalize(statement);
    }
    //NSLog(@"Sessions");
    //NSLog(@"%@", result);
    return result;
}

- (int) getTimePlayedToday {
    int timePlayed = 0;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd 12:00:00"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    //NSString * dateString = [self getDateFromDatabaseString:todaysDate];
    if(_speechgameDB) {
        NSString* querySQL=[NSString stringWithFormat:@"SELECT TimePlayed FROM Session WHERE Date='%@'", dateString];
        sqlite3_stmt* statement=NULL;
        if(sqlite3_prepare_v2(_speechgameDB, [querySQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSNumber* rowTimePlayed = [NSNumber numberWithInteger:sqlite3_column_int(statement, 0)];
                timePlayed += [rowTimePlayed intValue];
                //lastRowDate = date;
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_finalize(statement);
    }
    return timePlayed;
}


-(NSDate*)getDateFromDatabaseString:(NSString*)dateString {
    NSRange dayRange, monthRange, yearRange;
    yearRange.location = 0;
    yearRange.length = 4;
    monthRange.location = 5;
    monthRange.length = 2;
    dayRange.location = 8;
    dayRange.length = 2;
    NSString * year = [dateString substringWithRange:yearRange];
    NSString * month = [dateString substringWithRange:monthRange];
    NSString * day = [dateString substringWithRange:dayRange];
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setMonth:[month intValue]];
    [dateComponents setDay:[day intValue]];
    [dateComponents setYear:[year intValue]];
    [dateComponents setHour:12];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:dateComponents];
}

@end