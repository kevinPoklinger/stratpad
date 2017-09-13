//
//  StratFileAgendaItem.h
//  StratPad
//
//  Created by Julian Wood on 9/21/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaItem.h"
#import "StratFile.h"

@interface StratFileAgendaItem : AgendaItem {
    StratFile *stratFile_;
}

@property (nonatomic,retain) StratFile *stratFile;

-(id)initWithStratFile:(StratFile*)stratFile agendaItemType:(AgendaItemType)agendaItemType startDate:(NSDate*)startDate;

@end
