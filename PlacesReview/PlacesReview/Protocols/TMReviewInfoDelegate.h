//
//  TMSelectedReviewInfo.h
//  PlacesReview
//
//  Created by devKrishnan on 10/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol TMReviewInfoDelegate <NSObject>
-(void)openDetailsReviewControllerForReviewWithManagedObjectID:(NSManagedObjectID*)reviewObjectID;
@end
