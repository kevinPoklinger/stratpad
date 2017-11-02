//
//  EmployeeDeductions.h
//  StratPad
//
//  Created by Julian Wood on 2013-04-24.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum  {
    RemittanceDueDateThisMonth = 0,
    RemittanceDueDateNextMonth = 1
} RemittanceDueDate;

@class Financials;

@interface EmployeeDeductions : NSManagedObject

// what percent of each of these groups are wages? cost of goods and services
@property (nonatomic, retain) NSNumber * percentCogsAreWages;

// general and administration
@property (nonatomic, retain) NSNumber * percentGandAAreWages;

// research and development
@property (nonatomic, retain) NSNumber * percentRandDAreWages;

// sales and marketing
@property (nonatomic, retain) NSNumber * percentSandMAreWages;

// On average, how much do you deduct from an employee's pay, as a percentage?
@property (nonatomic, retain) NSNumber * employeeContributionPercentage;

//On average, what is the employer's portion, as a percentage of the employee's pay?
@property (nonatomic, retain) NSNumber * employerContributionPercentage;

// A RemittanceDueDate
@property (nonatomic, retain) NSNumber * dueDate;

// inverse
@property (nonatomic, retain) Financials *financials;

@end
