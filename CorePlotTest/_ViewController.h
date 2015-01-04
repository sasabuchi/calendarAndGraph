//
//  ViewController.h
//  CorePlotTest
//
//  Created by 笹渕 弘輝 on 2014/12/13.
//  Copyright (c) 2014年 笹渕 弘輝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CPTImage.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"

@interface _ViewController : UIViewController<
CPTPlotAreaDelegate,
CPTPlotSpaceDelegate,
CPTPlotDataSource,
CPTScatterPlotDelegate>
@property(weak, nonatomic) IBOutlet CPTGraphHostingView * graphView;
@end
