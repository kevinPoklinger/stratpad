//
//  ActivityAgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ActivityAgendaItem.h"
#import "Responsible.h"

@implementation ActivityAgendaItem

@synthesize activity = activity_;

-(id)initWithActivity:(Activity*)activity agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate
{
    self = [super initWithAgendaItemType:agendaItemType startDate:startDate];
    if (self) {
        activity_ = [activity retain]; // retain cause we're bypassing setActivity
    }
    return self;
}

-(NSString*)responsible
{
    return activity_.responsible.summary;
}

- (NSString*)responsibleString
{
    NSString *person = [self responsible];
    if (person) {
        return [NSString stringWithFormat:@" (%@) ", person];
    }
    return @" ";
}

-(NSString*)description
{
    switch (agendaItemType_) {
            
        case AgendaItemActivityStart:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_ACTIVITY_START", nil), [activity_ action], [self responsibleString], [startDate_ formattedDate1]];
            
        case AgendaItemActivityStop:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_ACTIVITY_STOP", nil), [activity_ action], [self responsibleString], [startDate_ formattedDate1]];
            
        default:
            return [super description];
            
    }
}

-(void)dealloc
{
    [activity_ release];
    [super dealloc];
}


@end
