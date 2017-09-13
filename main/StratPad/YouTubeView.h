//
//  YouTubeView.h
//  StratPad
//
//  Created by Julian Wood on 12-05-18.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTubeView : UIWebView

// borderhack is used to cover up an ugly grey border on the right hand side of the (StratBoard promotional) video
@property (nonatomic,assign) BOOL useBorderHack;

-(void)loadVideo:(NSString*)url;
-(void)loadErrorText:(NSString*)errorText;

@end