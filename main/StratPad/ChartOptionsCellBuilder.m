//
//  ChartOptionsCellBuilder.m
//  StratPad
//
//  Created by Julian Wood on 12-04-03.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ChartOptionsCellBuilder.h"
#import "Measurement.h"
#import "DataManager.h"

@implementation ChartOptionsCellBuilder

- (id)initWithChart:(Chart*)chart andTableView:(UITableView*)tableView
{
    self = [super init];
    if (self) {
        tblOptions_ = tableView;
        chart_ = [chart retain];
    }
    return self;
}

- (void)dealloc
{
    [chart_ release];
    [super dealloc];
}

- (ChartOptionsCell*)cellForTitle
{
    static NSString *cellIdentifier = @"OptionsCell";
    ChartOptionsCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[ChartOptionsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.textLabel.text = LocalizedString(@"CHART_TITLE", nil);
    cell.detailTextLabel.text = chart_.title ? chart_.title : LocalizedString(@"CHART_NO_TITLE", nil);
    
    return cell;
}

- (ChartOptionsCell*)cellForMetric
{
    static NSString *cellIdentifier = @"OptionsCell";
    ChartOptionsCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[ChartOptionsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = LocalizedString(@"METRIC", nil);
    cell.detailTextLabel.text = chart_.metric.summary ? chart_.metric.summary : LocalizedString(@"CHART_TYPE_0", nil);
    
    return cell;
}

- (ChartOptionsCell*)cellForChartType
{
    static NSString *cellIdentifier = @"OptionsCell";
    ChartOptionsCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[ChartOptionsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = LocalizedString(@"CHART_TYPE", nil);
    NSString *key = [NSString stringWithFormat:@"CHART_TYPE_%i", chart_.chartType.intValue];
    cell.detailTextLabel.text = LocalizedString(key, nil);
    
    return cell;
}

- (ChartOptionsCell*)cellForChartMaxValue
{
    static NSString *cellIdentifier = @"OptionsCell";
    ChartOptionsCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[ChartOptionsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = LocalizedString(@"CHART_MAX_VALUE", nil);
    
    // if no stored value, use calculated value
    NSNumber *yMax = [chart_ yAxisMaxFromChartOrMeasurement];
    cell.detailTextLabel.text = yMax.stringValue;
    
    return cell;
}


- (ColorCell*)cellForColor
{
    static NSString *colorCellIdentifier = @"ColorCell";
    ColorCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:colorCellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:colorCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.colorView.gradientColorStart = [chart_ colorForGradientStart];
    cell.colorView.gradientColorEnd = [chart_ colorForGradientEnd];
    [cell.colorView setNeedsDisplay];
    
    cell.lblColor.text = LocalizedString(@"COLOR", nil);
    NSString *key = [NSString stringWithFormat:@"COLOR_SCHEME_%i", chart_.colorScheme.intValue];
    cell.lblColorScheme.text = LocalizedString(key, nil);
    
    return cell;    
}

- (UITableViewCell*)cellForOverlay
{
    // if overlay present we show the color, by using a different cell
    static NSString *overlayCellIdentifier = @"OverlayCell";
    static NSString *colorCellIdentifier = @"ColorCell";
    
    UITableViewCell *cell = nil;
    if (chart_.shouldDrawOverlay) {
        Chart *chartOverlay = [Chart chartWithUUID:chart_.overlay];
        if (chartOverlay.colorScheme) {
            cell = [tblOptions_ dequeueReusableCellWithIdentifier:colorCellIdentifier];
            if (cell == nil) {
                // not localized
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:colorCellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
        }
    }
    
    if (cell == nil) {
        cell = [tblOptions_ dequeueReusableCellWithIdentifier:overlayCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:overlayCellIdentifier] autorelease];        
        }        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // figure out the title for the cell
    NSString *overlayTitle;
    if (chart_.shouldDrawOverlay) {
        Chart *chartOverlay = [Chart chartWithUUID:chart_.overlay];
        if (chartOverlay.chartType.intValue == ChartTypeComments) {
            overlayTitle = LocalizedString(@"CHART_TYPE_4", nil);
        }
        else if (chartOverlay.chartType.intValue > 0 && chartOverlay.metric) {
            overlayTitle = chartOverlay.metric.summary ? chartOverlay.metric.summary : @"N/A";
        } 
        else if (chartOverlay.chartType.intValue > 0) {
            overlayTitle = LocalizedString(@"CHOOSE_METRIC", nil);
        }
        else if (chartOverlay.metric.summary) {
            overlayTitle = LocalizedString(@"CHOOSE_CHART_TYPE", nil);
        }
        else {
            overlayTitle = LocalizedString(@"NO_OVERLAY", nil);
        }
    } else {
        overlayTitle = LocalizedString(@"NO_OVERLAY", nil);
    }
    
    if ([cell isKindOfClass:[ColorCell class]]) {
        Chart *chartOverlay = [Chart chartWithUUID:chart_.overlay];
        ((ColorCell*)cell).lblColor.text = LocalizedString(@"OVERLAY_OPTIONS_TITLE", nil);
        ((ColorCell*)cell).lblColorScheme.text = overlayTitle;
        ((ColorCell*)cell).colorView.gradientColorStart = [chartOverlay colorForGradientStart];
        ((ColorCell*)cell).colorView.gradientColorEnd = [chartOverlay colorForGradientEnd];
        [((ColorCell*)cell).colorView setNeedsDisplay];
        
    } else {
        cell.textLabel.text = LocalizedString(@"OVERLAY_OPTIONS_TITLE", nil);
        cell.detailTextLabel.text = overlayTitle;        
    }
    
    return cell;
    
}


- (BooleanTableViewCell*)booleanCellWithTitle:(NSString*)title
                                      binding:(NSString*)binding
                                       onText:(NSString*)onText
                                      offText:(NSString*)offText
                                       target:(id)target
                                       action:(SEL)action
{    
    BooleanTableViewCell *cell = [tblOptions_ dequeueReusableCellWithIdentifier:@"BooleanTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BooleanTableViewCell class]) owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lblName.font = [UIFont boldSystemFontOfSize:18];
    
    cell.switchOption.onText = onText;
    cell.switchOption.offText = offText;
    cell.switchOption.binding = binding;
    [cell.switchOption sizeToFit];
    [cell.switchOption addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    // set the row title from our dict of localized names
	[[cell lblName] setText:title];
    
    // set the switch value from settings
    BOOL on = [[chart_ valueForKey:binding] boolValue];
    [[cell switchOption] setOn:on];
    
    return cell;
}

@end
