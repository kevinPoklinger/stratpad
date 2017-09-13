//
//  AgendaItem.m
//  StratPad
//
//  Created by Julian Wood on 9/19/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "AgendaItem.h"
#import "StratFile.h"
#import "Theme.h"
#import "Objective.h"
#import "Activity.h"

@implementation AgendaItem

@synthesize agendaItemType = agendaItemType_;
@synthesize startDate = startDate_;

-(id)initWithAgendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate
{
    self = [super init];
    if (self) {
        agendaItemType_ = agendaItemType;
        startDate_ = [startDate retain]; // because we're bypassing setStartDate
    }
    return self;
}

-(void)dealloc
{
    [startDate_ release];
    [super dealloc];
}

// override
-(NSString*)responsible
{
    return nil;
}

// override
-(NSString*)responsibleString
{
    return nil;
}

// override
-(NSString*)description
{
   return [NSString stringWithFormat:@"Unknown item: %i class: %@", agendaItemType_, NSStringFromClass([self class])];
}

@end
