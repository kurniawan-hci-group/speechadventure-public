//
//  OEManager.h
//  SpeechAdventure
//
//  Created by John Chambers on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class OEPocketsphinxController;

#import <OpenEars/OEEventsObserver.h>
#import <RapidEars/OEEventsObserver+RapidEars.h>

#import <OpenEars/OELanguageModelGenerator.h>

#import "OEDelegate.h"

@interface OEManager : NSObject<OEEventsObserverDelegate>

- (id) initWithModel:(NSString *) modelName;
- (id) init;

- (void) startListening;
- (void) stopListening;
- (void) pauseListening;
- (void) resumeListening;
- (void) setSecondsOfSilence:(float) seconds;
- (void) recordingCutoff;
- (NSString*) getAudioLevel;
- (float) getRawAudioLevel;

- (void) setModel:(NSString *) modelName;
- (void) swapModel:(NSString *) modelName;
- (void) swapToDynamicModel:(NSString *) grammarPath withDictionary: (NSString*) dictionaryPath;

- (void) registerDelegate:(id <OEDelegate>) delegate shouldReturnPartials:(BOOL) returnPartials;
- (void) removeDelegate:(id <OEDelegate>) delegate;

//have a shared manager for the whole program
+ (OEManager *) sharedManager;

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;
@property (nonatomic, copy) NSString *modelKeyword;
@property (nonatomic, copy) NSString *modelDictionaryPath;
@property (nonatomic, copy) NSString *modelGrammarPath;
@property (nonatomic, assign) BOOL listeningStarted;
@property (nonatomic, assign) BOOL isListening;
@property (nonatomic, assign) BOOL modelSwapped;
@property (nonatomic, assign) BOOL debuggingMode;
@property (nonatomic, assign) BOOL useLiveSpeech;
@property (nonatomic, strong) OELanguageModelGenerator *languageModelGenerator;
@property (nonatomic, strong) NSMutableArray *notificationRegistrants;
@property (nonatomic, strong) NSMutableDictionary *modelsDictionary;
@property (nonatomic, strong) NSTimer *recordingCutoffTimer;

@end


