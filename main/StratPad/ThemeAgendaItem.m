//
//  ThemeAgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "ThemeAgendaItem.h"
#import "Responsible.h"

@implementation ThemeAgendaItem

@synthesize theme = theme_;

-(id)initWithTheme:(Theme*)theme agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate
{
    self = [super initWithAgendaItemType:agendaItemType startDate:startDate];
    if (self) {
        theme_ = [theme retain]; // retain cause we're bypassing setTheme
    }
    return self;
}

-(NSString*)responsible
{
    return theme_.responsible.summary;
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
            
        case AgendaItemThemeStart:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_THEME_START", nil), [theme_ title], [self responsibleString], [startDate_ formattedDate1]];
            
        case AgendaItemThemeStop:
            return [NSString stringWithFormat:LocalizedString(@"AGENDA_ITEM_THEME_CONCLUDE", nil), [theme_ title], [startDate_ formattedDate1]];
            
        default:
            return [super description];
            
    }
}

-(void)dealloc
{
    [theme_ release];
    [super dealloc];
}

@end
