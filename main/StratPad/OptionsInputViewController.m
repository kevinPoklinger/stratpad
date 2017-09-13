//
//  EnumInputViewController.m
//  StratPad
//
//  Created by Julian Wood on 2013-04-22.
//  Copyright (c) 2013 Glassey Strategy. All rights reserved.
//

#import "OptionsInputViewController.h"
#import "UIColor-Expanded.h"
#import "SkinManager.h"

@interface OptionsInputViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tblOptions;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBtnItemDescription;

@end

@implementation OptionsInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(self.desc !=nil , @"Set a description");
    NSAssert(_options !=nil , @"Set options");
    
    [_barBtnItemDescription setTitle:self.desc];

    [_tblOptions reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_desc release];
    [_value release];
    [_options release];
    [_target release];
    [_barBtnItemDescription release];
    [_tblOptions release];
    [_barBtnItemDescription release];
    [super dealloc];
}

-(CGSize)preferredSize
{
    CGFloat h = 44 + [self tableView:_tblOptions numberOfRowsInSection:0]*44;
    return CGSizeMake(self.view.bounds.size.width, h);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_target performSelector:_action withObject:[NSNumber numberWithInteger:indexPath.row]];
    self.value = [NSNumber numberWithInteger:indexPath.row];
    
    // reset the old selected cell as well as check the new cell
    [_tblOptions reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [[SkinManager sharedManager] colorForProperty:kSkinSection2TableCellFontColor];
    }
    
    if (_value != nil && _value.integerValue == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [_options objectAtIndex:[indexPath row]];
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *rowColor = indexPath.row % 2 == 1 ? [UIColor colorWithHexString:@"E6E6E6"] : [UIColor colorWithHexString:@"F1F1F1"];
    cell.backgroundColor = rowColor;
}

@end
