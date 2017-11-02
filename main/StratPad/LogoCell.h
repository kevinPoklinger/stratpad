//
//  LogoCell.h
//  StratPad
//
//  Created by Julian Wood on 12-01-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//
//  A cell which has a title, a subtitle, an image to represent the logo and a clear button.
//  When there is no logo, the image says edit instead.
//  Note that we only need the english localization of the background image.

#import <UIKit/UIKit.h>

@protocol LogoEditor <NSObject>
-(void)editLogo;
@end

@interface LogoCell : UITableViewCell

@property (assign, nonatomic) id<LogoEditor> logoEditor;

-(void)setLogoImage:(UIImage *)image;

@end
