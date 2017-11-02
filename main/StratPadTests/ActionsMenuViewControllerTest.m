//
//  ActionsMenuViewControllerTest.m
//  StratPad
//
//  Created by Julian Wood on 12-01-26.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ActionsMenuViewController.h"
#import "PdfHelper.h"
#import "StratFileManager.h"
#import "DataManager.h"

@interface ActionsMenuViewControllerTest : SenTestCase
@end

@implementation ActionsMenuViewControllerTest

-(void)testEmailAllReports
{
    // use v-soft
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"V-Soft Strategy"];
    StratFile *stratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                   sortDescriptorsOrNil:nil
                                         predicateOrNil:predicate];
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexAboutYourStrategy];

    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:nil
                                                      chapter:nil
                                                   pageNumber:0
                                                   reportSize:ReportSizeAllChapters
                                                 reportAction:ReportActionEmail
                         ];
    helper.allTasksCompletedBlock = ^(NSString* path) {
        // make sure file exists
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path], @"Oops");
        
        // and has a reasonable size
        NSDictionary *pathAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
        NSNumber *fileSize = [pathAttrs objectForKey:NSFileSize];
        STAssertTrue([fileSize intValue] > 50000, @"Oops: fileSize was: %@", fileSize);
    };
    [helper generatePdf];

}

-(void)testEmailAllReportsLarge
{
    // use mantra yoga
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Mantra Yoga Carlsbad"];
    StratFile *stratFile = (StratFile*)[DataManager objectForEntity:NSStringFromClass([StratFile class])
                                               sortDescriptorsOrNil:nil
                                                     predicateOrNil:predicate];
    [[StratFileManager sharedManager] loadStratFile:stratFile withChapterIndex:ChapterIndexAboutYourStrategy];
    
    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:nil
                                                      chapter:nil
                                                   pageNumber:0
                                                   reportSize:ReportSizeAllChapters
                                                 reportAction:ReportActionEmail
                         ];
    helper.allTasksCompletedBlock = ^(NSString* path) {
        // make sure file exists
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path], @"Oops");
        
        // and has a reasonable size
        NSDictionary *pathAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
        NSNumber *fileSize = [pathAttrs objectForKey:NSFileSize];
        STAssertTrue([fileSize intValue] > 50000, @"Oops: fileSize was: %@", fileSize);
    };
    [helper generatePdf];
}


-(void)testPdfPathWithFileName
{
    PdfHelper *helper = [[PdfHelper alloc] initWithReportName:nil
                                                      chapter:nil
                                                   pageNumber:0
                                                   reportSize:ReportSizeCurrentChapter
                                                 reportAction:ReportActionPrint
                         ];

    NSString *path = [helper pdfPathWithFileName:@"test\nfile.xml"];
    
    STAssertEqualObjects([path lastPathComponent], @"test file.pdf", @"Oops");
    [helper release];
}

@end
