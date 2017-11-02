//
//  MenuNavController.h
//  StratPad
//
//  Created by Julian Wood on 11-08-16.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

@protocol TableBasedMenu <NSObject>
-(UITableView*)tableView;
@end


@interface MenuNavController : UINavigationController<UIPopoverControllerDelegate> {
    UIPopoverController *popoverController_;    
    CGSize originalViewSize_;
}


@property (nonatomic,assign,readonly) UIPopoverController *popoverController;

- (void)showMenu:(UIBarButtonItem*)barButtonItem;
- (void)dismissMenu;
-(BOOL)isPresented;

@end
