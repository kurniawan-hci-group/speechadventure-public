//
//  OEManager.m
//  SpeechAdventure
//
//  Created by John Chambers on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <OpenEars/OEPocketsphinxController.h>
#import <RapidEars/OEPocketsphinxController+RapidEars.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <Rejecto/OELanguageModelGenerator+Rejecto.h>
#import <OpenEars/OEAcousticModel.h>

#import "OEManager.h"

@interface OEManager()

@end

@implementation OEManager

#define recordingCutoffTime 3

#pragma mark -
#pragma mark Memory Management

// Lazily allocate utility objects

// Lazily allocate PocketsphinxController.
- (OEPocketsphinxController *)pocketsphinxController
{
	if (_pocketsphinxController == nil) {
        _pocketsphinxController = [OEPocketsphinxController sharedInstance];
        //great for troubleshooting
        _pocketsphinxController.verbosePocketSphinx = FALSE; // Set true for debug spewing
	}
	return _pocketsphinxController;
}

// Lazily allocate OpenEarsEventsObserver.
- (OEEventsObserver *)openEarsEventsObserver
{
	if (_openEarsEventsObserver == nil) {
		_openEarsEventsObserver = [[OEEventsObserver alloc] init];
	}
	return _openEarsEventsObserver;
}

//Lazily allocate LanguageModelGenerator
- (OELanguageModelGenerator *)languageModelGenerator
{
    if (_languageModelGenerator == nil) {
        _languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    }
    return _languageModelGenerator;
}

//Lazily allocate notificationRegistrants array
- (NSMutableArray *)notificationRegistrants
{
    if (_notificationRegistrants == nil)
    {
        _notificationRegistrants = [[NSMutableArray alloc] initWithCapacity:15];
    }
    return _notificationRegistrants;
}

//Lazily allocate modelsDictionary
- (NSMutableDictionary *)modelsDictionary
{
    if (_modelsDictionary == nil)
    {
        _modelsDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _modelsDictionary;
}

#pragma mark -
#pragma mark Initializers

- (id) initWithModel:(NSString *)modelName
{
    if (self = [super init])
    {
        //register for OpenEars events
        [_openEarsEventsObserver setDelegate:self];
        //apply any parameters
        [self setModel:modelName];
        //[_pocketsphinxController requestMicPermission];
    }
    NSLog(@"Successfully initialized");
    return self;
}

- (id) init
{
    // Fix lazy allocation @synthesis issues
    _openEarsEventsObserver = self.openEarsEventsObserver;
    _notificationRegistrants = self.notificationRegistrants;
    _languageModelGenerator = self.languageModelGenerator;
    _modelsDictionary = self.modelsDictionary;
    //[_pocketsphinxController requestMicPermission];
    return [self initWithModel:@"OpenEars1"];
}

#pragma mark -
#pragma mark PocketSphinx Control

- (void) startListening
{
    if(!_listeningStarted) {
        NSLog(@"OpenEars: About to start listening");
        _pocketsphinxController = self.pocketsphinxController;
        [_pocketsphinxController setRapidEarsToVerbose:FALSE]; // This defaults to FALSE but will give a lot of debug readout if set TRUE
        [_pocketsphinxController setFinalizeHypothesis:TRUE]; // This defaults to TRUE and will return a final hypothesis, but can be turned off to save a little CPU and will then return no final hypothesis; only partial "live" hypotheses.
        [_pocketsphinxController startRealtimeListeningWithLanguageModelAtPath:_modelGrammarPath dictionaryAtPath:_modelDictionaryPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelAlternateEnglish1"]];
        [_pocketsphinxController setVadThreshold:3.5f];
        _listeningStarted = true;
        NSLog(@"OpenEars: Started listening: %f", [_pocketsphinxController vadThreshold]);
    }
}

- (void) stopListening
{
    [_pocketsphinxController stopListening];
    _listeningStarted = false;
    _isListening = false;
    NSLog(@"OpenEars: Stopped listening");
}

- (void) pauseListening
{
    if(_isListening) {
        [_pocketsphinxController suspendRecognition];
        _isListening = false;
        NSLog(@"OpenEars: Paused listening");
    }
}

- (void) resumeListening
{
    [_pocketsphinxController resumeRecognition];
    _isListening = true;
    NSLog(@"OpenEars: Resumed listening");
}

- (NSString*) getAudioLevel
{
    return [NSString stringWithFormat:@"Input level:%f",[_pocketsphinxController pocketsphinxInputLevel]];
}

- (float) getRawAudioLevel
{
    return [_pocketsphinxController pocketsphinxInputLevel];
}

- (void) setModel:(NSString *) modelName
{
    NSString *dicName = [modelName stringByAppendingString:@".dic"];
    NSString *grammarName = [modelName stringByAppendingString:@".languagemodel"];
    _modelGrammarPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], grammarName];
    _modelDictionaryPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], dicName];
}

