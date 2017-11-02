//
//  ActivityAgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaItem.h"
#import "Activity.h"

@interface ActivityAgendaItem : AgendaItem {
    Activity *activity_;
}

@property (nonatomic,retain) Activity *activity;

-(id)initWithActivity:(Activity*)activity agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;

@end
