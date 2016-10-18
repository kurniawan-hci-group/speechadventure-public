//
//  StatManager.h
//  SpeechAdventure
//
//  Created by Zak Rubin on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import "StatDatabase.h"

@interface StatManager : NSObject

- (void) startNewSessionStats;
- (void) setStartGameTimeToNow;
- (NSDate *) getGameTime;
- (NSString *) getStartGameTimeAsDateTime;
- (void) calculateAndSetTimePlayedThisSession;
- (int) getTimePlayedToday;
- (int) getLevelsPlayedThisSession;
- (void) setLevelsPlayedThisSession:(int) levelsPlayed;

// SQLite Functions
- (int) getSessionCount;
- (int) getLevelCount;
- (int) getSentenceCount;
- (int) getUtteranceCount;
- (void) updateSession:(NSString *)dataString andSessionID:(int)session;
- (void) updateTimeScoreLevelsForThisSession;
//- (void) updateTimePlayedAndLevelsPlayedInSession:(NSString *)dataString andSessionID:(int)session;
- (void) addSessionToDatabase:(NSString*) dataString;
- (void) addLevelToDatabase:(NSString*) dataString;
- (void) addSentenceToDatabase:(NSString*) dataString;
- (void) addUtteranceToDatabase:(NSString*) dataString;
- (NSMutableArray *) getSessionsByName:(NSString*) playerName;
- (NSMutableArray *) getSentencesBySession:(int) session;

// Deprecated functions from CSV DBs
- (void) uploadStats;
- (void) pushStatsToDatabase;

+ (StatManager *) sharedManager;

@property (nonatomic) int sessionID;
@property (nonatomic) int levelID;
@property (nonatomic) int sentenceID;
@property (nonatomic) int utteranceID;
@property (nonatomic) int levelsPlayedThisSession;
@property (nonatomic) int timePlayedThisSession;
@property (nonatomic) int scoreThisSession;
@property (nonatomic, retain) NSDate* startGameTime;
@property (nonatomic, strong) StatDatabase* statDatabase;

@end
