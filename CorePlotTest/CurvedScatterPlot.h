//
//  CurvedScatterPlot.h
//  Plot_Gallery_iOS
//
//  Created by Nino Ag on 23/10/11.

#import "PlotItem.h"

@interface CurvedScatterPlot : PlotItem<CPTPlotAreaDelegate,
                                        CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTScatterPlotDelegate>

+(void)loadGraph;
-(id)initWithDate:(NSDate *)date;

@property (nonatomic, readwrite, strong) NSDate *renderDate;
@property (nonatomic, readwrite, strong) NSArray *plotData;

@end
