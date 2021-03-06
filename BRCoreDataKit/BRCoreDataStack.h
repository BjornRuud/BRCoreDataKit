//
//  BRCoreDataStack.h
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 04.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import <CoreData/CoreData.h>

FOUNDATION_EXPORT NSString * const BRCoreDataStackErrorDomain;
FOUNDATION_EXPORT NSString * const BRCoreDataStackInitializedNotification;

@interface BRCoreDataStack : NSObject

@property (nonatomic, readonly) BOOL isInitialized;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, readonly) NSManagedObjectContext *privateQueueContext;

+ (BRCoreDataStack *)defaultStack;
+ (void)setDefaultStack:(BRCoreDataStack *)stack;

- (instancetype)initWithModelURL:(NSURL *)modelURL
                        storeURL:(NSURL *)storeURL
                       storeType:(NSString *)storeType
                      completion:(void (^)(NSError *error))completion;

// Convenience init with single base name for model and store
- (instancetype)initWithName:(NSString *)name
                  completion:(void (^)(NSError *error))completion;

- (NSManagedObjectContext *)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

@end
