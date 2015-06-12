

#import <Foundation/Foundation.h>
#import "TMReviewFetchOperation.h"
#import "TMWebOperationResponse.h"
#import <CoreData/CoreData.h>

@class TMWebRequestDelegate;

@protocol TMWebOperationStatusDelegate <NSObject>


-(void)delegate:(TMWebRequestDelegate*)delegate didFailWithResponse:(TMWebOperationResponse*)webResponse forOperation:(TMReviewFetchOperation*)webOperation;
-(void)delegate:(TMWebRequestDelegate*)delegate didSucceedWithDataResponse:(TMWebOperationResponse*)webResponse forOperation:(TMReviewFetchOperation*)webOperation;
-(void)delegate:(TMWebRequestDelegate*)delegate didSucceedWithWithoutDataResponse:(TMWebOperationResponse*)webResponse forOperation:(TMReviewFetchOperation*)webOperation;



@optional
-(void)delegate:(TMWebRequestDelegate*)delegate numberOfReviewsReceived:(NSUInteger)reviewCount forOperation:(TMReviewFetchOperation*)webOperation;
-(void)delegate:(TMWebRequestDelegate*)delegate didParseASetOfDataFromResponse:(TMWebOperationResponse*)webResponse forOperation:(TMReviewFetchOperation*)webOperation;
-(void)delegate:(TMWebRequestDelegate*)delegate didParseAllSetOfDataFromResponse:(TMWebOperationResponse*)webResponse forOperation:(TMReviewFetchOperation*)webOperation;
@optional
-(void)delegate:(TMWebRequestDelegate*)delegate didOperationStart:(TMReviewFetchOperation*)webOperation;


@end

@interface TMWebRequestDelegate : NSObject
@property(nonatomic,weak)id<TMWebOperationStatusDelegate> statusDelegate;
-(void)addWebOperation:(TMReviewFetchOperation*)webOperation;
-(id)initWithOperation:(NSOperationQueue*)queue withParentContext:(NSManagedObjectContext*)parentContext;

@end
