//
//  PrintBlock.m
//  StratPad
//
//  Created by Julian Wood on 9/22/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "DrawBlock.h"


@implementation DrawBlock

@synthesize height, yOffset, drawCommand;

-(id)initWithHeight:(CGFloat)h yOffset:(CGFloat)yOff drawCommand:( void (^)() )drawCmd 
{
    self = [super init];
    if (self) {
        self.height = h;
        self.yOffset = yOff;
        self.drawCommand = drawCmd;
        
        [self draw];
    }
    return self;
}

-(void)draw
{
    void (^drawFunc)() = self.drawCommand;
    drawFunc();    
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"height: %f, yOffset: %f, drawCommand: %@", self.height, self.yOffset, self.drawCommand]; 
}

@end
