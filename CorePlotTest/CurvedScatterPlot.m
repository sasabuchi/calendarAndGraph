//
//  CurvedScatterPlot.m
//  Plot_Gallery_iOS
//
//  Created by Nino Ag on 23/10/11.

#import "CurvedScatterPlot.h"

static NSString *const kFirst  = @"First Derivative";
static NSString *const kSecond = @"Second Derivative";

static NSInteger X_INTERVAL_LENGTH_HOUR = 4;

@interface CurvedScatterPlot()

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;

@property (nonatomic, readwrite, strong) NSArray *plotData1;
@property (nonatomic, readwrite, strong) NSArray *plotData2;

@end

@implementation CurvedScatterPlot

@synthesize symbolTextAnnotation;
@synthesize plotData;
@synthesize plotData1;
@synthesize plotData2;

+(void)loadGraph
{
    [super registerPlotItem:self];
}

-(id)initWithDate:(NSDate *)date
{
    if ( (self = [super init]) ) {
        self.title   = @"Curved Scatter Plot";
        self.section = kLinePlots;
        self.renderDate = date;
    }

    return self;
}

-(void)killGraph
{
    if ( self.graphs.count ) {
        CPTGraph *graph = (self.graphs)[0];

        CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(void)generateData
{
    
    //if ( self.plotData == nil ) {
        const NSTimeInterval oneDay = 24 * 60 * 60;
        NSMutableArray *contentArray = [NSMutableArray array];

        for ( NSUInteger i = 0; i < 24; i++ ) {
            NSTimeInterval xVal = oneDay / 24 * i;
            double yVal = 1.2 * arc4random() / (double)UINT32_MAX + 1.2;
            [contentArray addObject:@{ @"x": @(xVal), @"y": @(yVal) }
            ];
        }

        self.plotData = contentArray;
    //}
    /*
    if ( self.plotData1 == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];

        NSArray *dataArray = self.plotData;

        for ( NSUInteger i = 1; i < dataArray.count; i++ ) {
            NSDictionary *point1 = dataArray[i - 1];
            NSDictionary *point2 = dataArray[i];

            double x1   = [(NSNumber *)point1[@"x"] doubleValue];
            double x2   = [(NSNumber *)point2[@"x"] doubleValue];
            double dx   = x2 - x1;
            double xLoc = (x1 + x2) * 0.5;

            double y1 = [(NSNumber *)point1[@"y"] doubleValue];
            double y2 = [(NSNumber *)point2[@"y"] doubleValue];
            double dy = y2 - y1;

            [contentArray addObject:@{ @"x": @(xLoc),
                                       @"y": @( (dy / dx) / 20.0 ) }
            ];
        }

        //self.plotData1 = contentArray;
   // }
    
    
    
    if ( self.plotData2 == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];

        NSArray *dataArray = self.plotData1;

        for ( NSUInteger i = 1; i < dataArray.count; i++ ) {
            NSDictionary *point1 = dataArray[i - 1];
            NSDictionary *point2 = dataArray[i];

            double x1   = [(NSNumber *)point1[@"x"] doubleValue];
            double x2   = [(NSNumber *)point2[@"x"] doubleValue];
            double dx   = x2 - x1;
            double xLoc = (x1 + x2) * 0.5;

            double y1 = [(NSNumber *)point1[@"y"] doubleValue];
            double y2 = [(NSNumber *)point2[@"y"] doubleValue];
            double dy = y2 - y1;

            [contentArray addObject:@{ @"x": @(xLoc),
                                       @"y": @( (dy / dx) / 20.0 ) }
            ];
        }

        self.plotData2 = contentArray;
    }*/
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft   += self.titleSize * CPTFloat(2.25);
    graph.plotAreaFrame.paddingTop    += self.titleSize;
    graph.plotAreaFrame.paddingRight  += self.titleSize;
    graph.plotAreaFrame.paddingBottom += self.titleSize;
    graph.plotAreaFrame.masksToBorder  = NO;

    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake( self.titleSize * CPTFloat(0.625), self.titleSize * CPTFloat(0.625) );

    // date range
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 2.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(3.0)];
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(60 * 60 * X_INTERVAL_LENGTH_HOUR);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    x.minorTicksPerInterval       = 0;
   // x.minorTicksPerInterval = 4;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.renderDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = CPTFloat(M_PI_4);

    lineCap.lineStyle = x.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    x.axisLineCapMax  = lineCap;

    x.title       = self.xAxisTitle;
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 4;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(oneDay / 24);

    lineCap.lineStyle = y.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    y.axisLineCapMax  = lineCap;
    y.axisLineCapMin  = lineCap;

    y.title       = self.yAxisTitle;
    y.titleOffset = self.titleSize * CPTFloat(1.25);

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = self.dataTitle;

    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor orangeColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // First derivative
    CPTScatterPlot *firstPlot = [[CPTScatterPlot alloc] init];
    firstPlot.identifier    = kFirst;
    lineStyle.lineWidth     = 2.0;
    lineStyle.lineColor     = [CPTColor redColor];
    firstPlot.dataLineStyle = lineStyle;
    firstPlot.dataSource    = self;

//    [graph addPlot:firstPlot];

    // Second derivative
    CPTScatterPlot *secondPlot = [[CPTScatterPlot alloc] init];
    secondPlot.identifier    = kSecond;
    lineStyle.lineColor      = [CPTColor redColor];
    secondPlot.dataLineStyle = lineStyle;
    secondPlot.dataSource    = self;
    
    [self gradientScatterPlot:firstPlot];

//    [graph addPlot:secondPlot];

    // Auto scale the plot space to fit the plot data
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

    // Expand the ranges to put some space around the plot
    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.025)];
    xRange.location = plotSpace.xRange.location;
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
    x.visibleAxisRange = xRange;
    y.visibleAxisRange = yRange;

    [xRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor lightGrayColor] colorWithAlphaComponent:0.75]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(8.0, 8.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;

    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * CPTFloat(2.0) );
}

