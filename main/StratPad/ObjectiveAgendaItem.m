//
//  ObjectiveAgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ObjectiveAgendaItem.h"
#import "NSString-Expanded.h"
#import "NSDate-StratPad.h"
#import "Metric.h"
#import "Theme.h"
#import "Responsible.h"

@implementation ObjectiveAgendaItem

@synthesize objective = objective_;

-(id)initWithObjective:(Objective*)objective agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;
{
    self = [super initWithAgendaItemType:agendaItemType startDate:startDate];
    if (self) {
        objective_ = [objective retain]; // retain cause we're bypassing setObjective
    }
    return self;
}

-(NSString*)responsible
{
    // useful for meetings with metrics only, to include the person in charge of the theme
    return objective_.theme.responsible.summary;
}

- (NSString*)responsibleString
{
    return nil;
}

-(NSString*)description
{
    if (agendaItemType_ == AgendaItemMetricProgress) {
        if (objective_.metrics.count == 1) {
            
            Metric *metric = [objective_.metrics anyObject];
            
            BOOL hasTarget = metric.targetValue != nil && ![metric.targetValue isBlank];
            BOOL hasTargetDate = metric.targetDate != nil;

            if (hasTarget && hasTargetDate) {
                return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_OBJECTIVE_HAS_TARGET_AND_DATE", nil), metric.summary, metric.targetValue, [metric.targetDate formattedDate1]];
                
            } else if (hasTarget) {
                return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_OBJECTIVE_HAS_TARGET", nil), metric.summary, metric.targetValue];
                
            } else if (hasTargetDate) {
                return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_OBJECTIVE_HAS_DATE", nil), metric.summary, [metric.targetDate formattedDate1]];
                
            } else {
                return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_OBJECTIVE", nil), metric.summary];                        
            }

        } else if (objective_.metrics.count > 1) {
            
            return LocalizedString(@"AGENDA_ITEM_OBJECTIVE_MULTIPLE_METRICS", nil);            
            
        }
        
        // otherwise just use super
    }
    
    return [super description];
}

-(void)dealloc
{
    [objective_ release];
    [super dealloc];
}


@end
