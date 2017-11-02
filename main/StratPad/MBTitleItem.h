//
//  MBTitleItem.h
//  StratPad
//
//  Created by Eric Rogers on September 6, 2011.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//
//  A UIBarButtonItem that contains a label for use as the title item
//  in UIToolbar and UINavigationBar instances.  In addition, 
//  it will not display taps and will truncate text at the label's tail.

@interface MBTitleItem : UIBarButtonItem {
@private
    UILabel *lblTitle_;
}

@end
