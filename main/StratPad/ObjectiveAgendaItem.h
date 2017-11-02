//
//  ObjectiveAgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaItem.h"
#import "Objective.h"

@interface ObjectiveAgendaItem : AgendaItem {
    Objective *objective_;
}

@property (nonatomic,retain,readonly) Objective *objective;

-(id)initWithObjective:(Objective*)objective agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;

@end
