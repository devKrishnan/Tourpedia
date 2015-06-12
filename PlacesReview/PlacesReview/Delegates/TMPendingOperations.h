

#import <Foundation/Foundation.h>

@interface TMPendingOperations : NSObject
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end
