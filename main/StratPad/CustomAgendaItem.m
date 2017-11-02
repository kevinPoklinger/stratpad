//
//  CustomAgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "CustomAgendaItem.h"


@implementation CustomAgendaItem

@synthesize description = description_;

-(id)initWithDescription:(NSString*)description agendaItemType:(AgendaItemType)agendaItemType
{
    self = [super initWithAgendaItemType:agendaItemType startDate:nil];
    if (self) {
        description_ = [description retain]; // retain cause we're bypassing setDescription
    }
    return self;
}

- (void)dealloc
{
    [description_ release];
    [super dealloc];
}

@end
