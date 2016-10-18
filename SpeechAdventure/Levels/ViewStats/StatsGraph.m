//
//  StatsGraph.m
//  speechadventure
//
//  Created by Zachary Rubin on 7/27/14.
//  Copyright (c) 2016 Zak Rubin. All rights reserved.
//

#import "StatsGraph.h"

@implementation StatsGraph
@synthesize plotData;
@synthesize scatterPlotView;

CPTXYPlotSpace *plotSpace;
CPTScatterPlot *dataSourceLinePlot;

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (StatsGraph*)scene {
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Creates a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
    [self.backgroundLayer addChild:background];
    
    //below test functionality
    _graphTitle = [CCLabelTTF labelWithString:@"Statistics" fontName:@"ArialMT" fontSize:36.0f];
    _graphTitle.positionType = CCPositionTypeNormalized;
    _graphTitle.color = [CCColor blackColor];
    _graphTitle.position = ccp(0.5f, 0.9f); // Top Center
    [self addChild:_graphTitle];
    
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 4*winSize.height/20, winSize.width, 2*winSize.height/3)];
    [[CCDirector sharedDirector].view addSubview:scatterPlotView];
    
    [self addToggleButtons];
    [self addToggleButtonsLabels];
    
    [self addUploadButton];
    
    [self showBackButton];
    [self initPlot];

	return self;
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self constructTimeScatterPlot];
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(void)constructTimeScatterPlot {
    NSMutableArray * sessionArray = [[StatManager sharedManager] getSessionsByName:@"TestUser"];
    if([sessionArray count] == 0) return;
    
    NSDate *refDate = [self getDateFromDatabaseString:sessionArray[0][2]];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDateComponents *comp = [NSDateComponents new];
    comp.weekOfYear = 0;
    NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    NSDate *dataRefDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    
    NSMutableArray *newData = [NSMutableArray array];
    int sessionCount = [sessionArray count];
    for ( NSUInteger i = 0; i < sessionCount; i++ ) {
        // Pull in the information from the array
        NSDate * date = [self getDateFromDatabaseString:sessionArray[i][2]];
        int timePlayed = [sessionArray[i][3] intValue];
        double yVal = timePlayed/60.0;
        int levelsPlayed = [sessionArray[i][4] intValue];
        int score = [sessionArray[i][5] intValue];
        NSMutableArray * sentenceData = [[StatManager sharedManager] getSentencesBySession:[sessionArray[i][0] intValue]];
        int sentencesPlayed = [sentenceData count];
        
        // X coordinate determined by distance from the start date.
        NSInteger dateCompare = [self daysBetweenDate:startDate andDate:date];
        NSTimeInterval xVal = oneDay * dateCompare;
        
        //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
        NSComparisonResult result;
        result = [dataRefDate compare:date]; // comparing two dates
        
        if([newData count] == 0) {
            [newData addObject:
             @{ @(CPTScatterPlotFieldX): @(xVal),
                @(CPTScatterPlotFieldY): @(yVal),
                @"2": @(levelsPlayed),
                @"3": @(sentencesPlayed),
                @"4": @(score),
                @"5": @(yVal)
                }
             ];
        } else {
            if(result==NSOrderedAscending) {
                dataRefDate = date;
                [newData addObject:
                 @{ @(CPTScatterPlotFieldX): @(xVal),
                    @(CPTScatterPlotFieldY): @(yVal),
                    @"2": @(levelsPlayed),
                    @"3": @(sentencesPlayed),
                    @"4": @(score),
                    @"5": @(yVal)
                    }
                 ];
                NSLog(@"refdate is less");
            } else if(result==NSOrderedDescending){
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @([newYVal floatValue])
                                                                         }];
            } else {
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @([newYVal floatValue])
                                                                         }];
            }
        }
        self.plotData = newData;
    }
    [self setupScatterPlot];
}

