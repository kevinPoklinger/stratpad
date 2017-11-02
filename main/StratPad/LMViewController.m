//
//  LMViewController.m
//  StratPad
//
//  Created by Vitaliy Nevgadaylov on 12.07.12.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "LMViewController.h"


@implementation LMViewController

// todo: clean this up
// http://indiedevstories.com/2011/11/08/a-reusable-localization-manager-class-for-ios/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // most of our VC's are inited without a nibName, in which case we can try to get it ourselves
    // if we get a path for a nibNameOrNil=nil, then we try to grab it
    // nibBundleOrNil is just passed on
    
//    NSBundle *localBundle = [[LocalizedManager sharedManager]currentBundle];      
//    NSFileManager *filemanager = [NSFileManager defaultManager];
//    
//    NSString *nibPath = [localBundle pathForResource:nibNameOrNil ofType:@"nib"];
//    DLog(@"nibPath: %@", nibPath);
//    NSString *nibName = [self nibName:nibNameOrNil];
//    nibPath = [localBundle pathForResource:nibName ofType:@"nib"];
//    DLog(@"nibPath with calculated nibName: %@", nibPath);
//    
//    if(![filemanager fileExistsAtPath:nibPath] || nibPath==nil){
//        localBundle = [NSBundle mainBundle];
//    }
//    self = [super initWithNibName:nibName bundle:localBundle];
//    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLocalizableResources) name:kLMLocaleChanged object:nil];
//    }
//    return self;
    
    // use the current, localized bundle
    NSBundle *localBundle = [[LocalizedManager sharedManager] currentBundle];
    
    // if the resource is missing from the localized bundle, use the main bundle
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *path = [localBundle pathForResource:[self nibName:nibNameOrNil] ofType:@"nib"];
    DLog(@"nib path: %@", path);
    if(![filemanager fileExistsAtPath:path] || nibNameOrNil==nil){
        localBundle = [NSBundle mainBundle];
    }
    
    // init with the correct bundle
    self = [super initWithNibName:nibNameOrNil bundle:localBundle];
    if (self) {
        // listen for when the language gets changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLocalizableResources) name:kLMLocaleChanged object:nil];
    }
    return self;

}

-(NSString*)nibName:(NSString*)nibNameOrNil
{
    if (nibNameOrNil) {
        return nibNameOrNil;
    }
    
    // unfortunately won't work for any section 1 html pages, which are all ReferenceViewControllers
    NSString *nibName = NSStringFromClass([self class]);
    
    NSBundle *localBundle = [[LocalizedManager sharedManager] currentBundle];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    // look for nibs with filename pattern identical to controller name
    if ([filemanager fileExistsAtPath:[localBundle pathForResource:nibName ofType:@"nib"]]) {
//        [self viewDidUnload];
//        [localBundle loadNibNamed:nibName owner:self options:nil];
//        [self viewDidLoad];
        return nibName;
        
    } else {
        // look for nibs with filename pattern missing the Controller part
        nibName = [nibName stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
        if([filemanager fileExistsAtPath:[localBundle pathForResource:nibName ofType:@"nib"]]) {
//            [self viewDidUnload];
//            [localBundle loadNibNamed:nibName owner:self options:nil];
//            [self viewDidLoad];
            return nibName;
        }
    }
    
    WLog(@"Couldn't find nib %@ in bundle.", nibName);
    
    return nil;

}

//in subclass redefine this if need call another localizable object
- (void)reloadLocalizableResources
{
    
    // unfortunately won't work for any section 1 html pages, which are all ReferenceViewControllers
    NSString *nibNameOrNil = NSStringFromClass([self class]);

    NSBundle *localBundle = [[LocalizedManager sharedManager] currentBundle];      
    NSFileManager *filemanager = [NSFileManager defaultManager];

    // look for nibs with filename pattern identical to controller name
    if ([filemanager fileExistsAtPath:[localBundle pathForResource:nibNameOrNil ofType:@"nib"]]) {
        [self viewDidUnload];
        [localBundle loadNibNamed:nibNameOrNil owner:self options:nil];         
        [self viewDidLoad];
        
    } else {
        // look for nibs with filename pattern missing the Controller part
        nibNameOrNil = [nibNameOrNil stringByReplacingOccurrencesOfString:@"Controller" withString:@""]; 
        if([filemanager fileExistsAtPath:[localBundle pathForResource:nibNameOrNil ofType:@"nib"]]) {
            [self viewDidUnload];
            [localBundle loadNibNamed:nibNameOrNil owner:self options:nil]; 
            [self viewDidLoad];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLMLocaleChanged object:nil];

    [super dealloc];
}


@end
