//
//  Chart.h
//  StratPad
//
//  Created by Julian Wood on 12-02-27.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  For mini charts, we figure out the latest measurement from all charts, and then plot the previous 2 years
//  For main charts, we want a grid of 2y, 5y or 8y, depending on the chart start and end dates
//  We could just always have 24 segments
//  If there was a 3 month chart, could just label the 1st, 9th and 17th segment
//  Or we could have 3 segments
//  √ Or we could have a 1 year minimum - maybe we round up to the nearest year for the grid √
//  1y - 12 segs - 1 mo interval
//  2y - 24 segs - 1 mo
//  3y - 18 segs - 2 mo
//  4y - 24 segs - 2 mo
//  5y - 20 segs - 3 mo
//  ...

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "StratFile.h"
#import "YammerPublishedReport.h"

#define primaryChartLayer    [NSNumber numberWithInt:ZLayerPrimary]
#define overlayChartLayer    [NSNumber numberWithInt:ZLayerOverlay]

typedef enum {
    GradientPositionStart,
    GradientPositionEnd
} GradientPosition;

typedef enum {
    ZLayerPrimary = 0,
    ZLayerOverlay = 1
} Zlayer;


typedef enum {
    ChartTypeNone       = 0, // eg.the overlay could be none
    ChartTypeLine       = 1,
    ChartTypeBar        = 2,
    ChartTypeArea       = 3,
    ChartTypeComments   = 4
} ChartType;

typedef enum {
    ColorSchemeRed          = 0,
    ColorSchemeOrange       = 1,
    ColorSchemeYellow       = 2,
    ColorSchemeGreen        = 3,
    ColorSchemeRoyal        = 4,
    ColorSchemeTurquoise    = 5,
    ColorSchemeGrey         = 6,
    ColorSchemeSky          = 7,
} ColorScheme;

@class Metric;

@interface Chart : NSManagedObject

// name of the chart
@property (nonatomic, retain) NSString * title;

// 0 is the primary, 1 is the overlay - room for further overlays if necessary
@property (nonatomic, retain) NSNumber * zLayer;

// what does the chart look like? Use the ChartType enum
@property (nonatomic, retain) NSNumber * chartType;

// compute: http://people.hofstra.edu/stefan_waner/realworld/newgraph/regressionframes.html
// figure out if we have linear or some other best fit and draw it
@property (nonatomic, retain) NSNumber * showTrend;

// this will determine the fill colour for the bars
@property (nonatomic, retain) NSNumber * colorScheme;

// should we show the target value?
@property (nonatomic, retain) NSNumber * showTarget;

// the metric we are using to gather measurements used in this chart
@property (nonatomic, retain) Metric *metric;

// the user defined order of charts within their category; objective categories are ordered as in the enum
@property (nonatomic, retain) NSNumber * order;

// this is the UUID of a chart in another metric; required field
// only relevant when this chart is not an overlay
@property (nonatomic, retain) NSString * overlay;

// a globally unique id to identify this chart, so that we can reference from another chart as the overlay
// NB. we couldn't nest - we have to relate a chart to its metric (ie overlay charts with different metrics)
@property (nonatomic, retain) NSString * uuid;

// optional; this should override the calculated number from ChartView if non-nil
@property (nonatomic, retain) NSNumber * yAxisMax;

// inverse
@property (nonatomic, retain) YammerPublishedReport *yammerPublishedReport;

@end

@interface Chart (Convenience)
+ (NSArray*)chartsSortedByOrderForStratFile:(StratFile*)stratFile;
+ (Chart*)chartWithUUID:(NSString*)uuid;
+ (Chart*)chartAtPage:(NSUInteger)pageNumber stratFile:(StratFile*)stratFile;
- (UIColor*)colorForGradientStart;
- (UIColor*)colorForGradientEnd;
+ (NSString*)colorSchemeNameForColorScheme:(ColorScheme)colorScheme;
+ (NSArray*)colorSchemeNames;
+ (UIColor*)colorForColorScheme:(ColorScheme)colorScheme gradientPosition:(GradientPosition)gradientPosition;

// check if we have a valid overlay for this chart, with a valid metric, summary and chart type
- (BOOL)shouldDrawOverlay;

// the date of the first measurement, normalized to the first day of the month, making sure the target date is included
- (NSDate*)startDate;

// the difference between the first and last measurement, making sure the target date is included
- (NSUInteger)durationInMonths;

// tells us how many months should be between ticks on a chart; eg. if your chart spans 4 yrs, then each tick should represent a quarter (3 mos)
+ (NSUInteger)intervalForDuration:(NSUInteger)durationInMonths;

// given a chart duration, how many months should the grid cover? we can then find out how many segments(cols) there are
// by dividing by durationInMonths
// eg. if a chart is 17 mo, the grid duration will be 24 mo, and interval will be 1 mo, cols will be 24
+ (NSUInteger)gridDurationForChartDuration:(NSUInteger)durationInMonths;

// figures out a suitable maximum value for a chart, given the maximum measurement value
+(CGFloat)getYMax:(CGFloat)maxVal;

// convenience method which checks chart.yAxisMax and if nil, then uses yAxisMaxFromMeasurements + algorithm
- (NSNumber*)yAxisMaxFromChartOrMeasurement;

// dtermines the max measurement value or target value
- (CGFloat)yAxisMaxFromMeasurements;

@end
