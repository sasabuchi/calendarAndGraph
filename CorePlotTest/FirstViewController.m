//
//  FirstViewController.m
//  CorePlotTest
//
//  Created by 笹渕 弘輝 on 2014/12/21.
//  Copyright (c) 2014年 笹渕 弘輝. All rights reserved.
//

#import "FirstViewController.h"

#import "GraphViewController.h"

#import "PlotItem.h"
#import "CurvedScatterPlot.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"ShowGraph"] ) {
        GraphViewController *controller = (GraphViewController *)[segue destinationViewController];
        
        controller.navigationItem.leftBarButtonItem             = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        controller.currentThemeName = @"Plain White";
        
        [CurvedScatterPlot loadGraph];
        CurvedScatterPlot *curvedScater = [[CurvedScatterPlot alloc] init];
        controller.detailItem = curvedScater;
    }
}

- (IBAction)tapSender:(id)senderr
{
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
}

@end
