//
//  CustomAgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaItem.h"

@interface CustomAgendaItem : AgendaItem {
    NSString *description_;
}

-(id)initWithDescription:(NSString*)description agendaItemType:(AgendaItemType)agendaItemType;

@property (nonatomic,retain,readonly) NSString *description;

@end
