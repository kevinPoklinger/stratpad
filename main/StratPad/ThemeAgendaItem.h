//
//  ThemeAgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaItem.h"
#import "Theme.h"

@interface ThemeAgendaItem : AgendaItem {
    Theme *theme_;
}

@property (nonatomic,retain,readonly) Theme *theme;

-(id)initWithTheme:(Theme*)theme agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;

@end
