//
//  ColorChooserViewController.m
//  StratPad
//
//  Created by Julian Wood on 12-04-02.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ColorChooserViewController.h"
#import "ColorChooserCell.h"
#import "DataManager.h"

@interface ColorChooserViewController (Private)

@end

@implementation ColorChooserViewController
@synthesize tblColors;

- (id)initWithChart:(Chart*)chart andColorChooser:(id<ColorChooser>)colorChooser
{
    self = [super initWithNibName:NSStringFromClass([ColorChooserViewController class]) bundle:nil];
    if (self) {
        chart_ = chart;
        colorChooser_ = colorChooser;
        self.title = LocalizedString(@"Color", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    NSAssert(chart_ != nil, @"You have to provide a valid chart object in the init.");
    NSAssert(colorChooser_ != nil, @"You have to provide a valid color chooser object in the init.");
    DLog(@"chart: %@", chart_);

    [super viewDidLoad];
    tblColors.clipsToBounds = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTblColors:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// @override: this will make it so that the popover doesn't expand to full height
-(CGSize)contentSizeForViewInPopover
{
    CGFloat rowHeight = [self tableView:tblColors heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger numRows = [self tableView:tblColors numberOfRowsInSection:0];
    return CGSizeMake(self.view.bounds.size.width, numRows*rowHeight + 40);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *oldSelection = [NSIndexPath indexPathForRow:chart_.colorScheme.intValue inSection:0];
    NSIndexPath *newSelection = indexPath;
    
    ColorScheme newColorScheme = [indexPath row];
    
    // deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // update the chart entity
    [chart_ setColorScheme:[NSNumber numberWithInt:newColorScheme]];
    [DataManager saveManagedInstances];
    
    // notify delegate so that the chart can be updated
    [colorChooser_ colorSelected];
    
    // update checkmarks
    [[tableView cellForRowAtIndexPath:oldSelection] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:newSelection] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Chart colorSchemeNames] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *CellIdentifier = @"ColorChooserCell";
    ColorChooserCell *cell = [tblColors dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    ColorScheme colorScheme = [indexPath row];
    if (chart_.colorScheme.intValue == colorScheme) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.colorView.gradientColorStart = [Chart colorForColorScheme:colorScheme gradientPosition:GradientPositionStart];
    cell.colorView.gradientColorEnd = [Chart colorForColorScheme:colorScheme gradientPosition:GradientPositionEnd];
    [cell.colorView setNeedsDisplay];
    
    NSString *colorSchemeTitle = [NSString stringWithFormat:@"COLOR_SCHEME_%i", colorScheme];
    cell.lblTitle.text = LocalizedString(colorSchemeTitle, nil);
    
    return cell; 
}

- (void)dealloc {
    [tblColors release];
    [super dealloc];
}
@end
