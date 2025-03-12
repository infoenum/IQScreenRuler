//
//  SRDeveloperSettingsViewController.m
//  Screen Ruler
//
//  Created by IEMacBook01 on 16/10/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "SRDeveloperSettingsViewController.h"
#import "AppDelegate.h"
#import "SRDebugHelper.h"
#import "AdManager.h"

@interface SRDeveloperSettingsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *labelShowTouches;
@property (strong, nonatomic) IBOutlet UISwitch *switchShowTouch;

@property (strong, nonatomic) IBOutlet UILabel *labelInUseMemory;
@property (strong, nonatomic) IBOutlet UILabel *labelInUseMemoryBytes;

@property (strong, nonatomic) IBOutlet UILabel *labelVirtualMemory;
@property (strong, nonatomic) IBOutlet UILabel *labelVirtualMemoryBytes;

@end

@implementation SRDeveloperSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AdManager sharedManager] loadInterstitialAd];
    self.title = NSLocalizedString(@"developer_options", nil);
    self.labelShowTouches.text = NSLocalizedString(@"show_touches", nil);
    self.labelInUseMemory.text = NSLocalizedString(@"in_use_memory", nil);
    self.labelVirtualMemory.text = NSLocalizedString(@"virtual_memory", nil);
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    _switchShowTouch.on = appDelegate.shouldShowTouches;

    if (_switchShowTouch.on) {
        [[AdManager sharedManager] showAd:self];
        }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _labelInUseMemoryBytes.text = @"...";
    _labelVirtualMemoryBytes.text = @"...";
    [[NSOperationQueue new] addOperationWithBlock:^{
        struct task_basic_info info = [SRDebugHelper memoryReport];
        
        NSByteCountFormatter *formatter = [NSByteCountFormatter new];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _labelInUseMemoryBytes.text = [formatter stringFromByteCount:info.resident_size];
            _labelVirtualMemoryBytes.text = [formatter stringFromByteCount:info.virtual_size];
        }];
    }];
}

- (IBAction)showTouchesAction:(UISwitch *)sender
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.shouldShowTouches = _switchShowTouch.on;
    if (sender.on) {
              [[AdManager sharedManager] loadInterstitialAd];
              [[AdManager sharedManager] showAd:self];
      }
  }
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 70;
    }
    else
    {
        return 44;
    }
}

@end
