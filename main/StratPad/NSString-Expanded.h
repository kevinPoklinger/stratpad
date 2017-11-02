//
//  NSString-Expanded.h
//  StratPad
//
//  Created by Julian Wood on 11-08-05.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Provides additional methods for NSString.

#import <Foundation/Foundation.h>


@interface NSString (Expanded)

- (BOOL)isBlank;
- (NSString *)stringByDecodingXMLEntities;
+ (NSString*) stringWithUUID;
- (NSString *) md5;

// when passing string to javascript, enclose it with double quotes and filter with this method
- (NSString*) stringByEscapingIllegalJavascriptCharacters;

@end
