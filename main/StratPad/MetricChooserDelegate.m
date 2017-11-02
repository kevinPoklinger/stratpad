//
//  MetricChooserDelegate.m
//  StratPad
//
//  Created by Julian Wood on 12-04-20.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "MetricChooserDelegate.h"

#import "Metric.h"
#import "Objective.h"
#import "Theme.h"
#import "ThemeKey.h"

#pragma mark - MetricChooserDelegate

@interface MetricChooserDelegate ()

@end

@implementation MetricChooserDelegate

- (id)initWithMetrics:(NSArray*)metrics chosenMetric:(Metric*)chosenMetric andMetricChooser:(id<MetricChooser>)metricChooser
{
    self = [super init];
    if (self) {
        NSAssert(metrics != nil, @"You have to provide a valid metrics array in the init.");
        NSAssert(metricChooser != nil, @"You have to provide a valid MetricChooser object in the init.");
        
        metricChooser_ = metricChooser;
        chosenMetric_ = chosenMetric;
        
        // rearrange metrics into a dict
        metricsDict_ = [[NSMutableDictionary dictionary] retain];
        for (Metric *metric in metrics) {

            int metricFilters = [metricChooser metricFilters];
            if ((metricFilters & MetricFilterMeasurements) != 0) {
                if (!metric.measurements || metric.measurements.count == 0) {
                    continue;
                }
            }
            if ((metricFilters & MetricFilterSummary) != 0) {
                if (!metric.summary) {
                    continue;
                }
            }
            
            ThemeKey *themeKey = [[ThemeKey alloc] initWithTheme:metric.objective.theme];
            NSMutableArray *ary = [metricsDict_ objectForKey:themeKey];
            if (!ary) {
                ary = [NSMutableArray array];
            }
            [ary addObject:metric];
            [metricsDict_ setObject:ary forKey:themeKey];
            [themeKey release];
        }
        
    }
    return self;
}

- (void)dealloc
{
    [metricsDict_ release];
    [super dealloc];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // figure out the old selection
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    ThemeKey *themeKey = [[ThemeKey alloc] initWithTheme:chosenMetric_.objective.theme];
    NSUInteger sectionIdx = [themeKeys indexOfObject:themeKey];
    [themeKey release];
    
    NSUInteger rowIdx = NSNotFound;
    for (ThemeKey *themeKey in themeKeys) {
        NSArray *metrics = [metricsDict_ objectForKey:themeKey];
        rowIdx = [metrics indexOfObject:chosenMetric_];
        if (rowIdx != NSNotFound) {
            break;
        }
    }
    
    NSIndexPath *oldSelection = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
    NSIndexPath *newSelection = indexPath;
    
    // deselect the new row
    [tableView deselectRowAtIndexPath:newSelection animated:YES];
    
    // new chosen metric
    Theme *theme = [themeKeys objectAtIndex:[newSelection section]];
    NSArray *metrics = [metricsDict_ objectForKey:theme];
    chosenMetric_ = [metrics objectAtIndex:[newSelection row]];
    
    // notify delegate so that the chart can be updated
    [metricChooser_ metricSelected:chosenMetric_];
    
    // update checkmarks
    [[tableView cellForRowAtIndexPath:oldSelection] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:newSelection] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [metricsDict_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    ThemeKey *themeKey = [themeKeys objectAtIndex:section];
    NSArray *rows = [metricsDict_ objectForKey:themeKey];
    return [rows count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    ThemeKey *themeKey = [themeKeys objectAtIndex:section];
    return themeKey.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    static NSString *CellIdentifier = @"MetricCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    ThemeKey *themeKey = [themeKeys objectAtIndex:[indexPath section]];
    NSArray *metrics = [metricsDict_ objectForKey:themeKey];
    Metric *metric = [metrics objectAtIndex:[indexPath row]];
    
    if ([chosenMetric_ isEqual:metric]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = metric.summary;
    cell.detailTextLabel.text = metric.objective.summary;
    
    return cell;    
}

#pragma mark - Public

-(CGFloat)heightForAllRows:(UITableView*)tblMetrics
{
    CGFloat rowHeight = [self tableView:tblMetrics heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *themeKeys = [[metricsDict_ allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    int numRows = 0;
    for (ThemeKey *themeKey in themeKeys) {
        NSArray *rows = [metricsDict_ objectForKey:themeKey];
        numRows += [rows count];
    }
    
    CGFloat height = numRows*rowHeight + [themeKeys count] * 20;

    return height;    
}


@end
