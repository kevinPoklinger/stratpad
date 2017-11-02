//
//  Settings.h
//  StratPad
//
//  Created by Julian Wood on 11-08-15.
//  Copyright (c) 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Settings : NSManagedObject {
@private
}

// flag indicating whether or not the user has rated this version of the app.
@property (nonatomic, retain) NSNumber * appRated;

// version string containing the last version of the app the user rated.
@property (nonatomic, retain) NSString * lastVersionRated;

// used for making calculations in the reports
@property (nonatomic, retain) NSNumber * isCalculationOptimistic;

// the currency abbreviation to use in reports
@property (nonatomic, retain) NSString * currency;

// the version of the app installed
@property (nonatomic, retain) NSString * version;

// consultants only - name of the firm
@property (nonatomic, retain) NSString * consultantFirm;

// a logo image, for use on the reports
@property (nonatomic, retain) id consultantLogo;


@end
