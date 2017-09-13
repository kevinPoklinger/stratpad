//
//  StrategyMapPrintDelegate.h
//  StratPad
//
//  Created by Julian Wood on 11-09-30.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractReportDelegate.h"
#import "StrategyMapView.h"

@interface StrategyMapPrintDelegate : AbstractReportDelegate<PrintReportDelegate> {
@private
    int pageCounter_;
    uint numPages_;
    StrategyMapView *strategyMapView_;
}

@property (nonatomic,retain) StrategyMapView *strategyMapView;

@end
