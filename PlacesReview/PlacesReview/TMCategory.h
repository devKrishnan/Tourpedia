//
//  TMCategory.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TMFilterRequest;

@interface TMCategory : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *partOfFilterRequests;
@end

@interface TMCategory (CoreDataGeneratedAccessors)

- (void)addPartOfFilterRequestsObject:(TMFilterRequest *)value;
- (void)removePartOfFilterRequestsObject:(TMFilterRequest *)value;
- (void)addPartOfFilterRequests:(NSSet *)values;
- (void)removePartOfFilterRequests:(NSSet *)values;

@end