-(void) constructScoreScatterPlot {
    NSMutableArray * sessionArray = [[StatManager sharedManager] getSessionsByName:@"TestUser"];
    if([sessionArray count] == 0) return;
    
    NSDate *refDate = [self getDateFromDatabaseString:sessionArray[0][2]];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDateComponents *comp = [NSDateComponents new];
    comp.weekOfYear = 0;
    NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    NSDate *dataRefDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    
    NSMutableArray *newData = [NSMutableArray array];
    int sessionCount = [sessionArray count];
    for ( NSUInteger i = 0; i < sessionCount; i++ ) {
        // Pull in the information from the array
        NSDate * date = [self getDateFromDatabaseString:sessionArray[i][2]];
        int timePlayed = [sessionArray[i][3] intValue];
        double totalTimePlayed = timePlayed/60.0;
        int yVal = [sessionArray[i][5] intValue];
        int levelsPlayed = [sessionArray[i][4] intValue];
        int score = [sessionArray[i][5] intValue];
        NSMutableArray * sentenceData = [[StatManager sharedManager] getSentencesBySession:[sessionArray[i][0] intValue]];
        int sentencesPlayed = [sentenceData count];
        
        // X coordinate determined by distance from the start date.
        NSInteger dateCompare = [self daysBetweenDate:startDate andDate:date];
        NSTimeInterval xVal = oneDay * dateCompare;
        
        //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
        NSComparisonResult result;
        result = [dataRefDate compare:date]; // comparing two dates
        
        if([newData count] == 0) {
            [newData addObject:
             @{ @(CPTScatterPlotFieldX): @(xVal),
                @(CPTScatterPlotFieldY): @(score),
                @"2": @(levelsPlayed),
                @"3": @(sentencesPlayed),
                @"4": @(score),
                @"5": @(totalTimePlayed)
                }
             ];
        } else {
            if(result==NSOrderedAscending) {
                dataRefDate = date;
                [newData addObject:
                 @{ @(CPTScatterPlotFieldX): @(xVal),
                    @(CPTScatterPlotFieldY): @(score),
                    @"2": @(levelsPlayed),
                    @"3": @(sentencesPlayed),
                    @"4": @(score),
                    @"5": @(totalTimePlayed)
                    }
                 ];
                NSLog(@"refdate is less");
            } else if(result==NSOrderedDescending){
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                totalTimePlayed += [newData[dataLocation][@"5"] doubleValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @(totalTimePlayed)
                                                                         }];
            } else {
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                totalTimePlayed += [newData[dataLocation][@"5"] doubleValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @(totalTimePlayed)
                                                                         }];
            }
        }
        self.plotData = newData;
    }
    [self setupScatterPlot];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.scatterPlotView.hostedGraph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    y.minorTicksPerInterval       = 1;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-500.0) length:CPTDecimalFromDouble(750.0)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-100.0) length:CPTDecimalFromDouble(10000.0)];
    //y.majorTickLength = 50.0f;
}

-(void) constructSentenceScatterPlot {
    NSMutableArray * sessionArray = [[StatManager sharedManager] getSessionsByName:@"TestUser"];
    if([sessionArray count] == 0) return;
    
    NSDate *refDate = [self getDateFromDatabaseString:sessionArray[0][2]];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDateComponents *comp = [NSDateComponents new];
    comp.weekOfYear = 0;
    NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    NSDate *dataRefDate = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:refDate options:0];
    
    NSMutableArray *newData = [NSMutableArray array];
    int sessionCount = [sessionArray count];
    for ( NSUInteger i = 0; i < sessionCount; i++ ) {
        // Pull in the information from the array
        NSDate * date = [self getDateFromDatabaseString:sessionArray[i][2]];
        int timePlayed = [sessionArray[i][3] intValue];
        //double yVal = timePlayed/60.0;
        double totalTimePlayed = timePlayed/60.0;
        int yVal = [sessionArray[i][4] intValue];
        int levelsPlayed = [sessionArray[i][4] intValue];
        int score = [sessionArray[i][5] intValue];
        NSMutableArray * sentenceData = [[StatManager sharedManager] getSentencesBySession:[sessionArray[i][0] intValue]];
        
        int sentencesPlayed = [sentenceData count];
        
        // X coordinate determined by distance from the start date.
        NSInteger dateCompare = [self daysBetweenDate:startDate andDate:date];
        NSTimeInterval xVal = oneDay * dateCompare;
        
        //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
        NSComparisonResult result;
        result = [dataRefDate compare:date]; // comparing two dates
        
        if([newData count] == 0) {
            [newData addObject:
             @{ @(CPTScatterPlotFieldX): @(xVal),
                @(CPTScatterPlotFieldY): @(sentencesPlayed),
                @"2": @(levelsPlayed),
                @"3": @(sentencesPlayed),
                @"4": @(score),
                @"5": @(totalTimePlayed)
                }
             ];
        } else {
            if(result==NSOrderedAscending) {
                dataRefDate = date;
                [newData addObject:
                 @{ @(CPTScatterPlotFieldX): @(xVal),
                    @(CPTScatterPlotFieldY): @(sentencesPlayed),
                    @"2": @(levelsPlayed),
                    @"3": @(sentencesPlayed),
                    @"4": @(score),
                    @"5": @(totalTimePlayed)
                    }
                 ];
                NSLog(@"refdate is less");
            } else if(result==NSOrderedDescending){
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                totalTimePlayed += [newData[dataLocation][@"5"] doubleValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @(totalTimePlayed)
                                                                         }];
            } else {
                //Date within range, combine information
                int dataLocation = [newData count]-1;
                double oldYVal = [newData[dataLocation][@(CPTScatterPlotFieldY)] doubleValue];
                NSNumber * newYVal = [[NSNumber alloc] initWithDouble:oldYVal+yVal];
                levelsPlayed += [newData[dataLocation][@"2"] intValue];
                sentencesPlayed += [newData[dataLocation][@"3"] intValue];
                score += [newData[dataLocation][@"4"] intValue];
                totalTimePlayed += [newData[dataLocation][@"5"] doubleValue];
                int oldXVal = [newData[dataLocation][@(CPTScatterPlotFieldX)] intValue];
                NSLog(@"Merged data points");
                [newData replaceObjectAtIndex:dataLocation withObject:@{ @(CPTScatterPlotFieldX): @(oldXVal),
                                                                         @(CPTScatterPlotFieldY): @([newYVal floatValue]),
                                                                         @"2": @(levelsPlayed),
                                                                         @"3": @(sentencesPlayed),
                                                                         @"4": @(score),
                                                                         @"5": @(totalTimePlayed)
                                                                         }];
            }
        }
        self.plotData = newData;
    }
    [self setupScatterPlot];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.scatterPlotView.hostedGraph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    y.minorTicksPerInterval       = 1;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-100.0) length:CPTDecimalFromDouble(750.0)];
    
}

