//
//  SideBarViewController.h
//  StratPad
//
//  Created by Eric Rogers on July 26, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  This is a scollview, filled with a bunch of buttons.
//  Each button is grouped into one of 3 sections: i (reference), ii (forms) or iii (reports)
//  There is a special button for StratBoard, which is a special report, in its own section iv.
//  The scrollview has an image background, and then buttons with their own custom background are placed 
//  on top of that. Each button can swap in an "arrow" to indicate it is selected. The arrow goes beyond 
//  its bounds and that of its parent scrollview, for a nice effect.
//  We have a bigger background to swap in when StratBoard is enabled.

#import "Chapter.h"
#import "LMViewController.h"

@interface SideBarViewController : LMViewController {
 @private    
    NSInteger loadingChapterIndex_;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end

