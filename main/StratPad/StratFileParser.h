//
//  StratFileParser.h
//  StratPad
//
//  Created by Julian Wood on 9/9/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StratFile.h"
#import "TBXML.h"

@interface StratFileParser : NSObject {
    StratFile *stratFile_;
    NSData *xmlData_;
}

// if the email tag in the xml does not match what we have stored in userdefaults, fail this import; default is false
@property (nonatomic, assign) BOOL failWithMismatchedEmails;

- (id)initWithStratFile:(StratFile*)stratFile xmlData:(NSData*)xmlData;
- (void)parse;

@end
