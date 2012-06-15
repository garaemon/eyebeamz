//
//  MCZRootViewController.m
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MCZRootViewController.h"
#import "MCZUtil.h"
#import "MCZNetworkClient.h"

@interface MCZRootViewController ()

@end

@implementation MCZRootViewController

- (void)alertView:(NSString*)title message:(NSString*)message
{
  UIAlertView* alert
    = [[UIAlertView alloc]
        initWithTitle:title
              message:message
             delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
  [alert show];
}

- (id)initWithoutStyle
{
  self = [self initWithStyle:UITableViewStyleGrouped];
  if (self) {
    
  }
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
 
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
  // Configure the cell...
  NSInteger row = indexPath.row;
  NSInteger section = indexPath.section;
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }
  switch (section) {
  case 0:
    switch (row) {
    case 0:
      cell.textLabel.text = LOCALIZED_STRING(@"take a picture");
      break;
    case 1:
      cell.textLabel.text = LOCALIZED_STRING(@"choose from photoroll");
      break;
    default:
      break;
    }
    break;
  default:
    break;
  }
  
  return cell;
}

- (void)openCameraPicker:(UIImagePickerControllerSourceType)sourceType
{
  if (![UIImagePickerController
             isSourceTypeAvailable:sourceType]) {
    [self alertView:@"Bad news"
            message:@"your device does not support this device"];
  }
  else {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    LOG_INFO(@"open picker");
    [self presentModalViewController:picker animated:YES];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  LOG_INFO(@"closed");
  [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker
        didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
  LOG_INFO(@"closed");
  MCZNetworkClient* client = [MCZNetworkClient callback:^(NSDictionary* dummy){
    }
  failCallback:^() {
    }];
  [client postPhoto:image];
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view delegate
   
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  if (section == 0 && row == 0)
    [self openCameraPicker:UIImagePickerControllerSourceTypeCamera];
  else if (section == 0 && row == 1)
    [self openCameraPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

@end
