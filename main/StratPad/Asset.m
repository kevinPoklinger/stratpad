//
//  Asset.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "Asset.h"
#import "Financials.h"
#import "NSString-Expanded.h"


@implementation Asset

@dynamic name;
@dynamic date;
@dynamic value;
@dynamic depreciationTerm;
@dynamic salvageValue;
@dynamic depreciationType;
@dynamic type;

// inverse
@dynamic financials;

@synthesize isNew;


+(NSArray*) types
{
    NSMutableArray *ary = [NSMutableArray array];
    for (int i=0; i<AssetTypeCount; i++) {
        NSString * key = [NSString stringWithFormat:@"AssetType_%d", i];
        [ary addObject:LocalizedString(key, nil)];
    }
    return ary;
}

+(NSArray*) depreciationTypes
{
    NSMutableArray *ary = [NSMutableArray array];
    for (int i=0; i<AssetDepreciationTypeCount; i++) {
        NSString * key = [NSString stringWithFormat:@"AssetDepreciationType_%d", i];
        [ary addObject:LocalizedString(key, nil)];
    }
    return ary;    
}

- (BOOL)isValid
{
    return ![self.name isBlank] &&
    self.date != nil &&
    self.value != nil &&
    self.depreciationTerm != nil &&
    self.salvageValue != nil &&
    self.depreciationType != nil &&
    self.type != nil;
}

@end
