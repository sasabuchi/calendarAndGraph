//
//  CalendarViewController.h
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@interface InsideImagesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *insideView;

@end


@interface CalendarViewController : UIViewController <JTCalendarDataSource, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@property (strong, nonatomic) JTCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView *insideImagesTableView;
@property (weak, nonatomic) IBOutlet UIButton *showInsideImagesButton;

@end