- (void) gradientScatterPlot:(CPTScatterPlot *)plot
{
    CPTColor *beginningColor = [CPTColor colorWithComponentRed:0 green:0.5 blue:1.0 alpha:1];
    CPTColor *endingColor = [CPTColor colorWithComponentRed:0 green:0.5 blue:1.0 alpha:0];
    
    CPTGradient *areaGradient = [CPTGradient
                                 gradientWithBeginningColor:beginningColor
                                 endingColor:endingColor];
    // 上から下へグラデーション
    areaGradient.angle = -90.0;
    
    CPTFill* areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    plot.areaFill = areaGradientFill;
    plot.areaBaseValue = CPTDecimalFromString(@"0.0");
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:self.dataTitle] ) {
        numRecords = self.plotData.count;
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        numRecords = self.plotData1.count;
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        numRecords = self.plotData2.count;
    }

    return numRecords;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:self.dataTitle] ) {
        num = self.plotData[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        num = self.plotData1[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        num = self.plotData2[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;

    CPTMutablePlotRange *changedRange = [newRange mutableCopy];

    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:CPTDecimalFromDouble(1.025)];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;

        case CPTCoordinateY:
            [changedRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;

        default:
            break;
    }

    return newRange;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *graph = (self.graphs)[0];

    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor redColor];
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSDictionary *dataPoint = self.plotData[index];

    NSNumber *x = dataPoint[@"x"];
    NSNumber *y = dataPoint[@"y"];

    NSArray *anchorPoint = @[x, y];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    //CPTImage *background    = [CPTImage imageNamed:@"BlueBackground"];
    //background.edgeInsets   = CPTEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    //textLayer.fill          = [CPTFill fillWithImage:background];
    textLayer.paddingLeft   = 2.0;
    textLayer.paddingTop    = 2.0;
    textLayer.paddingRight  = 2.0;
    textLayer.paddingBottom = 2.0;

    annotation                    = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    annotation.contentLayer       = textLayer;
    annotation.contentAnchorPoint = CGPointMake(0.5, 0.0);
    annotation.displacement       = CGPointMake(0.0, 10.0);
    [graph.plotAreaFrame.plotArea addAnnotation:annotation];
}

-(void)scatterPlotDataLineWasSelected:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
}

-(void)scatterPlotDataLineTouchDown:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchDown: %@", plot);
}

-(void)scatterPlotDataLineTouchUp:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchUp: %@", plot);
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea
{
    // Remove the annotation
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        CPTXYGraph *graph = [self.graphs objectAtIndex:0];

        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
}

@end
