//
//  Bindable.h
//  StratPad
//
//  Created by Eric Rogers on August 23, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  Protocol that a control should use to bind itself to a specific
//  entity and property.


@protocol Bindable <NSObject>

-(id) boundEntity;
-(NSString*) boundProperty;

- (void)setBindingWithEntity:(id)entity andProperty:(NSString*)property;

@end
