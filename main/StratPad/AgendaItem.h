//
//  AgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/19/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Base class for agenda items

#import <Foundation/Foundation.h>
#import "NSDate-StratPad.h"

typedef enum {
    AgendaItemStrategyStart,
    AgendaItemStrategyProgress,
    AgendaItemStrategyStop,
    AgendaItemStrategyReview,

    AgendaItemThemeStart,
    AgendaItemThemeStop,

    AgendaItemMetricProgress,

    AgendaItemActivityStart,
    AgendaItemActivityStop,
    
    AgendaItemFinancialPerformanceReview,
        
} AgendaItemType;

@interface AgendaItem : NSObject {
    AgendaItemType agendaItemType_;
    NSDate *startDate_;
}

@property (nonatomic,assign,readonly) AgendaItemType agendaItemType;
@property (nonatomic,retain,readonly) NSDate *startDate;

-(id)initWithAgendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;

@end

@interface AgendaItem (Protected)

// this is exactly what was in the text field - typically "firstname lastname"
-(NSString*)responsible;

// formatted version of responsible, used when we're only interested in a single responsible
-(NSString*)responsibleString;

@end
