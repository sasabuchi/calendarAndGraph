//
//  GraphViewController.m
//  CorePlotTest
//
//  Created by 笹渕 弘輝 on 2014/12/20.
//  Copyright (c) 2014年 笹渕 弘輝. All rights reserved.
//

#import "GraphViewController.h"

#import "PlotItem.h"

NSString *const kThemeTableViewControllerNoTheme      = @"None";
NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

NSString *const PlotGalleryThemeDidChangeNotification = @"PlotGalleryThemeDidChangeNotification";
NSString *const PlotGalleryThemeNameKey               = @"PlotGalleryThemeNameKey";

@interface GraphViewController ()

@property (nonatomic, readwrite, weak) UIPopoverController *themePopoverController;

-(CPTTheme *)currentTheme;

-(void)setupView;
-(void)themeChanged:(NSNotification *)notification;

@end

@implementation GraphViewController

#pragma mark -
#pragma mark Initialization and Memory Management

-(void)setupView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:PlotGalleryThemeDidChangeNotification
                                               object:nil];
    
    [self showTemperatureGraph:nil];
}

-(void)awakeFromNib
{
    [self setupView];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        [self setupView];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Managing the detail item

-(void)setDetailItem:(PlotItem *)newDetailItem
{
    if (_detailItem != newDetailItem ) {
        [_detailItem killGraph];
        
        _detailItem = newDetailItem;
        [_detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
    }
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupView];
}

#pragma mark -
#pragma mark Theme Selection

-(void)setCurrentThemeName:(NSString *)newThemeName
{
    if ( newThemeName != _currentThemeName ) {
        _currentThemeName = [newThemeName copy];
        
        self.themeBarButton.title = [NSString stringWithFormat:@"Theme: %@", newThemeName];
    }
}

-(CPTTheme *)currentTheme
{
    CPTTheme *theme;
    
    if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerNoTheme] ) {
        theme = (id)[NSNull null];
    }
    else if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerDefaultTheme] ) {
        theme = nil;
    }
    else {
        theme = [CPTTheme themeNamed:self.currentThemeName];
    }
    
    return theme;
}

-(void)themeSelectedWithName:(NSString *)themeName
{
    self.currentThemeName = themeName;
    
    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}

-(void)themeChanged:(NSNotification *)notification
{
    NSDictionary *themeInfo = notification.userInfo;
    
    [self themeSelectedWithName:themeInfo[PlotGalleryThemeNameKey]];
}

- (IBAction)closeeGraph:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showTemperatureGraph:(id)sender
{
    self.currentThemeName = @"Slate";
    self.detailItem.xAxisTitle = @"Time";
    self.detailItem.yAxisTitle = @"°C";
    self.detailItem.title =  @"Box内温度";
    self.detailItem.dataTitle = @"Box Temperature";
    [self.detailItem formatAllGraphs];
    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}

- (IBAction)showTiltGraph:(id)sender
{
    self.currentThemeName = @"Dark Gradients";
    self.detailItem.title = @"傾き具合";
    self.detailItem.xAxisTitle = @"Time";
    self.detailItem.yAxisTitle = @"傾き";
    self.detailItem.dataTitle = @"tilt";
    [self.detailItem formatAllGraphs];
    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}


#pragma mark -
#pragma mark Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"selectTheme"] ) {
        self.themePopoverController = segue.destinationViewController;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ( [identifier isEqualToString:@"selectTheme"] ) {
        UIPopoverController *controller = self.themePopoverController;
        
        if ( controller ) {
            [controller dismissPopoverAnimated:YES];
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return YES;
}


@end
