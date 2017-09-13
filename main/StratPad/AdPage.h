//
//  AdPage.h
//  StratPad
//
//  Created by Julian Wood on 12-01-04.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "HTMLPage.h"

@interface AdPage : HTMLPage

@property(nonatomic, copy) NSString *client;
@property(nonatomic, copy) NSString *url;

- (id)initWithDictionary:(NSDictionary*)dict;


@end
