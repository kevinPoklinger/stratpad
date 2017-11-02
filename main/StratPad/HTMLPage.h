//
//  HTMLPage.h
//  StratPad
//
//  Created by Eric on 11-07-28.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "Page.h"

@interface HTMLPage : Page

@property(nonatomic, copy) NSString *filename;

- (id)initWithDictionary:(NSDictionary*)dict;

@end
