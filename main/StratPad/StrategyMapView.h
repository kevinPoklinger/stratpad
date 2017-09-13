//
//  StrategyMapView.h
//  StratPad
//
//  Created by Julian Wood on 11-08-19.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StratFile.h"
#import "SkinManager.h"

extern CGFloat const cornerRadius;

// strategy statement, themes, 4 regular objective types, 2 additional types = 8
// screen height for this rect is 752, though a lot of it is offscreen
// we don't change the number around, regarless of whether we are in non-profit or not
extern NSUInteger const numRows;

@interface StrategyMapView : UIView {
    SkinManager *skinMan_;
    
    StratFile *stratFile_;
        
    NSUInteger pageNumber_;
}

// print or screen
@property(nonatomic,assign) MediaType mediaType;

// what page are we on?
@property (nonatomic,assign) NSUInteger pageNumber;

@end

