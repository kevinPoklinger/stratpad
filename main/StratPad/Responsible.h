//
//  Responsible.h
//  StratPad
//
//  Created by Eric on 11-09-07.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, StratFile, Theme;

@interface Responsible : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * summary;

// inverse relationships
@property (nonatomic, retain) StratFile * stratFile;
@property (nonatomic, retain) NSSet* activities;
@property (nonatomic, retain) NSSet* themes;

+ (Responsible*)responsibleWithSummary:(NSString*)summary forStratFile:(StratFile*)stratFile;

@end
