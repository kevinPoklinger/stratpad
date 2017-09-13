//
//  ImageToDataTransformer.m
//  BodyTracker
//
//  Created by Julian Wood on 11-06-01.
//  Copyright 2011 Mobilesce Inc. All rights reserved.
//

#import "ImageToDataTransformer.h"


@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation 
{
	return YES;
}

+ (Class)transformedValueClass 
{
	return [NSData class];
}

- (id)transformedValue:(id)value 
{
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}

- (id)reverseTransformedValue:(id)value 
{
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return [uiImage autorelease];
}

@end
