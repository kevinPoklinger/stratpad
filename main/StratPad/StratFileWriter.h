//
//  StratFileWriter.h
//  StratPad
//
//  Created by Julian Wood on 9/8/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLWriter.h"
#import "StratFile.h"

@interface StratFileWriter : XMLWriter {
    StratFile *stratFile_;
}

-(id)initWithStratFile:(StratFile*)stratFile;

// writes the stratfile into the XMLWriter, optionally omitting invalid data 
-(void)writeStratFile:(BOOL)filterInvalidData;

@end
