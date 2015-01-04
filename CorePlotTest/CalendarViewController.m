//
//  CalendarViewController.m
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import "CalendarViewController.h"
#import "GraphViewController.h"

#import "CurvedScatterPlot.h"

@implementation InsideImagesTableViewCell


@end

@interface CalendarViewController ()
@property (nonatomic, strong)    NSMutableDictionary *eventsByDate;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
    [self createRandomEvents];
    
    self.insideImagesTableView.hidden = YES;
    self.insideImagesTableView.allowsSelection = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // Must be call in viewDidAppear
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}

- (IBAction)didShowGraph:(id)sender
{
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(self.eventsByDate[key] && [self.eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    NSArray *events = self.eventsByDate[key];
    
    NSLog(@"Date: %@ - %ld events", date, [events count]);
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 300;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
    }
    // crash code in the official example 
    /*
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                     }];
     */
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                              self.insideImagesTableView.hidden = !self.calendar.calendarAppearance.isWeekMode;
                                              [self.showInsideImagesButton setTitle:self.calendar.calendarAppearance.isWeekMode ? @"カレンダー全表示" : @"Box内画像を見る" forState:UIControlStateNormal];
                                              
                                          }];
                     }];
}

#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (void)createRandomEvents
{
    self.eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!self.eventsByDate[key]){
            self.eventsByDate[key] = [NSMutableArray new];
        }
             
        [self.eventsByDate[key] addObject:randomDate];
    }
}

-(NSInteger)numberOfSectionsInTableView:
(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InsideImagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InsideImagesTableViewCell" forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:@"intel_sp0821.png"];
    //UIImage *resizeImage = [self scaleImage:image imageView:cell.insideView];
    cell.insideView.image = image;
    cell.descriptionTextView.text =  @"撮影日時:2015-01-05 13:30:25 \nBox内温度: 35度";
    return cell;
}

- (UIImage *)scaleImage:(UIImage *)image imageView:(UIImageView *)imageView
{
    NSInteger imageWidth = image.size.width;
    NSInteger imageHeight = image.size.height;
    
    CGFloat scale = imageWidth / imageView.image.size.width;
    
    CGSize resizedSize = CGSizeMake(imageWidth * scale, imageHeight * scale);
    UIGraphicsBeginImageContext(resizedSize);
    [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"ShowGraph"] ) {
        GraphViewController *controller = (GraphViewController *)[segue destinationViewController];
        
        controller.navigationItem.leftBarButtonItem             = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        controller.currentThemeName = @"Plain White";
        
        [CurvedScatterPlot loadGraph];
        CurvedScatterPlot *curvedScater = [[CurvedScatterPlot alloc] initWithDate:self.calendar.currentDateSelected];
        ;
        controller.detailItem = curvedScater;
    }
}

@end