-(void) mergeDataPoints {
    
}

-(void) setupScatterPlot {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 4*winSize.height/20, winSize.width, 2*winSize.height/3)];
    [[CCDirector sharedDirector].view addSubview:scatterPlotView];
    
    NSMutableArray * sessionArray = [[StatManager sharedManager] getSessionsByName:@"TestUser"];
    if([sessionArray count] == 0) return;
    
    NSDate *refDate = [self getDateFromDatabaseString:sessionArray[0][2]];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:scatterPlotView.bounds];
    self.scatterPlotView.hostedGraph = graph;
    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    
    // Theme
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    
    // Setup scatter plot space
    plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    NSTimeInterval xLow       = (oneDay - 1);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-5.0) length:CPTDecimalFromDouble(50.0)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval       = 0;
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = M_PI_4;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(5.0);
    y.minorTicksPerInterval       = 0;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    
    // Create a plot that uses the data source method
    dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    [self setGlobalYRange:-10.0f andMax:1000.0f];
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(25.0, 25.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate                        = self;
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 1.5;

}

- (void) setGlobalYRange:(float) min andMax:(float) max {
    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(min)
                                                              length:CPTDecimalFromFloat(max)];
    plotSpace.globalYRange = globalYRange;
}

- (void) addUploadButton {
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(uploadStats:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.8f, 0.9f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale *= 0.75f;
    [self addChild:testLevelButton];
    
    //label 4
    CCLabelTTF *label;
    label = [CCLabelTTF labelWithString:@"Upload" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.85f, 0.92f);
    [self addChild:label];
}

- (void) addToggleButtons {
    //Button 1
    CCButton *testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(showTime:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.0f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.4f;
    [self addChild:testLevelButton];
    //Button 2
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(showScores:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.25f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.4f;
    [self addChild:testLevelButton];
    
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(showSentences:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.50f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.4f;
    [self addChild:testLevelButton];
    
    testLevelButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium_sel.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Textbox_medium.png"]];
    [testLevelButton setTarget:self selector:@selector(showSettings:)];
    testLevelButton.positionType = CCPositionTypeNormalized;
    testLevelButton.position = ccp(0.75f, 0.05f);
    [testLevelButton setAnchorPoint:CGPointZero];
    testLevelButton.scale = 0.4f;
    [self addChild:testLevelButton];
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

- (void) addToggleButtonsLabels {
    CCLabelTTF *label;
    
    //label 1
    label = [CCLabelTTF labelWithString:@"Time Played" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.015f, 0.05f);
    [self addChild:label];
    
    //label 2
    label = [CCLabelTTF labelWithString:@"Score" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.31f, 0.05f);
    [self addChild:label];
    
    //label 3
    label = [CCLabelTTF labelWithString:@"Sentences" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.53f, 0.05f);
    [self addChild:label];
    
    //label 4
    label = [CCLabelTTF labelWithString:@"Settings" fontName:@"ArialMT" fontSize:20.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    [label setAnchorPoint:CGPointZero];
    label.position = ccp(0.80f, 0.05f);
    [self addChild:label];
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(NSArray*)grabAggregateData:(CPTScatterPlot *)plot {
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
    return nil;
}

-(NSArray*)splitSQLDateToComponents:(CPTScatterPlot *)plot {
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
    return nil;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index {
    //CPTGraph *graph = self.scatterPlotView.hostedGraph.graph;
    
    CPTPlotSpaceAnnotation *annotation;
    
    // Remove the annotation
    [self removeAnnotation];
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSDictionary *dataPoint = self.plotData[index];
    
    NSNumber *x = dataPoint[@(CPTScatterPlotFieldX)];
    NSNumber *y = dataPoint[@(CPTScatterPlotFieldY)];
    NSNumber *levelsPlayed = dataPoint[@"2"];
    NSNumber *SentencesSpoken = dataPoint[@"3"];
    NSNumber *score = dataPoint[@"4"];
    NSNumber *timePlayed = dataPoint[@"5"];
    
    NSArray *anchorPoint = @[x, y];
    
    // Format the date
    NSMutableArray * sessionArray = [[StatManager sharedManager] getSessionsByName:@"TestUser"];
    if([sessionArray count] == 0) return;
    
    NSDate *refDate = [self getDateFromDatabaseString:sessionArray[0][2]];
    refDate = [refDate dateByAddingTimeInterval:[x integerValue]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:refDate];
    NSString * dateYearMonthDay = [NSString stringWithFormat:@"%d-%d-%d", components.year, components.month, components.day];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *timePlayedString = [formatter stringFromNumber:timePlayed];
    //yString = [NSString stringWithFormat:@"Date: %@\nMinutes Played: %@\nLevels Played: %@\nTargetSentences Spoken: %@\nSyllables: %@", dateYearMonthDay, yString, levelsPlayed, SentencesSpoken, @"/k, g/"];
    NSString * annotationText = [NSString stringWithFormat:@"Date: %@\nMinutes Played: %@\nLevels Played: %@\nTargetSentences Spoken: %@\nScore: %@", dateYearMonthDay, timePlayedString, levelsPlayed, SentencesSpoken, score];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:annotationText style:hitAnnotationTextStyle];
    annotation                = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.scatterPlotView.hostedGraph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    annotation.contentLayer   = textLayer;
    annotation.displacement   = CGPointMake(120.0, 75.0);
    self.symbolTextAnnotation = annotation;
    [self.scatterPlotView.hostedGraph.plotAreaFrame.plotArea addAnnotation:annotation];
}

-(void)scatterPlotDataLineWasSelected:(CPTScatterPlot *)plot {
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
}

-(void)scatterPlotDataLineTouchDown:(CPTScatterPlot *)plot {
    NSLog(@"scatterPlotDataLineTouchDown: %@", plot);
}

-(void)scatterPlotDataLineTouchUp:(CPTScatterPlot *)plot {
    NSLog(@"scatterPlotDataLineTouchUp: %@", plot);
}

-(void)removeAnnotation {
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
    
    if ( annotation ) {
        CPTGraph *graph = self.scatterPlotView.hostedGraph;
        
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea {
    // Remove the annotation
    [self removeAnnotation];
}


#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    return self.plotData[index][@(fieldEnum)];
}

- (void) showTime:(id)sender {
    [self removeChild:_graphTitle];
    [self removeAnnotation];
    _graphTitle = [CCLabelTTF labelWithString:@"Time Performance" fontName:@"ArialMT" fontSize:36.0f];
    _graphTitle.positionType = CCPositionTypeNormalized;
    _graphTitle.color = [CCColor blackColor];
    _graphTitle.position = ccp(0.5f, 0.9f); // Top Center
    [self addChild:_graphTitle];
    [scatterPlotView removeFromSuperview];
    [self constructTimeScatterPlot];
    //[self setupScatterPlot];
}

- (void) showScores:(id)sender {
    [self removeChild:_graphTitle];
    [self removeAnnotation];
    _graphTitle = [CCLabelTTF labelWithString:@"Score Performance" fontName:@"ArialMT" fontSize:36.0f];
    _graphTitle.positionType = CCPositionTypeNormalized;
    _graphTitle.color = [CCColor blackColor];
    _graphTitle.position = ccp(0.5f, 0.9f); // Top Center
    [self addChild:_graphTitle];
    [scatterPlotView removeFromSuperview];
    [self constructScoreScatterPlot];
    //[self setupScatterPlot];
}

- (void) showSentences:(id)sender {
    [self removeChild:_graphTitle];
    [self removeAnnotation];
    _graphTitle = [CCLabelTTF labelWithString:@"Sentence Performance" fontName:@"ArialMT" fontSize:36.0f];
    _graphTitle.positionType = CCPositionTypeNormalized;
    _graphTitle.color = [CCColor blackColor];
    _graphTitle.position = ccp(0.5f, 0.9f); // Top Center
    [self addChild:_graphTitle];
    [scatterPlotView removeFromSuperview];
    //[self constructLevelScatterPlot];
    [self constructSentenceScatterPlot];
    //[self setupScatterPlot];
}

- (void) uploadStats:(id)sender {
    [[StatManager sharedManager] uploadStats];
}

- (void) showSettings:(id)sender {
    //
    [scatterPlotView removeFromSuperview];
}

- (void) goBack:(id)sender {
    [scatterPlotView removeFromSuperview];
    [self returnToMainMenu];
}


@end
