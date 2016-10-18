//
//  OEEvent.h
//  SpeechAdventure
//
//  Created by John Chambers on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OEEvent : NSObject

typedef enum {
    OpenEarsResponse,
    RapidEarsPartial,
    RapidEarsResponse,
    OpenEarsStateChange
} EventType;

@property (nonatomic,copy) NSString *text;
@property (nonatomic,copy) NSNumber *recognitionScore;
@property (nonatomic, assign) EventType eventType;
@property (nonatomic, assign) BOOL isListening;

- (id) initWithText:(NSString*)recognitionText andScore:(NSNumber*)score;

- (id) initWithText:(NSString*)recognitionText andScore:(NSNumber*)score andType:(EventType) type;

- (id) initWithListeningState:(BOOL) listening;


@end
