//
//  BranchLogger.m
//  Branch
//
//  Created by Nipun Singh on 2/1/24.
//  Copyright © 2024 Branch, Inc. All rights reserved.
//

#import "BranchLogger.h"
#import <os/log.h>

@implementation BranchLogger

static BranchLogLevel _logLevelThreshold = BranchLogLevelDebug;

+ (instancetype)shared {
    static BranchLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BranchLogger alloc] init];
        sharedInstance.loggingEnabled = NO;
        sharedInstance.logLevelThreshold = BranchLogLevelDebug;
    });
    return sharedInstance;
}

- (void)logError:(NSString *)message error:(NSError *_Nullable)error {
    [self logMessage:message withLevel:BranchLogLevelError error:error];
}

- (void)logWarning:(NSString *)message {
    [self logMessage:message withLevel:BranchLogLevelWarning error:nil];
}

- (void)logInfo:(NSString *)message {
    [self logMessage:message withLevel:BranchLogLevelInfo error:nil];
}

- (void)logDebug:(NSString *)message {
    [self logMessage:message withLevel:BranchLogLevelDebug error:nil];
}

- (void)logVerbose:(NSString *)message {
    [self logMessage:message withLevel:BranchLogLevelVerbose error:nil];
}

- (void)logMessage:(NSString *)message withLevel:(BranchLogLevel)level error:(NSError *_Nullable)error {
    if (!self.loggingEnabled || message.length == 0 || level < self.logLevelThreshold) {
        return;
    }
    
    NSString *logLevelString = [self stringForLogLevel:level];
    NSString *logTag = [NSString stringWithFormat:@"[BranchSDK][%@]", logLevelString];
    NSMutableString *fullMessage = [NSMutableString stringWithFormat:@"%@ %@", logTag, message];
    
    if (error) {
        [fullMessage appendFormat:@", Error: %@ (Domain: %@, Code: %ld)", error.localizedDescription, error.domain, (long)error.code];
    }

    if (self.logCallback) {
        self.logCallback(fullMessage, level, error);
    } else {
        os_log_t log = os_log_create("io.branch.sdk", "BranchSDK");
        os_log_type_t osLogType = [self osLogTypeForBranchLogLevel:level];
        os_log_with_type(log, osLogType, "%{public}@", fullMessage);
    }
}

- (os_log_type_t)osLogTypeForBranchLogLevel:(BranchLogLevel)level {
    switch (level) {
        case BranchLogLevelError: return OS_LOG_TYPE_FAULT;
        case BranchLogLevelWarning: return OS_LOG_TYPE_ERROR;
        case BranchLogLevelInfo: return OS_LOG_TYPE_INFO;
        case BranchLogLevelDebug: return OS_LOG_TYPE_DEBUG;
        case BranchLogLevelVerbose: return OS_LOG_TYPE_DEFAULT;
        default: return OS_LOG_TYPE_DEFAULT;
    }
}

- (NSString *)stringForLogLevel:(BranchLogLevel)level {
    switch (level) {
        case BranchLogLevelVerbose: return @"Verbose";
        case BranchLogLevelDebug: return @"Debug";
        case BranchLogLevelInfo: return @"Info";
        case BranchLogLevelWarning: return @"Warning";
        case BranchLogLevelError: return @"Error";
        default: return @"Unknown";
    }
}

@end
