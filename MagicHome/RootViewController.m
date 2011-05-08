//
//  RootViewController.m
//  MagicHome
//
//  Created by Patrick Quinn-Graham on 8/05/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RootViewController.h"
#import "SwitchCell.h"
#import "DomusAPI.h"
#import "Reachability.h"

@interface RootViewController() 

- (void)configureZones;

@end


@implementation RootViewController

@synthesize zones, api, reach;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Home";
    
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.431 green:0.431 blue:0.427 alpha:1.000];
    
	self.tableView.backgroundColor = [UIColor clearColor];
	self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backdrop"]];
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = refresh;
    [refresh release];
    
    self.zones = [NSArray array];
    self.api = [[[DomusAPI alloc] init] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationWillEnterForegroundNotification object:nil]; 
    [self configureZones];
}

- (void)configureZones {
    
    NSDictionary *couch = [NSDictionary dictionaryWithObjectsAndKeys:@"Couch", @"name", 
                           @"lamp", @"mode", @"couch", @"id", nil];
    NSDictionary *stairs = [NSDictionary dictionaryWithObjectsAndKeys:@"Stairs", @"name", 
                            @"lamp", @"mode", @"stairs", @"id", nil];
    NSDictionary *allLamps = [NSDictionary dictionaryWithObjectsAndKeys:@"All off", @"name", 
                              @"macro", @"mode", @"lamps", @"id", @"off", @"action", nil];
    
    NSArray *lampItems = [NSArray arrayWithObjects:couch, stairs, allLamps, nil];
    NSDictionary *lamps = [NSDictionary dictionaryWithObjectsAndKeys:@"Lamps", @"name", lampItems, @"items", nil];
    
    NSDictionary *tallLLs = [NSDictionary dictionaryWithObjectsAndKeys:@"Tall", @"name", 
                             @"appliance", @"mode", @"tall_lavalamps", @"id", nil];
    NSDictionary *shortLLs = [NSDictionary dictionaryWithObjectsAndKeys:@"Short", @"name", 
                              @"appliance", @"mode", @"short_lavalamps", @"id", nil];
    NSDictionary *allLavaLamps = [NSDictionary dictionaryWithObjectsAndKeys:@"All off", @"name", 
                                  @"macro", @"mode", @"lava_lamps", @"id", @"off", @"action", nil];
    
    NSArray *lavampItems = [NSArray arrayWithObjects:tallLLs, shortLLs, allLavaLamps, nil];
    NSDictionary *lavaLamps = [NSDictionary dictionaryWithObjectsAndKeys:@"Lava Lamps", @"name", lavampItems, @"items", nil];
    
    self.zones = [NSArray arrayWithObjects:lamps, lavaLamps, nil];
    // [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
} 

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.zones ? [self.zones count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.zones objectAtIndex:section] objectForKey:@"items"] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[[self.zones objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *mode = [item objectForKey:@"mode"];
    NSString *alias = [item objectForKey:@"id"];
    
    NSString *CellIdentifier = [@"Cell" stringByAppendingFormat:@".%@", [item objectForKey:@"mode"]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if([mode isEqualToString:@"lamp"]|| [mode isEqualToString:@"appliance"]) {
            cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
           cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease]; 
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    cell.textLabel.text = [item objectForKey:@"name"];
    
    if([mode isEqualToString:@"lamp"] || [mode isEqualToString:@"appliance"]) {
        [(SwitchCell*)cell setSwitchDidChange:^(BOOL on, void (^callback)(BOOL, BOOL)){
            callback(on, NO);
            [api setAliasState:alias state:on withBlock:^(BOOL done, NSError *err) {
                if(!done) {
                    NSLog(@"Setting alias state failed... %@", err);
                    callback(!on, YES);
                } else {
                    callback(on, YES);
                }
            }];
        }];
        
        [(SwitchCell*)cell setSwitchState:^(void (^callback)(BOOL, BOOL)){
            callback(NO, NO);
            [api getAliasState:alias withBlock:^(BOOL on, NSInteger level, NSError *err) {
                if(err) {
                    NSLog(@"Getting %@ state failed... %@", alias, err);
                } else {
                    callback(on, YES);
                }
            }];
        }];
        
        [(SwitchCell*)cell refreshSwitcher];

    }

    // Configure the cell.
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *gv = [[UIView alloc] initWithFrame:CGRectZero];
	gv.backgroundColor = [UIColor clearColor];
	//	[[GradientView alloc] initWithFrame:CGRectMake(10.0,0.0,300.0,66.0)];
	//	
	//	gv.startColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	//	gv.endColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	
	UILabel * headerLabel = [[[UILabel alloc]
							  initWithFrame:CGRectZero] autorelease];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(10, 0, 300.0, 44.0);
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.text = [NSString stringWithString:[self tableView:tableView titleForHeaderInSection:section]];
	
  	[gv addSubview:headerLabel];
	
	return gv;
	
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.zones objectAtIndex:section] objectForKey:@"name"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[[self.zones objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *mode = [item objectForKey:@"mode"];
    NSString *alias = [item objectForKey:@"id"];
    
    if([mode isEqualToString:@"macro"]) {
        NSString *action = [item objectForKey:@"action"];
        [api setAliasState:alias state:[action isEqualToString:@"on"] withBlock:^(BOOL done, NSError *err) {
            if(!done) {
                NSLog(@"Setting alias state failed... %@", err);
            } else {
                NSLog(@"Done!");
            }
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.zones = nil;
    self.api = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)refresh:(id)sender {
    [self.tableView reloadData];
}

@end
