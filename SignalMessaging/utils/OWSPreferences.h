//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * The users privacy preference for what kind of content to show in lock screen notifications.
 */
typedef NS_ENUM(NSUInteger, NotificationType) {
    NotificationNoNameNoPreview,
    NotificationNameNoPreview,
    NotificationNamePreview,
};

// Used when migrating logging to NSUserDefaults.
extern NSString *const OWSPreferencesSignalDatabaseCollection;
extern NSString *const OWSPreferencesKeyEnableDebugLog;

@interface OWSPreferences : NSObject

#pragma mark - Helpers

- (nullable id)tryGetValueForKey:(NSString *)key;
- (void)setValueForKey:(NSString *)key toValue:(nullable id)value;
- (void)clear;

#pragma mark - Specific Preferences

+ (BOOL)isReadyForAppExtensions;
+ (void)setIsReadyForAppExtensions;

- (BOOL)getHasSentAMessage;
- (void)setHasSentAMessage:(BOOL)enabled;

- (BOOL)getHasArchivedAMessage;
- (void)setHasArchivedAMessage:(BOOL)enabled;

+ (BOOL)isLoggingEnabled;
+ (void)setIsLoggingEnabled:(BOOL)flag;

- (BOOL)screenSecurityIsEnabled;
- (void)setScreenSecurity:(BOOL)flag;

- (NotificationType)notificationPreviewType;
- (void)setNotificationPreviewType:(NotificationType)type;
- (NSString *)nameForNotificationPreviewType:(NotificationType)notificationType;

- (BOOL)soundInForeground;
- (void)setSoundInForeground:(BOOL)enabled;

- (BOOL)hasDeclinedNoContactsView;
- (void)setHasDeclinedNoContactsView:(BOOL)value;

- (void)setIOSUpgradeNagDate:(NSDate *)value;
- (nullable NSDate *)iOSUpgradeNagDate;

#pragma mark - Calling

#pragma mark Callkit

- (BOOL)isCallKitEnabled;
- (void)setIsCallKitEnabled:(BOOL)flag;
// Returns YES IFF isCallKitEnabled has been set by user.
- (BOOL)isCallKitEnabledSet;

- (BOOL)isCallKitPrivacyEnabled;
- (void)setIsCallKitPrivacyEnabled:(BOOL)flag;
// Returns YES IFF isCallKitPrivacyEnabled has been set by user.
- (BOOL)isCallKitPrivacySet;

#pragma mark direct call connectivity (non-TURN)

- (BOOL)doCallsHideIPAddress;
- (void)setDoCallsHideIPAddress:(BOOL)flag;

#pragma mark - Push Tokens

- (void)setPushToken:(NSString *)value;
- (nullable NSString *)getPushToken;

- (void)setVoipToken:(NSString *)value;
- (nullable NSString *)getVoipToken;

- (void)unsetRecordedAPNSTokens;

@end

NS_ASSUME_NONNULL_END
