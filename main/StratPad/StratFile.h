//
//  StratFile.h
//  StratPad
//
//  Created by Eric on 11-09-07.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//
// sharing questions:
// make stratfile.name a unique constraint?
// obey permissions in stratfile, given that we are not the owner anymore
// owner, group fields
// we need to know who the owner is :-)
// can you re-share documents?


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    UserTypeOwner = 100,
    UserTypeGroup = 10,
    UserTypeOther = 1
} UserType;

// used in calculations for number of pages in Reports - eg R2
// we will always cover 5 years in our reports, for example
// the same number as when we are calculating a strategy end date, but there is no end date on any theme
#define strategyDurationInYearsWhenNotDefined   5

@class Responsible, Theme, Chart, YammerPublishedReport, Financials;

@interface StratFile : NSManagedObject

// @since 1.6
@property (nonatomic, retain) NSString * uuid;

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSDate * dateLastAccessed;

@property (nonatomic, retain) NSString * customersDescription;
@property (nonatomic, retain) NSString * keyProblems;
@property (nonatomic, retain) NSString * addressProblems;
@property (nonatomic, retain) NSString * competitorsDescription;
@property (nonatomic, retain) NSString * businessModelDescription;
@property (nonatomic, retain) NSString * expansionOptionsDescription;
@property (nonatomic, retain) NSString * ultimateAspiration;

@property (nonatomic, retain) NSString * mediumTermStrategicGoal;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * provinceState;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * industry;

@property (nonatomic, retain) NSSet* themes;
@property (nonatomic, retain) NSSet* responsibles;
@property (nonatomic, retain) Financials *financials;


// octal string, currently used only for owner read and readwrite, eg 0400 and 0600
@property (nonatomic, retain) NSString * permissions;

// this matches the current core data model version for StratPad.xcdatamodeld when created or written
// for import or reading of old stratfiles, we can use it as a hint to update it to the current model
@property (nonatomic, retain) NSString * model;

// any reports which are published to Yammer are recorded here; not serialized/deserialized
@property (nonatomic, retain) NSSet *yammerReports;

@end


@interface StratFile (Convenience)

- (BOOL)isReadable:(UserType)userType;

- (BOOL)isWritable:(UserType)userType;

// returns all themes for the StratFile, sorted ascending by order.
- (NSMutableArray*)themesSortedByOrder;

// returns all themes for the StratFile, sorted ascending by start date.
- (NSArray*)themesSortedByStartDate;

// returns the date of the theme with the earliest start date, or the current date,
// if no themes have a start date, or nil if no themes exist.
- (NSDate*)dateOfEarliestThemeOrToday;

// synonym for -[dateOfEarliestThemeOrToday]
- (NSDate*)strategyStartDate;
- (NSDate*)strategyEndDate;

// figures out the number of months, and rounds that up to the nearest year
- (NSUInteger)strategyDurationInYears;

// the number of months
- (NSUInteger)strategyDurationInMonths;

// check if we've published the report representing the current chapter (and/or page) to Yammer
-(BOOL)isPublishedToYammer:(NSString*)chapterNumber pageNumber:(NSUInteger)pageNumber;

-(BOOL)isChapterPublishedToYammer:(NSString*)chapterNumber;
-(BOOL)isChartPublishedToYammer:(Chart*)chart;

@end


@interface StratFile (CoreData)

- (void)addThemesObject:(Theme *)value;
- (void)removeThemesObject:(Theme *)value;
- (void)addThemes:(NSSet *)value;
- (void)removeThemes:(NSSet *)value;

- (void)addResponsiblesObject:(Responsible *)value;
- (void)removeResponsiblesObject:(Responsible *)value;
- (void)addResponsibles:(NSSet *)value;
- (void)removeResponsibles:(NSSet *)value;

- (void)addYammerPublishedReportsObject:(YammerPublishedReport *)value;
- (void)removeYammerPublishedReportsObject:(YammerPublishedReport *)value;
- (void)addYammerPublishedReports:(NSSet *)values;
- (void)removeYammerPublishedReports:(NSSet *)values;

@end

