//
//  NoRowsTableDataSource.m
//  StratPad
//
//  Created by Julian Wood on 11-08-21.
//  Copyright 2011 Glassey Strategy. All rights reserved.
//

#import "NoRowsTableDataSource.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"
#import "AddRowTableViewCell.h"

@implementation NoRowsTableDataSource

@synthesize titleForRow = titleForRow_;
@synthesize isRounded = isRounded_;

-(id)initWithTitle:(NSString*)titleForRow
{
    self = [super init];
    if (self) {
        titleForRow_ = titleForRow;
        isRounded_ = YES;
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell;
    if (isRounded_) {
        cell = [self roundedCellForTableView:tableView];
        ((AddRowTableViewCell*)cell).lblAddRow.text = titleForRow_;
    } else {
        // this is basically for the straboard - can make this more flexible if needed
        static NSString *noRowsCellIdentifier = @"NoRowsTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:noRowsCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FrequencyCell"] autorelease];        
        }
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = titleForRow_;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumFontSize = 12;
    }
    
    return cell;                
}

-(AddRowTableViewCell*)roundedCellForTableView:(UITableView*)tableView
{
    static NSString* RoundedCellIdentifier = @"AddRowTableViewCell";
    AddRowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RoundedCellIdentifier];
    if (cell == nil) {
        // not localized
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:RoundedCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        SkinManager *skinMan = [SkinManager sharedManager];
        cell.roundedView.backgroundColor = [skinMan colorForProperty:kSkinSection2TableCellBackgroundColor];
        cell.lblAddRow.font = [skinMan fontWithName:kSkinSection2TableCellFontName andSize:kSkinSection2TableCellMediumFontSize];
        cell.lblAddRow.textColor = [skinMan colorForProperty:kSkinSection2PlaceHolderFontColor];
        cell.lblAddRow.backgroundColor = [UIColor clearColor];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
