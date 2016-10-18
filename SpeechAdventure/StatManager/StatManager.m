//
//  StatManager.m
//  SpeechAdventure
//
//  Created by Zak Rubin on 5/9/13.
//
//

#import "StatManager.h"

@interface StatManager()

@end

@implementation StatManager

- (id) init
{
    _statDatabase = [[StatDatabase alloc] init];
    
    // Insert database testing code here
    
    return self;
}

- (void) startNewSessionStats
{
    // Add session to statistics
    //[self setStartGameTimeToNow];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd 12:00:00"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    _timePlayedThisSession = 0;
    _levelsPlayedThisSession = 0;
    _scoreThisSession = 0;
    NSString * query = [NSString stringWithFormat:@"'%@', '%@', %d, %d, %d", @"TestUser", dateString, _timePlayedThisSession, _levelsPlayedThisSession, _scoreThisSession];
    [self addSessionToDatabase:query];
    int session = [[StatManager sharedManager] getSessionCount];
    [self setSessionID:session];
}

- (void) setStartGameTimeToNow
{
    _startGameTime = [NSDate date];
}

- (NSDate *) getGameTime
{
    return _startGameTime;
}

- (NSString *) getStartGameTimeAsDateTime
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd 12:00:00"];
    return [dateFormat stringFromDate:_startGameTime];
}

- (void) calculateAndSetTimePlayedThisSession
{
    NSTimeInterval totalLevelTime = [[NSDate date] timeIntervalSinceDate:_startGameTime];
    _timePlayedThisSession = (int)totalLevelTime;
    _levelsPlayedThisSession++;
}

- (int) getLevelsPlayedThisSession
{
    return _levelsPlayedThisSession;
}

- (int) getTimePlayedToday {
    return [_statDatabase getTimePlayedToday];
}

- (void) setLevelsPlayedThisSession:(int)levelsPlayed
{
    _levelsPlayedThisSession = levelsPlayed;
}

- (void) setSessionID:(int)newSessionID
{
    _sessionID = newSessionID;
    NSLog(@"Session Set: %d", _sessionID);
}

- (void) parseFile:(NSString*) filePath
{
    
}

- (void) uploadStats {
    NSData * database = [_statDatabase getDatabaseFile];
    
    // Begin uploading statistics
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString * returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    NSString *urlString = @"https://users.soe.ucsc.edu/~zarubin/cleft2016/uploadstats.php";
    NSString *filename = [NSString stringWithFormat:@"speechadventure%@", [NSDate date]];
    filename = [filename stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.db\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:database]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
}


- (int) getSessionCount
{
    return [_statDatabase getSessionCount];
}

- (int) getLevelCount
{
    return [_statDatabase getLevelCount];
}

- (int) getSentenceCount
{
    return [_statDatabase getSentenceCount];
}

- (int) getUtteranceCount
{
    return [_statDatabase getUtteranceCount];
}

- (void) updateSession:(NSString *)dataString andSessionID:(int)session
{
    NSString * query  = [[NSString alloc]initWithFormat: @"UPDATE Session SET (PlayerName, Date, TimePlayed, LevelsPlayed) VALUES (%@) WHERE ID=%d", dataString, session];
    [_statDatabase queryDatabase:query];
}

- (void) updateTimeScoreLevelsForThisSession
{
    _levelsPlayedThisSession++;
    NSString * query  = [[NSString alloc]initWithFormat: @"UPDATE Session SET TimePlayed=%d, LevelsPlayed=%d, SessionScore=%d WHERE ID=%d", _timePlayedThisSession, _levelsPlayedThisSession, _scoreThisSession, _sessionID];
    [_statDatabase queryDatabase:query];
}

- (void) addSessionToDatabase: (NSString*) dataString
{
    NSString * query  = [[NSString alloc]initWithFormat: @"INSERT INTO Session (PlayerName, Date, TimePlayed, LevelsPlayed, SessionScore) VALUES (%@)", dataString];
    [_statDatabase queryDatabase:query];
    NSLog(@"Session Count is now: %d", [_statDatabase getSessionCount]);
}

- (void) addLevelToDatabase: (NSString*) dataString
{
    NSString * query  = [[NSString alloc]initWithFormat: @"INSERT INTO Level (SessionID, PlayerName, Date, LevelName, TotalLevelTime, LevelScore) VALUES (%@)", dataString];
    [_statDatabase queryDatabase:query];
    NSLog(@"Level Count is now: %d", [_statDatabase getLevelCount]);
}

- (void) addSentenceToDatabase: (NSString*) dataString
{
    NSString * query  = [[NSString alloc]initWithFormat: @"INSERT INTO Sentence (SessionID, LevelID, Sentence, TargetWords, TargetSyllables) VALUES (%@)", dataString];
    [_statDatabase queryDatabase:query];
    NSLog(@"Sentence Count is now: %d", [_statDatabase getSentenceCount]);
}

- (void) addUtteranceToDatabase: (NSString*) dataString
{
    NSString * query  = [[NSString alloc]initWithFormat: @"INSERT INTO Utterance (SentenceID, Utterance) VALUES (%@)", dataString];
    [_statDatabase queryDatabase:query];
    NSLog(@"Utterance Count is now: %d", [_statDatabase getUtteranceCount]);
}

- (NSMutableArray *) getSessionsByName: (NSString*) playerName
{
    return [_statDatabase getSessionsByName:playerName];
}

- (NSMutableArray *) getSentencesBySession:(int) session
{
    return [_statDatabase getSentencesBySession:session];
}


#pragma mark -
#pragma mark Singleton Stuff. Here be dragons
static StatManager *statManager = nil;

+ (StatManager *) sharedManager
{
    if (statManager == nil) {
        statManager = [[super allocWithZone:NULL] init];
    }
    return statManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
