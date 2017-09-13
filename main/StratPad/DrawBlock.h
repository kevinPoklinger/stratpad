//
//  PrintBlock.h
//  StratPad
//
//  Created by Julian Wood on 9/22/11.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DrawBlock : NSObject {
}

@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat yOffset;
@property (nonatomic,copy) void (^drawCommand)();


-(id)initWithHeight:(CGFloat)height yOffset:(CGFloat)yOffset drawCommand:(void (^)())drawCommand;
-(void)draw;

@end
