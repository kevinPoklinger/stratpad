//
//  Asset.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum  {
    AssetTypeLand           = 0,
    AssetTypeBuilding       = 1,
    AssetTypeMachinery      = 2,
    AssetTypeFurniture      = 3,
    AssetTypeTools          = 4,
    AssetTypeITEquipment    = 5,
    AssetTypeVehicles       = 6,
    AssetTypeOther          = 7,
    
    AssetTypeCount
} AssetType;

typedef enum  {
    AssetDepreciationTypeStraightLine   = 0,
    
    AssetDepreciationTypeCount
} AssetDepreciationTypes;


@class Financials;

@interface Asset : NSManagedObject

// name of asset
@property (nonatomic, retain) NSString * name;

// date acquired; YYYYMM but typically displayed as MMYY
@property (nonatomic, retain) NSNumber * date;

// value of asset - int
@property (nonatomic, retain) NSNumber * value;

// how many years until fully depreciated - int
@property (nonatomic, retain) NSNumber * depreciationTerm;

// value at end of depreciation term - int
@property (nonatomic, retain) NSNumber * salvageValue;

// how it depreciates - int
@property (nonatomic, retain) NSNumber * depreciationType;

// the category of asset - int
@property (nonatomic, retain) NSNumber * type;



// inverse
@property (nonatomic, retain) Financials *financials;


+(NSArray*) types;

+(NSArray*) depreciationTypes;

// a valid asset is completely filled in with non-nil values
- (BOOL)isValid;

// transient property used to tell us if the user just added this asset; will be NO by default
@property (nonatomic, assign) BOOL isNew;


@end
