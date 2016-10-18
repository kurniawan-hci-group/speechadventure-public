//
//  StatsGraph.h
//  speechadventure
//
//  Created by Michael Weber on 7/27/14.
//  Copyright (c) 2014 Zak Rubin. All rights reserved.
//

#import "SpeechAdventureLevel.h"
#import "CorePlot-CocoaTouch.h"


@interface StatsGraph : SpeechAdventureLevel <CPTPlotAreaDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource, CPTScatterPlotDelegate>

+ (StatsGraph *)scene;
- (id)init;

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;
@property (nonatomic, strong) CPTGraphHostingView *scatterPlotView;
@property (nonatomic, readwrite, strong) NSArray *plotData;
@property (nonatomic, strong) CCLabelTTF *graphTitle;

@end