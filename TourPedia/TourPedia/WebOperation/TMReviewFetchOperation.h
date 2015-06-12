

#import <Foundation/Foundation.h>
#import "TMWebOperationResponse.h"
#import <CoreData/CoreData.h>





@interface TMReviewFetchOperation : NSOperation<NSURLSessionDelegate>
@property(nonatomic)NSObject *objectToSend;
@property(nonatomic,strong)TMWebOperationResponse *webResponse;
@property(nonatomic)NSManagedObjectID *filterRequestUniqueID;
@end
