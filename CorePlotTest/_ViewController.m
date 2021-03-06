//
//  ViewController.m
//  CorePlotTest
//
//  Created by 笹渕 弘輝 on 2014/12/13.
//  Copyright (c) 2014年 笹渕 弘輝. All rights reserved.
//

#import "_ViewController.h"

static NSString *const X_TITLE = @"Time";
static NSString *const Y_TITLE = @"°C";
static NSString *const kData   = @"Box Temperature";
static NSString *const kFirst  = @"First Derivative";
static NSString *const kSecond = @"Second Derivative";

@interface _ViewController ()

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;


@property (nonatomic, readwrite, strong) CPTGraphHostingView *defaultLayerHostingView;

@property (nonatomic, readwrite, strong) NSArray *plotData;
@property (nonatomic, readwrite, strong) NSArray *plotData1;
@property (nonatomic, readwrite, strong) NSArray *plotData2;

//
@property (nonatomic, readwrite, strong) NSMutableArray *graphs;
@property (nonatomic, readwrite, strong) NSString *section;
@property (nonatomic, readwrite, strong) NSString *title;

@property (nonatomic, readonly) CGFloat titleSize;

@end

@implementation _ViewController

- (void) awakeFromNib {
    _defaultLayerHostingView = nil;
    _graphs = [@[] mutableCopy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphView.layer.borderWidth = 2.0f;
    self.graphView.layer.borderColor = [[UIColor orangeColor] CGColor];
    self.graphView.layer.cornerRadius = 10.0f;
    
    [self generateData];
    [self renderInGraphHostingView:self.graphView withTheme:nil animated:YES];
    
    [self formatAllGraphs];
    
    self.defaultLayerHostingView = self.graphView;
}

- (void)generateData
{
    if ( self.plotData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        
        for ( NSUInteger i = 0; i < 11; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * arc4random() / (double)UINT32_MAX + 0.5);
            [contentArray addObject:@{ @"x": x, @"y": y }
             ];
        }
        
        self.plotData = contentArray;
    }
    
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
        
        self.plotData1 = contentArray;
    }
    
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
    }
}

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)hostingView
{
    [self.graphs addObject:graph];
    
    if ( hostingView ) {
        hostingView.hostedGraph = graph;
    }
}

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
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
    // ---Graph Theme----
    //[self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
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
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = CPTDecimalFromDouble(0.1);
    x.minorTicksPerInterval = 4;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];
    
    lineCap.lineStyle = x.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    x.axisLineCapMax  = lineCap;
    
    x.title       = X_TITLE;
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
    
    lineCap.lineStyle = y.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    y.axisLineCapMax  = lineCap;
    y.axisLineCapMin  = lineCap;
    
    y.title       = Y_TITLE;
    y.titleOffset = self.titleSize * CPTFloat(1.25);
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = kData;
    
    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor colorWithCGColor:[UIColor redColor].CGColor];
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
    lineStyle.lineColor      = [CPTColor blueColor];
    secondPlot.dataLineStyle = lineStyle;
    secondPlot.dataSource    = self;
    
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
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;
    
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;
    
    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * CPTFloat(2.0) );
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:kData] ) {
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
    
    if ( [identifier isEqualToString:kData] ) {
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
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
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

-(void)formatAllGraphs
{
    CGFloat graphTitleSize = self.titleSize;
    
    for ( CPTGraph *graph in self.graphs ) {
        // Title
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color    = [CPTColor grayColor];
        textStyle.fontName = @"Helvetica-Bold";
        textStyle.fontSize = graphTitleSize;
        
        graph.title                    = (self.graphs.count == 1 ? self.title : nil);
        graph.titleTextStyle           = textStyle;
        graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        
        // Padding
        CGFloat boundsPadding = graphTitleSize;
        graph.paddingLeft = boundsPadding;
        
        if ( graph.title.length > 0 ) {
            graph.paddingTop = MAX(graph.titleTextStyle.fontSize * CPTFloat(2.0), boundsPadding);
        }
        else {
            graph.paddingTop = boundsPadding;
        }
        
        graph.paddingRight  = boundsPadding;
        graph.paddingBottom = boundsPadding;
        
        // Axis labels
        CGFloat axisTitleSize = graphTitleSize * CPTFloat(0.75);
        CGFloat labelSize     = graphTitleSize * CPTFloat(0.5);
        
        for ( CPTAxis *axis in graph.axisSet.axes ) {
            // Axis title
            textStyle          = [axis.titleTextStyle mutableCopy];
            textStyle.fontSize = axisTitleSize;
            
            axis.titleTextStyle = textStyle;
            
            // Axis labels
            textStyle          = [axis.labelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;
            
            axis.labelTextStyle = textStyle;
            
            textStyle          = [axis.minorTickLabelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;
            
            axis.minorTickLabelTextStyle = textStyle;
        }
        
        // Plot labels
        for ( CPTPlot *plot in graph.allPlots ) {
            textStyle          = [plot.labelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;
            
            plot.labelTextStyle = textStyle;
        }
        
        // Legend
        CPTLegend *theLegend = graph.legend;
        textStyle          = [theLegend.textStyle mutableCopy];
        textStyle.fontSize = labelSize;
        
        theLegend.textStyle  = textStyle;
        theLegend.swatchSize = CGSizeMake( labelSize * CPTFloat(1.5), labelSize * CPTFloat(1.5) );
        
        theLegend.rowMargin    = labelSize * CPTFloat(0.75);
        theLegend.columnMargin = labelSize * CPTFloat(0.75);
        
        theLegend.paddingLeft   = labelSize * CPTFloat(0.375);
        theLegend.paddingTop    = labelSize * CPTFloat(0.375);
        theLegend.paddingRight  = labelSize * CPTFloat(0.375);
        theLegend.paddingBottom = labelSize * CPTFloat(0.375);
    }
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
