//
//  ServiceProviderViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-03-31.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "ServiceProviderViewController.h"
#import "MBReportHeaderView.h"
#import "SkinManager.h"
#import "AFNetworking.h"
#import "ServiceProviderCell.h"

@interface ServiceProviderViewController ()
@property (retain, nonatomic) IBOutlet MBReportHeaderView *reportHeader;
@property (retain, nonatomic) IBOutlet UITableView *tblServiceProviders;

@property (retain, nonatomic) NSArray *serviceProviders;

@end

@implementation ServiceProviderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.serviceProviders = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    
    
    
    [_reportHeader setTextInsetLeft:20.f];
    [_reportHeader setReportTitle:@"Software and Related\nFind appropriate software and web services."];
    
//    SkinManager *skinMan = [SkinManager sharedManager];
//    
//    
//
//    
//    NSString *boldFontName = [skinMan stringForProperty:kSkinSection3BoldFontName forMediaType:MediaTypeScreen];
//        
//    [_reportHeader addTitleItemWithText:@"Find appropriate software and internet-related services."
//                                        font:[UIFont fontWithName:boldFontName size:[skinMan fontSizeForProperty:kSkinSection3ReportDescriptionFontSize forMediaType:MediaTypeScreen]]
//                                    andColor:[skinMan colorForProperty:kSkinSection3ReportDescriptionFontColor forMediaType:MediaTypeScreen]];

    
    // transparent table background
    self.tblServiceProviders.backgroundColor = [UIColor clearColor];
    self.tblServiceProviders.opaque = NO;
    self.tblServiceProviders.backgroundView = nil;
    self.tblServiceProviders.clipsToBounds = YES;
    
    [self fetchServiceProviders];
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [_reportHeader release];
    [_tblServiceProviders release];
    [_serviceProviders release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setReportHeader:nil];
    [self setTblServiceProviders:nil];
    [self setServiceProviders:nil];
    [super viewDidUnload];
}

-(void)fetchServiceProviders
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.tag = 9433;
    
    CGSize aSize = indicator.frame.size;
    indicator.frame = CGRectMake((_tblServiceProviders.frame.size.width - aSize.width)/2,
                                 (_tblServiceProviders.frame.size.height - aSize.height)/2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    [_tblServiceProviders addSubview:indicator];
    
    [indicator startAnimating];
    [indicator release];
    
    // host url
    NSURL *url = [NSURL URLWithString:@"http://guruscore.co"];
    AFHTTPClient *request = [AFHTTPClient clientWithBaseURL:url];
    
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"61", @"serviceId",
                            @"6", @"count",
                            nil];
    
    // post to server
    [request getPath:@"/GuruScoreService.svc/GetTopData"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                  DLog(@"Providers: %@", json);
                  
                  self.serviceProviders = [json objectForKey:@"d"];
                  [self.tblServiceProviders reloadData];
                  
                  [[self.tblServiceProviders viewWithTag:9433] removeFromSuperview];
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  ELog(@"Couldn't get service providers. %@", error);
                  [[self.tblServiceProviders viewWithTag:9433] removeFromSuperview];
              }
     ];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_serviceProviders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Accounting";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServiceProviderCell";
    ServiceProviderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSDictionary *dict = [_serviceProviders objectAtIndex:indexPath.row];

    // name
    cell.lblCompanyName.text = [dict objectForKey:@"CompanyName"];
        
    // get company logo
    NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reviewsgurus.com/App_Themes/Default/%@", [dict objectForKey:@"LogoURL"]]];
    [cell.imageViewCompanyLogo setImageWithURL:imgURL];
    
    // guru score
    NSString *imageName = [[[dict objectForKey:@"ScoreClassName"] lastPathComponent] stringByDeletingPathExtension];
    cell.imageViewGuruScore.image = [UIImage imageNamed:imageName];
    cell.lblGuruScore.text = [dict objectForKey:@"GuruScoreValue"];
    
    // description
    cell.lblDescription.text = [dict objectForKey:@"Description"];
    
    // reviews
    cell.lblReviews.text = [NSString stringWithFormat:@"%@ Reviews", [dict objectForKey:@"UserReviewsCount"]];
    
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_serviceProviders objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dict objectForKey:@"AffiliateLink"]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - overrides

- (void)exportToPDF
{
    
}



@end
