

#import "TMWebRequestDelegate.h"
#import "TMWebConstants.h"
#import "TMConstants.h"
#import "TMParsingUtility.h"


#define kBatchCount 30
@interface TMWebRequestDelegate ()
@property(nonatomic,strong)NSOperationQueue *operationQueue;
@property(nonatomic,strong)NSMutableSet *operationSet;
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
@end
@implementation TMWebRequestDelegate
@synthesize operationQueue,statusDelegate,operationSet,managedObjectContext;
-(id)initWithOperation:(NSOperationQueue*)queue withParentContext:(NSManagedObjectContext*)parentContext
{
  self = [super init];
  if (self) {
    NSAssert1(queue||parentContext, @"Operation queue or Parent context can not be nil %s",__func__);
    if (queue == nil) {
      return nil;
    }
    else
    {
      operationQueue = queue;
      operationSet = [[NSMutableSet alloc]init];
      managedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
      [managedObjectContext setParentContext:parentContext];
    }
    
  }
  return self;
}

-(id)init
{
  return [self initWithOperation:nil withParentContext:nil];
}

-(void)addWebOperation:(TMReviewFetchOperation*)webOperation
{
  NSAssert1(statusDelegate,@"statusDelegate can not be nil %s" , __func__);
  
  BOOL isRedundant = [operationSet containsObject:webOperation];
  [operationSet addObject:webOperation];
  if (isRedundant == NO) {
    
    [webOperation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
    [operationQueue addOperation:webOperation];
    [self.statusDelegate delegate:self didOperationStart:webOperation];
    
  }
  else
    
  {
    ALog(@"The Operation is already added %lu",(unsigned long)webOperation)
  }
  
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
  
  
  TMReviewFetchOperation *tempoperation = operation;
  
  NSError *error = nil;
  
  
    TMWebOperationResponse *webServiceResponse = tempoperation.webResponse;
    
    [self handleReviewsResponse:webServiceResponse withOperation:tempoperation withError:&error];
    if (error) {
      
      DLog(@"error %@\n %@",[error localizedDescription],[error userInfo]);
      // NSAssert2(NO, @"Error with Parsing %@\n%s", [error userInfo],__func__);
      tempoperation.webResponse.responseType = TMWebAPIResponseSuccessWithNoData;
      
      
    }
    
    
  
  
  
  
  @try{
    [tempoperation removeObserver:self forKeyPath:@"isFinished"];
  }
  @catch(id anException){
    //do nothing, obviously it wasn't attached because an exception was thrown
  }
  [self.operationSet removeObject:tempoperation];
  if(tempoperation.webResponse.responseType == TMWebAPIResponseFail)
  {
    [self.statusDelegate delegate:self didFailWithResponse:tempoperation.webResponse  forOperation:tempoperation];
  }
  else if(tempoperation.webResponse.responseType == TMWebAPIResponseSuccessWithData)
  {
    [self.statusDelegate delegate:self didSucceedWithDataResponse:tempoperation.webResponse  forOperation:tempoperation];
  }
  else
  {
    [self.statusDelegate delegate:self didSucceedWithWithoutDataResponse:tempoperation.webResponse  forOperation:tempoperation];
  }
  
  
  
}


#ifdef IMPROVED_VERSION_OF_PARSING
-(void)handleReviewsResponse:(TMWebOperationResponse*)webServiceResponse withOperation:(TMWebOperation*)operation withError:(NSError**)error
{
  
  if (A3WebAPIResponseSuccessWithData == webServiceResponse.responseType) {
    
    NSArray *reviewList =  (NSArray*)webServiceResponse.responseObject;
    
    if (YES == [statusDelegate respondsToSelector:@selector(delegate:numberOfReviewsReceived:forOperation:)] )
    {
      [statusDelegate delegate:self numberOfReviewsReceived:reviewList.count forOperation:operation];
    }
    
    TMParsingUtility *parsingUtility =  [[TMParsingUtility alloc]initWithManagedObjectContext:self.managedObjectContext];
    NSInteger countForEachBatch = kBatchCount;
    countForEachBatch = reviewList.count;
    NSInteger remainingItems = (reviewList.count%countForEachBatch);
    
    NSInteger totalBatches = (reviewList.count/countForEachBatch) ;
    
    NSInteger currentBatchIndex = 0;
    
    @autoreleasepool {
#warning have not followed DRY.
      for (; currentBatchIndex < totalBatches ; currentBatchIndex++)
      {
        NSRange currentRange;
        currentRange.location = countForEachBatch*currentBatchIndex;
        currentRange.length = countForEachBatch;
        NSArray *currentList = [reviewList subarrayWithRange:currentRange];
        
        NSSet *reviewSet =  [parsingUtility parseAndStoreReviewList:currentList withError:error];
        [self.managedObjectContext save:error];
        [statusDelegate delegate:self didParseASetOfDataFromResponse:webServiceResponse forOperation:operation];
      }
      
      if (remainingItems > 0) {
        
        
        NSRange currentRange;
        currentRange.location = countForEachBatch*currentBatchIndex;
        currentRange.length = remainingItems;
        NSArray *currentList = [reviewList subarrayWithRange:currentRange];
        
        NSSet *reviewSet =  [parsingUtility parseAndStoreReviewList:currentList withError:error];
        [self.managedObjectContext save:error];
        [statusDelegate delegate:self didParseASetOfDataFromResponse:webServiceResponse forOperation:operation];
      }
      
    }
    [self.managedObjectContext reset];
    webServiceResponse.responseObject = nil;
    [statusDelegate delegate:self didParseAllSetOfDataFromResponse:webServiceResponse forOperation:operation];
    
    
    
  }
  
  
  
  
}
#else

-(BOOL)handleReviewsResponse:(TMWebOperationResponse*)webServiceResponse withOperation:(TMReviewFetchOperation*)operation withError:(NSError**)error
{
  
  if (TMWebAPIResponseSuccessWithData == webServiceResponse.responseType) {
    
    NSArray *reviewList =  (NSArray*)webServiceResponse.responseObject;
    
    if (YES == [statusDelegate respondsToSelector:@selector(delegate:numberOfReviewsReceived:forOperation:)] )
    {
      [statusDelegate delegate:self numberOfReviewsReceived:reviewList.count forOperation:operation];
    }
    
    TMParsingUtility *parsingUtility =  [[TMParsingUtility alloc]initWithManagedObjectContext:self.managedObjectContext];
    
    
    @autoreleasepool {
      
      NSSet *reviewSet =  [parsingUtility parseAndStoreReviewList:reviewList  withError:error];
     
    
      TMFilterRequest *filterRequest = (TMFilterRequest*) [managedObjectContext objectWithID:operation.filterRequestUniqueID];
      filterRequest.hasReviews = reviewSet;
      NSAssert1(filterRequest, @"TMFilterRequest  can not be nil %s", __func__);

     BOOL operationSuccess = [self.managedObjectContext.parentContext save:error];
      if (operationSuccess == NO) {
        return operationSuccess;
        DLog(@"error %@]\nLocalized Info %@",[(*error) userInfo],[(*error) localizedDescription])
        abort();
      }
      [self.managedObjectContext save:error];
      
      if (operationSuccess == NO) {
        return operationSuccess;
        DLog(@"error %@]\nLocalized Info %@",[(*error) userInfo],[(*error) localizedDescription])
        abort();
      }
    }
    [self.managedObjectContext reset];
    webServiceResponse.responseObject = nil;
    
    if ([statusDelegate respondsToSelector:@selector(delegate:didParseAllSetOfDataFromResponse:forOperation:)]) {
      [statusDelegate delegate:self didParseAllSetOfDataFromResponse:webServiceResponse forOperation:operation];
    }
    
    
    
    
  }
  
  return TRUE;
  
  
}

#endif

@end
