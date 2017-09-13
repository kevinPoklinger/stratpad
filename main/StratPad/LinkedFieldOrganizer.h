//
//  LinkedFieldOrganizer.h
//  StratPad
//
//  Created by Julian Wood on 2013-05-29.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkedFieldOrganizer : NSObject

// when the popover is up, we can still interact with these views
@property (nonatomic,retain) NSArray *linkedFields;

-(void)resignRespondersExcept:(UIResponder*)responder;

@end
