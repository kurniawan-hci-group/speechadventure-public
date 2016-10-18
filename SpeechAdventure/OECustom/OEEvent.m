//
//  OEEvent.m
//  SpeechAdventure
//
//  Created by John Chambers on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OEEvent.h"

@implementation OEEvent

- (id)initWithText:(NSString *)recognitionText andScore:(NSNumber *)score
{
    if (self = [super init])
    {
        _text = recognitionText;
        _recognitionScore = score;
        _eventType = OpenEarsResponse;
    }
    return self;
}

- (id)initWithText:(NSString *)recognitionText andScore:(NSNumber *)score andType:(EventType ) type
{
    if (self = [super init])
    {
        _text = recognitionText;
        _recognitionScore = score;
        _eventType = type;
    }
    return self;
}

- (id) initWithListeningState:(BOOL) listening
{
    if (self = [super init])
    {
        _isListening = listening;
    }
    return self;
}

@end
