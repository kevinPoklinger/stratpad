//
//  MultiPageReportBuilderTest.m
//  StratPad
//
//  Created by Julian Wood on 1/7/2014.
//  Copyright (c) 2014 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MultiPageReportBuilder.h"
#import "MBTestDrawable.h"
#import "MBDrawableLabel.h"

@interface MultiPageReportBuilderTest : SenTestCase

@property (nonatomic, retain) NSString *contentB;

@end

@implementation MultiPageReportBuilderTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.contentB = @"There are many organizations who would like to use DocLock. For now, we will focus on military organizations and federal, state and provincial governments in Canada and the U.S. For them, the consequences of stray documents can be enormous. \
    \
    Even though the normal procurement cycles for these customers are long, we are assured that highly relevant products such as DocLock are routinely fast-tracked through the purchase process.Organizations need to share documents among their management and staff and with other organizations. However, the increasing power, portability and communications abilities of computing devices increases the risk that sensitive documents will be lost, stolen or inappropriately shared. The cost of this type of event can be incalculable. \
    \
    There are several commercial solutions to this problem. None, however, are complete. Each suffers from a key failing related to either security, convenience or disaster mitigation. All have fatally flawed designs that prevent them from providing a complete alternative. That being said, this is a robust sector and these companies generated combined revenues of US$7.2 billion in 2010. Gartner forecasts growth exceeding 20% for each of the next three years.We have created a software system called DocLock which is based on several patents which we own. DocLock allows trusted users to encrypt, store, view, print, share and remotely retrieve PDF files. DocLock works on all major computing and mobile platforms. It uses military grade encryption and a unique approach to protecting documents no matter how far they are shared. \
    \
    Here's how it works: you prepare a PDF document and wish to share it with a group. You drag the document to the DocLock icon and it is immediately and automatically encrypted. From within DocLock you specify the people that are permitted to have access to the document (the distribution list) and whether they may print the document. You then send it to one or more of them. \
    \
    Document recipients may open, view or print (if allowed) the document but must do so from within DocLock. All activity is logged and this log is transmitted to the document's author. Recipients can only share the document with people on the distribution list. The document may not be edited nor can its image be captured from the screen via the local operating system. Further, the document is not available as an independent file and so cannot be \"seen\" outside of DocLock. \
    \
    As a final security measure, any document can be \"recalled\". The author or an administrator can cause all copies of the document on any DocLock device to be immediately and irrevocably destroyed. \
    \
    This technology virtually guarantees the security of the document while removing none of the user's convenience. Further, the audit log provides excellent forensic abilities to further mitigate potential misuse.We have large, capable, aggressive competitors with existing products. These four provide examples of the state-of-the-art: \
    \
    DropBox offers a hosted environment with controlled distribution and the potential to recall or destroy documents. However, documents can be removed from the DropBox environment and, once removed, can be freely distributed. \
    \
    Adobe is the author of the PDF format and have made this format increasingly secure. However, they do not provide a distribution solution. PDF documents can be easily duplicated and freely shared. \
    \
    IBM uses a blend of services and technology to create customized solutions for their customers that are often integrated with workflow and other process automation projects. Their solutions, however, are expensive and don't offer the flexibility and multi-platform support of DocLock. \
    \
    Oracle, like DropBox, offers document management solutions tied to their flagship product. Highly secure and robust, they offer logging and recall functions. However, documents are tied directly to the Oracle database environment and so the flexibility to share on devices or with people that not have an Oracle database is not possible. \
    \
    DocLock provides a superior solution that matches the best features of these competitive offerings with none of their weaknesses.We generate revenue by selling software licenses to those who wish to share their documents. DocLock is free to install on any supported device, however, only \"Pro\" licenses can send documents. These licenses are $4,995 per \"Pro\" user. Enterprise licensing is available with discounts as high as 50% for more than 1,000 \"Pro\" users. \
    \
    We will hire an outbound sales team headed by an experienced large account sales manager. After a comprehensive outbound marketing campaign to increase our target prospects' awareness of DocLock, the sales team will attend two key trade shows. The team and the outbound campaigns will continue to be refined and expanded.Beyond North American military and government applications, DocLock is an appropriate solution in all countries and to any research-based organization or corporation that wishes to ensure the security of their documents. Our preliminary research suggests that there are 2,500 organizations in North America that would be interested in acquiring DocLock \"Pro\" licenses for at least 100 users. This equates to a retail value of US$125,000,000. ";
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBasicOnePager
{
    CGRect printInsetRect = CGRectMake(54, 142, 504, 614);
    MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect];
    pageBuilder.mediaType = MediaTypePrint;

    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(49, 36, 509, 86)]]; // header
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 142, 144, 13)]]; // A heading
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 165, 481, 78)]]; // A
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 263, 253, 13)]]; // B heading

    NSArray *pagedDrawables = [pageBuilder build];
    
    STAssertEquals([pagedDrawables count], (uint)1, @"Oops");
    STAssertEquals([pagedDrawables[0] count], (uint)4+1, @"Oops"); // builder adds the page number
    
    // all fits on 1 page
    STAssertEquals([pagedDrawables[0][3] rect], CGRectMake(54, 263, 253, 13), @"Oops");
    
    for (NSArray *drawablesForPage in pagedDrawables) {
        for (id<Drawable> drawable in drawablesForPage) {
            DLog(@"page: %i, rect: %@", 0, NSStringFromCGRect(drawable.rect));
        }
    }
    
    [pageBuilder release];
    
}

- (void)testTwoPager
{
    CGRect printInsetRect = CGRectMake(54, 36, 504, 700);
    MultiPageReportBuilder *pageBuilder = [[MultiPageReportBuilder alloc] initWithPageRect:printInsetRect];
    pageBuilder.mediaType = MediaTypePrint;
    
    // margin is 10 between heading and content, 20 between sections (ie at content bottom)
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(49, 36, 509, 86)]]; // header
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 142, 144, 13)]]; // A heading
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 165, 481, 78)]]; // A
    [pageBuilder addDrawable:[[MBTestDrawable alloc] initWithRect:CGRectMake(54, 263, 253, 13)]]; // B heading
    
    MBDrawableLabel *lblSectionBContent = [[MBDrawableLabel alloc] initWithText:self.contentB
                                                                           font:[UIFont fontWithName:@"Helvetica" size:12]
                                                                          color:[UIColor colorWithWhite:0 alpha:1]
                                                                  lineBreakMode:UILineBreakModeWordWrap
                                                                      alignment:UITextAlignmentLeft
                                                                        andRect:CGRectMake(54, 286, 504, 975)];
    [pageBuilder addDrawable:lblSectionBContent]; // B - needs a split
    [lblSectionBContent release];
    
    
    NSArray *pagedDrawables = [pageBuilder build];
    
    STAssertEquals([pagedDrawables count], (uint)2, @"Oops");
    STAssertEquals([pagedDrawables[0] count], (uint)5+1, @"Oops"); // builder adds the page number in the margin
    STAssertEquals([pagedDrawables[1] count], (uint)1+1, @"Oops"); // builder adds the page number
    
    for (uint i=0; i<pagedDrawables.count; ++i) {
        NSArray *drawablesForPage = [pagedDrawables objectAtIndex:i];
        for (id<Drawable> drawable in drawablesForPage) {
            DLog(@"page: %i, rect: %@", i, NSStringFromCGRect([drawable rect]));
        }
    }
    
    [pageBuilder release];
    
}

@end
