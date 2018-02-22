//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "NotificationSettingsOptionsViewController.h"
#import "OWSSoundSettingsViewController.h"
#import <SignalMessaging/Environment.h>
#import <SignalMessaging/OWSPreferences.h>

@implementation NotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"SETTINGS_NOTIFICATIONS", nil)];

    [self updateTableContents];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateTableContents];
}

#pragma mark - Table Contents

- (void)updateTableContents
{
    OWSTableContents *contents = [OWSTableContents new];

    __weak NotificationSettingsViewController *weakSelf = self;

    OWSPreferences *prefs = [Environment preferences];
    
    // Sounds section.
    
    OWSTableSection *soundsSection = [OWSTableSection new];
    soundsSection.headerTitle = NSLocalizedString(@"SETTINGS_SECTION_SOUNDS",
                                                  @"Label for the sounds section of settings views.");
    [soundsSection
     addItem:[OWSTableItem disclosureItemWithText:
              NSLocalizedString(@"SETTINGS_ITEM_NOTIFICATION_SOUND",
                                @"Label for settings view that allows user to change the notification sound.")
                                      actionBlock:^{
                                          OWSSoundSettingsViewController *vc =
                                          [OWSSoundSettingsViewController new];
                                          vc.soundType = OWSSoundType_Notification;
                                          [weakSelf.navigationController pushViewController:vc animated:YES];
                                      }]];
    [soundsSection
     addItem:[OWSTableItem disclosureItemWithText:
              NSLocalizedString(@"SETTINGS_ITEM_RINGTONE_SOUND",
                                @"Label for settings view that allows user to change the ringtone sound.")
                                      actionBlock:^{
                                          OWSSoundSettingsViewController *vc =
                                          [OWSSoundSettingsViewController new];
                                          vc.soundType = OWSSoundType_Ringtone;
                                          [weakSelf.navigationController pushViewController:vc animated:YES];
                                      }]];
    [contents addSection:soundsSection];
    
    OWSTableSection *backgroundSection = [OWSTableSection new];
    backgroundSection.headerTitle = NSLocalizedString(@"NOTIFICATIONS_SECTION_BACKGROUND", nil);
    [backgroundSection addItem:[OWSTableItem itemWithCustomCellBlock:^{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                       reuseIdentifier:@"UITableViewCellStyleValue1"];

        NotificationType notifType = [prefs notificationPreviewType];
        NSString *detailString     = [prefs nameForNotificationPreviewType:notifType];
        cell.textLabel.text = NSLocalizedString(@"NOTIFICATIONS_SHOW", nil);
        cell.detailTextLabel.text = detailString;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        return cell;
    }
                                   actionBlock:^{
                                       NotificationSettingsOptionsViewController *vc =
                                           [NotificationSettingsOptionsViewController new];
                                       [weakSelf.navigationController pushViewController:vc animated:YES];
                                   }]];
    [contents addSection:backgroundSection];

    OWSTableSection *inAppSection = [OWSTableSection new];
    inAppSection.headerTitle = NSLocalizedString(@"NOTIFICATIONS_SECTION_INAPP", nil);
    [inAppSection addItem:[OWSTableItem switchItemWithText:NSLocalizedString(@"NOTIFICATIONS_SOUND", nil)
                                                      isOn:[prefs soundInForeground]
                                                    target:weakSelf
                                                  selector:@selector(didToggleSoundNotificationsSwitch:)]];
    [contents addSection:inAppSection];

    self.contents = contents;
}

#pragma mark - Events

- (void)didToggleSoundNotificationsSwitch:(UISwitch *)sender {
    [Environment.preferences setSoundInForeground:sender.on];
}

@end
