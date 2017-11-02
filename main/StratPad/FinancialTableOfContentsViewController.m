//
//  FinancialTableOfContentsViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-12.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "FinancialTableOfContentsViewController.h"
#import "MBRoundedRectView.h"
#import "SkinManager.h"
#import "RootViewController.h"
#import "DataManager.h"
#import "UIColor-Expanded.h"


@interface FinancialTableOfContentsViewController ()

@property (retain, nonatomic) IBOutlet UITableView *tblContents;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (retain, nonatomic) IBOutlet MBRoundedRectView *viewRoundedRect;

@property (retain, nonatomic) Financials *financials;

@end

@implementation FinancialTableOfContentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    SkinManager *skinMan = [SkinManager sharedManager];

    _tblContents.backgroundColor = [UIColor clearColor];
    _tblContents.opaque = NO;
    _tblContents.backgroundView = nil;
    _tblContents.clipsToBounds = YES;
    
    // because we are making the background transparent, and because we have a grouped table, and because we have padding around the cells, compensate by adjusting the frame
    //CGRect f = _tblContents.frame;
    //_tblContents.frame = CGRectMake(f.origin.x-10, f.origin.y-10, f.size.width+20, f.size.height+20);

 
    
    _viewRoundedRect.roundedRectBackgroundColor = [skinMan colorForProperty:kSkinSection2FormBackgroundColor];
    
    _lblTitle.font = [skinMan fontWithName:kSkinSection2TitleFontName andSize:kSkinSection2TitleFontSize];
    _lblTitle.textColor = [skinMan colorForProperty:kSkinSection2TitleFontColor];
    
    _lblSubtitle.font = [skinMan fontWithName:kSkinSection2SubtitleFontName andSize:kSkinSection2SubtitleFontSize];
    _lblSubtitle.textColor = [skinMan colorForProperty:kSkinSection2SubtitleFontColor];
    
    for (UIView *subview in _viewRoundedRect.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setTextColor:[skinMan colorForProperty:kSkinSection2FieldLabelFontColor]];
        }
    }

    self.financials = [stratFileManager_ currentStratFile].financials;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // so that we don't get a flash on the table when page flipping
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PageViewController *pageVC = rootViewController.pageViewController;
    [pageVC setDelaysContentTouches:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // restore default
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PageViewController *pageVC = rootViewController.pageViewController;
    [pageVC setDelaysContentTouches:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tblContents release];
    [_lblTitle release];
    [_lblSubtitle release];
    [_viewRoundedRect release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTblContents:nil];
    [self setLblTitle:nil];
    [self setLblSubtitle:nil];
    [self setViewRoundedRect:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RootViewController *rootViewController = (RootViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController jumpToFinancialsPage:indexPath.row + 1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = CGRectGetHeight(_tblContents.frame)-10;
    return floorf(h/10);
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // don't list TOC
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        SkinManager *skinMan = [SkinManager sharedManager];
        cell.textLabel.textColor = [skinMan colorForProperty:kSkinSection2FieldLabelFontColor];
        cell.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
    }
    
    // skip the TOC
    NSString *key = [NSString stringWithFormat:@"FINANCES_%i", indexPath.row+1];
    //cell.textLabel.text = [NSString stringWithFormat:@"%i. %@", indexPath.row+1, LocalizedString(key, nil)];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i. %@", indexPath.row+1, LocalizedString(key, nil)]];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    [cell.textLabel setAttributedText:attributeString];
    
    return cell;

}


@end
