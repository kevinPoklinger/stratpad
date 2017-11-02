//
//  ImportStratFileViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-06-10.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "ImportStratFileViewController.h"
#import "StratFileManager.h"
#import "NSDate-StratPad.h"
#import "DataManager.h"
#import "NSString-Expanded.h"

@interface ImportStratFileViewController ()

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;

@property (retain, nonatomic) IBOutlet UILabel *lblNameExistingStratFile;
@property (retain, nonatomic) IBOutlet UILabel *lblDateCreatedExistingStratFile;
@property (retain, nonatomic) IBOutlet UILabel *lblDateModifiedExistingStratFile;

@property (retain, nonatomic) IBOutlet UILabel *lblNameImportedStratFile;
@property (retain, nonatomic) IBOutlet UILabel *lblDateCreatedImportedStratFile;
@property (retain, nonatomic) IBOutlet UILabel *lblDateModifiedImportedStratFile;

@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnKeepBoth;
@property (retain, nonatomic) IBOutlet UIButton *btnReplace;

@property (retain, nonatomic) UIPopoverController *popover;

@property (retain, nonatomic) StratFile *existingStratFile;
@property (retain, nonatomic) StratFile *importedStratFile;

@end

@implementation ImportStratFileViewController

- (id)initWithExistingStratFile:(StratFile*)existingStratFile importedStratFile:(StratFile*)importedStratFile
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.existingStratFile = existingStratFile;
        self.importedStratFile = importedStratFile;
        self.title = LocalizedString(@"IMPORT_STRATFILE", nil);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *btnCancelImg = [[UIImage imageNamed:@"btn-large-black-modern.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [_btnCancel setBackgroundImage:btnCancelImg forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCancel setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_btnCancel.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnCancel.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];

    UIImage *btnGreenImg = [[UIImage imageNamed:@"btn-large-green-modern.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [_btnKeepBoth setBackgroundImage:btnGreenImg forState:UIControlStateNormal];
    [_btnKeepBoth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnKeepBoth setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_btnKeepBoth.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnKeepBoth.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];

    [_btnReplace setBackgroundImage:btnGreenImg forState:UIControlStateNormal];
    [_btnReplace setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnReplace setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_btnReplace.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [_btnReplace.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
        
    BOOL isExistingOlder = [_existingStratFile.dateModified isBefore:_importedStratFile.dateModified];
    BOOL isSame = [_existingStratFile.dateModified isEqualToDate:_importedStratFile.dateModified];
    NSString *prefix = isSame ? LocalizedString(@"IMPORT_DIALOG_PREFIX_SAME", nil) : isExistingOlder ? LocalizedString(@"IMPORT_DIALOG_PREFIX_OLDER", nil) : LocalizedString(@"IMPORT_DIALOG_PREFIX_NEWER", nil);
    NSString *title = [NSString stringWithFormat:LocalizedString(@"IMPORT_DIALOG_TITLE", nil), prefix];
    _lblTitle.text = title;
    
    _lblNameExistingStratFile.text = _existingStratFile.name;
    _lblDateCreatedExistingStratFile.text = [NSString stringWithFormat:LocalizedString(@"IMPORT_DIALOG_DATE_CREATED", nil), [_existingStratFile.dateCreated formattedDateTimeForLocalTimeZone]];
    _lblDateModifiedExistingStratFile.text = [NSString stringWithFormat:LocalizedString(@"IMPORT_DIALOG_DATE_MODIFIED", nil), [_existingStratFile.dateModified formattedDateTimeForLocalTimeZone]];
    
    _lblNameImportedStratFile.text = _importedStratFile.name;    
    _lblDateCreatedImportedStratFile.text = [NSString stringWithFormat:LocalizedString(@"IMPORT_DIALOG_DATE_CREATED", nil), [_importedStratFile.dateCreated formattedDateTimeForLocalTimeZone]];
    _lblDateModifiedImportedStratFile.text = [NSString stringWithFormat:LocalizedString(@"IMPORT_DIALOG_DATE_MODIFIED", nil), [_importedStratFile.dateModified formattedDateTimeForLocalTimeZone]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(CGSize)contentSizeForViewInPopover
{
    return self.view.bounds.size;
}

- (IBAction)cancelImport:(id)sender {
    // delete the imported stratfile
    [[StratFileManager sharedManager] deleteStratFile:_importedStratFile];

    [DataManager saveManagedInstances];
    [self dismissPopover];
}

- (IBAction)keepBothStratFiles:(id)sender {

    // can't allow two stratfiles with the same uuid in the db
    _importedStratFile.name = [NSString stringWithFormat:@"%@ %@", _importedStratFile.name, LocalizedString(@"SUFFIX_IMPORTED", nil)];
    _importedStratFile.uuid = [NSString stringWithUUID];
    
    // load it up
    [[StratFileManager sharedManager] loadStratFile:_importedStratFile withChapterIndex:ChapterIndexAboutYourStrategy];
    
    [DataManager saveManagedInstances];
    
    [self dismissPopover];
}

- (IBAction)replaceExistingStratFile:(id)sender {
    // delete the existing stratfile
    [[StratFileManager sharedManager] deleteStratFile:_existingStratFile];

    // load up the new one
    [[StratFileManager sharedManager] loadStratFile:_importedStratFile withChapterIndex:ChapterIndexAboutYourStrategy];
    
    [DataManager saveManagedInstances];
    
    [self dismissPopover];
}

- (void)dealloc {
    [_existingStratFile release];
    [_importedStratFile release];
    [_btnCancel release];
    [_btnKeepBoth release];
    [_btnReplace release];
    [_lblTitle release];
    [_lblNameExistingStratFile release];
    [_lblDateCreatedExistingStratFile release];
    [_lblDateModifiedExistingStratFile release];
    [_lblNameImportedStratFile release];
    [_lblDateCreatedImportedStratFile release];
    [_lblDateModifiedImportedStratFile release];
    [super dealloc];
}


#pragma mark - Public

- (void)showPopoverInView:(UIView*)view
{    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
    navController.modalInPopover = YES;
    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.popover = popover;
    [popover release];
    [navController release];
    
    [_popover presentPopoverFromRect:view.bounds
                                        inView:view
                      permittedArrowDirections:0 // no arrows
                                      animated:YES];
}


- (void)dismissPopover
{
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
    }
    else {
        // if it was appended to a nav controller
        UIViewController *vc = [[self.navigationController viewControllers] objectAtIndex:0];
        if ([vc respondsToSelector:@selector(dismissPopover)]) {
            [vc performSelector:@selector(dismissPopover)];
        }
    }
}

@end
