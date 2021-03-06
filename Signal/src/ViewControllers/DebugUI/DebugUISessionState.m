//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "DebugUISessionState.h"
#import "OWSTableViewController.h"
#import "Signal-Swift.h"
#import <SignalServiceKit/OWSIdentityManager.h>
#import <SignalServiceKit/TSContactThread.h>
#import <SignalServiceKit/TSStorageManager+SessionStore.h>

NS_ASSUME_NONNULL_BEGIN

@implementation DebugUISessionState

- (NSString *)name
{
    return @"Session State";
}

- (nullable OWSTableSection *)sectionForThread:(nullable TSThread *)threadParameter
{
    NSMutableArray<OWSTableItem *> *items = [NSMutableArray new];
    if ([threadParameter isKindOfClass:[TSContactThread class]]) {
        TSContactThread *thread = (TSContactThread *)threadParameter;
        [items addObjectsFromArray:@[
            [OWSTableItem itemWithTitle:@"Log All Recipient Identities"
                            actionBlock:^{
                                [OWSRecipientIdentity printAllIdentities];
                            }],
            [OWSTableItem itemWithTitle:@"Log All Sessions"
                            actionBlock:^{
                                [[TSStorageManager sharedManager] printAllSessions];
                            }],
            [OWSTableItem itemWithTitle:@"Toggle Key Change"
                            actionBlock:^{
                                DDLogError(@"Flipping identity Key. Flip again to return.");

                                OWSIdentityManager *identityManager = [OWSIdentityManager sharedManager];
                                NSString *recipientId = [thread contactIdentifier];

                                NSData *currentKey = [identityManager identityKeyForRecipientId:recipientId];
                                NSMutableData *flippedKey = [NSMutableData new];
                                const char *currentKeyBytes = currentKey.bytes;
                                for (NSUInteger i = 0; i < currentKey.length; i++) {
                                    const char xorByte = currentKeyBytes[i] ^ 0xff;
                                    [flippedKey appendBytes:&xorByte length:1];
                                }
                                OWSAssert(flippedKey.length == currentKey.length);
                                [identityManager saveRemoteIdentity:flippedKey recipientId:recipientId];
                            }],
            [OWSTableItem itemWithTitle:@"Delete all sessions"
                            actionBlock:^{
                                [TSStorageManager.sharedManager.newDatabaseConnection
                                    readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                                        [[TSStorageManager sharedManager]
                                            deleteAllSessionsForContact:thread.contactIdentifier
                                                        protocolContext:transaction];
                                    }];
                            }],
            [OWSTableItem itemWithTitle:@"Archive all sessions"
                            actionBlock:^{
                                [TSStorageManager.sharedManager.newDatabaseConnection
                                    readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                                        [[TSStorageManager sharedManager]
                                            archiveAllSessionsForContact:thread.contactIdentifier
                                                         protocolContext:transaction];
                                    }];
                            }],
            [OWSTableItem itemWithTitle:@"Send session reset"
                            actionBlock:^{
                                [OWSSessionResetJob runWithContactThread:thread
                                                           messageSender:[Environment current].messageSender
                                                          storageManager:[TSStorageManager sharedManager]];
                            }],
        ]];
    }

#if DEBUG
    [items addObjectsFromArray:@[
        [OWSTableItem itemWithTitle:@"Clear Session and Identity Store"
                        actionBlock:^{
                            [DebugUISessionState clearSessionAndIdentityStore];
                        }],
        [OWSTableItem itemWithTitle:@"Snapshot Session and Identity Store"
                        actionBlock:^{
                            [DebugUISessionState snapshotSessionAndIdentityStore];
                        }],
        [OWSTableItem itemWithTitle:@"Restore Session and Identity Store"
                        actionBlock:^{
                            [DebugUISessionState restoreSessionAndIdentityStore];
                        }]
    ]];
#endif

    return [OWSTableSection sectionWithTitle:self.name items:items];
}

#if DEBUG
+ (void)clearSessionAndIdentityStore
{
    [TSStorageManager.sharedManager.newDatabaseConnection
        readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [[TSStorageManager sharedManager] resetSessionStore:transaction];
            [[OWSIdentityManager sharedManager] clearIdentityState:transaction];
        }];
}

+ (void)snapshotSessionAndIdentityStore
{
    [TSStorageManager.sharedManager.newDatabaseConnection
        readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [[TSStorageManager sharedManager] snapshotSessionStore:transaction];
            [[OWSIdentityManager sharedManager] snapshotIdentityState:transaction];
        }];
}

+ (void)restoreSessionAndIdentityStore
{
    [TSStorageManager.sharedManager.newDatabaseConnection
        readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [[TSStorageManager sharedManager] restoreSessionStore:transaction];
            [[OWSIdentityManager sharedManager] restoreIdentityState:transaction];
        }];
}
#endif

@end

NS_ASSUME_NONNULL_END
