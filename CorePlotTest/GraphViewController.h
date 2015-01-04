//
//  GraphViewController.h
//  CorePlotTest
//
//  Created by 笹渕 弘輝 on 2014/12/20.
//  Copyright (c) 2014年 笹渕 弘輝. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlotItem;

@interface GraphViewController : UIViewController

@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, copy) NSString *currentThemeName;

@property (nonatomic, strong) IBOutlet UIView *hostingView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeBarButton;

-(void)themeSelectedWithName:(NSString *)themeName;

@end
