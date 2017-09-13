//
//  ThemeKey.m
//  StratPad
//
//  Created by Julian Wood on 12-05-15.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "ThemeKey.h"
#import "Responsible.h"

@implementation ThemeKey

@synthesize title=title_;
@synthesize order=order_;
@synthesize startDate=startDate_;
@synthesize endDate=endDate_;
@synthesize responsible=responsible_;

- (id)initWithTheme:(Theme*)theme
{
    self = [super init];
    if (self) {
        self.title = theme.title;
        self.order = theme.order;
        self.startDate = theme.startDate;
        self.endDate = theme.endDate;
        self.responsible = theme.responsible.summary;
    }
    return self;
}

- (void)dealloc
{
    [title_ release];
    [order_ release];
    [startDate_ release];
    [endDate_ release];
    [responsible_ release];
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"[title: %@, order: %@]", self.title, self.order];
}

- (id)copyWithZone:(NSZone *)zone
{
    ThemeKey *copy = [[[self class] allocWithZone: zone] init];
    [copy setTitle:[self title]];
    [copy setOrder:[self order]];
    [copy setStartDate:[self startDate]];
    [copy setEndDate:[self endDate]];
    [copy setResponsible:[self responsible]];
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToThemeKey:object];
}

- (BOOL)isEqualToThemeKey:(ThemeKey *)themeKey 
{
    if (self == themeKey)
        return YES;
    if (![title_ isEqualToString:[themeKey title]])
        return NO;
    if (![order_ isEqual:[themeKey order]])
        return NO;
    if (![startDate_ isEqual:[themeKey startDate]])
        return NO;
    if (![endDate_ isEqual:[themeKey endDate]])
        return NO;
    if (![responsible_ isEqualToString:[themeKey responsible]])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    int hash = 7;
    hash = 31 * hash + (title_ ? 0 : title_.hash);
    hash = 31 * hash + (order_ ? 0 : order_.hash);
    hash = 31 * hash + (startDate_ ? 0 : startDate_.hash);
    hash = 31 * hash + (endDate_ ? 0 : endDate_.hash);
    hash = 31 * hash + (responsible_ ? 0 : responsible_.hash);
    return hash;
}

@end