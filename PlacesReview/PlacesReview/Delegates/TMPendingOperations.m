

#import "TMPendingOperations.h"

@implementation TMPendingOperations
@synthesize downloadQueue,downloadsInProgress;
- (NSMutableDictionary *)downloadsInProgress {
  if (!downloadsInProgress) {
    downloadsInProgress = [[NSMutableDictionary alloc] init];
  }
  return downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
  if (!downloadQueue) {
    downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"Review More info Queue";
    downloadQueue.maxConcurrentOperationCount = 1;
  }
  return downloadQueue;
}
@end
