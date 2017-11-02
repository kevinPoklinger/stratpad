//
//  StratFileAgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "StratFileAgendaItem.h"


@implementation StratFileAgendaItem

@synthesize stratFile = stratFile_;

-(id)initWithStratFile:(StratFile*)stratFile agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate
{
    self = [super initWithAgendaItemType:agendaItemType startDate:startDate];
    if (self) {
        stratFile_ = [stratFile retain]; // retain cause we're bypassing setStratFile
    }
    return self;
}

-(NSString*)responsible
{
    return nil;
}

- (NSString*)responsibleString
{
    return nil;
}

-(NSString*)description
{
    switch (agendaItemType_) {
            
        case AgendaItemStrategyStart:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_STRATEGY_START", nil), [stratFile_ name], [startDate_ formattedDate1]];            

        case AgendaItemStrategyStop:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_THEME_STOP", nil), [stratFile_ name], [startDate_ formattedDate1]];
            
        case AgendaItemStrategyProgress:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_STRATEGY_PROGRESS", nil), [stratFile_ name]];
            
        case AgendaItemStrategyReview:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_STRATEGY_REVIEW", nil), [stratFile_ name]]; 
            
        default:
            return @"Unknown stratfile item.";
    }
}

-(void)dealloc
{
    [stratFile_ release];
    [super dealloc];
}

@end
