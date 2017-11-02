//
//  MetricList.m
//  StratPad
//
//  Created by Julian Wood on 12-04-24.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MetricList.h"
#import "Objective.h"
#import "Metric.h"
#import "ThemeKey.h"

@implementation MetricList

- (NSIndexPath*)indexPathForChart:(Chart*)chart
{
    int section=0;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    for (ThemeKey *themeKey in themeKeys) {
        int row = 0;
        NSArray *metrics = [metricsDict_ objectForKey:themeKey];
        for (Metric *metric in metrics) {
            if ([chart.metric isEqual:metric]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
            row++;
        }
        section++;
    }
    
    ELog(@"Couldn't find metric row representing chart (should not be possible): %@", chart);
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *CellIdentifier = @"MetricCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    // any metric with some measurements gets a check mark
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    ThemeKey *themeKey = [themeKeys objectAtIndex:[indexPath section]];
    NSArray *metrics = [metricsDict_ objectForKey:themeKey];
    Metric *metric = [metrics objectAtIndex:[indexPath row]];
    
    if (metric.measurements && metric.measurements.count) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = metric.summary;
    cell.detailTextLabel.text = metric.objective.summary;
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([metricsDict_ count] == 0) {
        return;
    }
    
    // figure out the chosen metric
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];    
    Theme *theme = [themeKeys objectAtIndex:[indexPath section]];
    NSArray *metrics = [metricsDict_ objectForKey:theme];
    chosenMetric_ = [metrics objectAtIndex:[indexPath row]];
    
    // notify delegate so that the detail can be updated
    [metricChooser_ metricSelected:chosenMetric_];
}


@end