- (void) swapModel:(NSString *) modelName
{
    NSString *dicName = [modelName stringByAppendingString:@".dic"];
    NSString *grammarName = [modelName stringByAppendingString:@".languagemodel"];
    _modelGrammarPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], grammarName];
    _modelDictionaryPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], dicName];
    self.modelSwapped = false;
    //while(!_modelSwapped) {
        [_pocketsphinxController changeLanguageModelToFile:_modelGrammarPath withDictionary:_modelDictionaryPath];
        //usleep(1000000);
    //}
    
    
    // Wait for the model swap to finish
    
    // 100 ms sleep to deal with a race condition
    
}

- (void) swapToDynamicModel:(NSString *) grammarPath withDictionary: (NSString*) dictionaryPath
{
    _modelGrammarPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], grammarPath];
    _modelDictionaryPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], dictionaryPath];
    [_pocketsphinxController changeLanguageModelToFile:_modelGrammarPath withDictionary:_modelDictionaryPath];
    
}

#pragma mark -
#pragma mark Notification Registration
- (void) registerDelegate:(id<OEDelegate>)delegate shouldReturnPartials:(BOOL) shouldReturnPartials
{
    [delegate setShouldReturnPartials:shouldReturnPartials];
    [_notificationRegistrants addObject:delegate];
    NSLog(@"OpenEars Delegate registered");
}

- (void) removeDelegate:(id<OEDelegate>)delegate
{
    [_notificationRegistrants removeObject:delegate];
    NSLog(@"OpenEars Delegate removed");
}

#pragma mark -
#pragma mark Singleton Stuff
static OEManager *theManager = nil;

+ (OEManager *) sharedManager
{
    if (theManager == nil) {
        theManager = [[super allocWithZone:NULL] init];
    }
    return theManager;
}

#pragma mark -
#pragma mark OpenEarsEventsObserver delegate methods

// pocketsphinxDidReceiveHypothesis is deprecated, please use rapidEarsDidDetectFinishedSpeechAsWordArray 
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    
	NSLog(@"OpenEars received hypothesis %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    if ([hypothesis isEqualToString:@"STOP"])
    {
        [self stopListening];
    }
    
    //generate the event
    OEEvent *voiceEvent = [[OEEvent alloc] initWithText:hypothesis andScore:[[NSNumber alloc] initWithDouble:[recognitionScore doubleValue]]];
    [self sendOEEventToCallbacks:voiceEvent];
}

- (void) rapidEarsDidReceiveLiveSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore
{
    //NSLog(@"detected words: %@",hypothesis);
    OEEvent *voiceEvent = [[OEEvent alloc] initWithText:hypothesis andScore:[[NSNumber alloc] initWithDouble:0.0] andType:RapidEarsPartial];
    [self sendOEEventToCallbacks:voiceEvent];
}

- (void) rapidEarsDidReceiveFinishedSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore
{
    NSLog(@"detected complete statement: %@",hypothesis);
    // Generate and deliver the event
    OEEvent *voiceEvent = [[OEEvent alloc] initWithText:hypothesis andScore:[[NSNumber alloc] initWithDouble:0.0] andType:RapidEarsResponse];
    [self sendOEEventToCallbacks:voiceEvent];
}

- (void) rapidEarsDidDetectBeginningOfSpeech
{
    NSLog(@"rapidEarsDidDetectBeginningOfSpeech");
}

- (void) rapidEarsDidDetectEndOfSpeech
{
    NSLog(@"rapidEarsDidDetectEndOfSpeech");
}

- (void) pocketSphinxContinuousSetupDidFail
{
    NSLog(@"OpenEars setup failed");
}

- (void) pocketsphinxDidCompleteCalibration
{
    if (_debuggingMode) {
        NSLog(@"OpenEars calibration complete");
    }
}

- (void) pocketsphinxRecognitionLoopDidStart {
    _isListening = true;
    NSLog(@"Recognition loop started");
}

- (void) pocketsphinxDidResumeRecognition {
    if (_debuggingMode) {
        NSLog(@"OpenEars resume complete");
    }
}

- (void) setSecondsOfSilence:(float) seconds {
    [_pocketsphinxController setSecondsOfSilenceToDetect:seconds];
    _pocketsphinxController.continuousModel.secondsOfSilenceToDetect = seconds;
}

- (void) pocketsphinxDidDetectSpeech
{
    NSLog(@"OpenEars detected speech");
    //_recordingCutoffTimer = [NSTimer scheduledTimerWithTimeInterval:recordingCutoffTime target:self selector:@selector(recordingCutoff) userInfo:nil repeats:NO];
    OEEvent *listening = [[OEEvent alloc] initWithListeningState:true];
    [self sendOEStateToCallbacks:listening];
}

- (void) pocketsphinxDidDetectFinishedSpeech
{
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
    
    OEEvent *listening = [[OEEvent alloc] initWithListeningState:false];
    [self sendOEStateToCallbacks:listening];
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString
{
    self.modelSwapped = true;
    NSLog(@"Changed to model %@", newLanguageModelPathAsString);
    OEEvent *voiceEvent = [[OEEvent alloc] initWithText:newLanguageModelPathAsString andScore:[[NSNumber alloc] initWithDouble:0.0] andType:OpenEarsStateChange];
    [self sendOEEventToCallbacks:voiceEvent];
}

// This ensures that the system doesn't get locked up with a big sentence.
// Deprecated for use since RapidEars Implementation
- (void) recordingCutoff
{
    /*NSLog(@"Recording is too long, cutting"); // Log it.
    [_pocketsphinxController suspendRecognition];
    //[_pocketsphinxController.continuousModel stopDevice];
    _recordingCutoffTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(recordingResume) userInfo:nil repeats:NO];*/
}

- (void) recordingResume
{
    
}

- (void) sendOEEventToCallbacks:(OEEvent *) event
{
    //actually deliver the event
    NSEnumerator *registrantArrayTraverser = [_notificationRegistrants objectEnumerator];
    id<OEDelegate> currentRegistrant;
    
    if(_isListening) {
        while (currentRegistrant = [registrantArrayTraverser nextObject])
        {
            if ([currentRegistrant conformsToProtocol:@protocol(OEDelegate)])
            {
                [currentRegistrant receiveOEEvent:event];
            }
        }
    }
}

- (void) sendOEStateToCallbacks:(OEEvent *) state
{
    //actually deliver the event
    NSEnumerator *registrantArrayTraverser = [_notificationRegistrants objectEnumerator];
    id<OEDelegate> currentRegistrant;
    
    while (currentRegistrant = [registrantArrayTraverser nextObject])
    {
        if ([currentRegistrant conformsToProtocol:@protocol(OEDelegate)])
        {
            [currentRegistrant receiveOEState:state];
        }
    }
}

@end
