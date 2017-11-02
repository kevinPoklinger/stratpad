//
//  Page.h
//  StratPad
//
//  Created by Eric on 11-07-28.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

@interface Page : NSObject

@property(nonatomic, copy) NSString *viewControllerClass;

- (id)initWithDictionary:(NSDictionary*)dict;

@end
