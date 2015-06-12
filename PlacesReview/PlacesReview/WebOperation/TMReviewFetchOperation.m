

#import "TMReviewFetchOperation.h"
#import "TMConstants.h"
#import "TMWebConstants.h"
#import "PDKeychainBindings.h"
#import "NSDictionary+Verified.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



typedef    void (^WebServiceCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error);


//http://tour-pedia.org/api
//static NSString * const  relativeURLOfReviews = @"/getReviews?location=London&category=attraction&language=en";

//static NSString * const  relativeURLOfReviews = @"/getReviews?location=London&category=attraction&category=restaurant&language=en";
static NSString * const  relativeURLOfReviews = @"/getReviews?";









@interface TMReviewFetchOperation()
@property(nonatomic,strong)NSURLRequest *webRequest;

@end

@implementation TMReviewFetchOperation
@synthesize executing,finished;
@synthesize objectToSend;



- (id)init{
    self = [super init];
    if (self) {
        
 
        executing = NO;
        finished = NO;

       
        
                
    }
    return self;
}


- (void)start {
    
    // Ensure this operation is not being restarted and that it has not been cancelled
    //if( [self finished] || [self isCancelled] ) { [self done]; return; }
    if ([self isCancelled]) {
        
        //[self willChangeValueForKey:@"isFinished"];
        // finished = YES;
        // [self didChangeValueForKey:@"isFinished"];
        return;
    }
    @autoreleasepool {
        
    
        NSString *urlString  = nil;
        [self willChangeValueForKey:@"isExecuting"];
       
        PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
        NSString *baseServerIPURL = [bindings objectForKey:configDetailsBASEURLKey];

        urlString = [NSString stringWithFormat:@"%@%@%@",baseServerIPURL, relativeURLOfReviews,objectToSend];
        [self fetchReviewsWithURLString:urlString];
              
        NSAssert1(self.filterRequestUniqueID, @"filterRequestUniqueID is mandatory %s", __func__);
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        if ([self isCancelled])
            return;

    }
   
 
    
}

-(void)fetchReviewsWithURLString:(NSString*)urlString
{
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest  *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    
    
    WebServiceCompletionBlock completionBlock = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
#ifdef LOGTIMEOFSERVER
        ALog(@"Request Completed %@",[NSDate date])
#endif
        
        NSHTTPURLResponse *httpResponse =(NSHTTPURLResponse*) response;
     
        TMWebOperationResponse *serviceResponse = [[TMWebOperationResponse alloc]init];
        if(data.length > 0)
        {
            NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            //success
#ifdef DEBUG
            
            NSString *name = @"Reviews.json";
            [self storeContents:string withName:name shouldAppend:NO];
#endif
            NSArray *JSONList =
            [NSJSONSerialization JSONObjectWithData: [string dataUsingEncoding:NSUTF8StringEncoding]
                                            options: NSJSONReadingMutableContainers
                                              error: &error];
            
            
            
            if ([JSONList  isKindOfClass:[NSArray class]]) {
                
                if (JSONList.count > 0) {
                    
                    serviceResponse.responseType = TMWebAPIResponseSuccessWithData;
                    serviceResponse.responseObject = JSONList;

                }
                else
                {
                    serviceResponse.responseType = TMWebAPIResponseSuccessWithNoData;
                    serviceResponse.errorMessage = NSLocalizedString(@"ReviewsNotAvailable", "");

                }
                
                
                self.webResponse = serviceResponse;
                
            }
            else
            {
                self.webResponse =[self webResponseFromHttpResponse:httpResponse];
                
                
                
            }
            
            
            
        }
        else
        {
            serviceResponse.responseType = TMWebAPIResponseFail;
            serviceResponse.errorMessage = [error localizedDescription];
            self.webResponse = serviceResponse;
        }
        [self requestFinished];
        
        
    };
    ;
    
    [self invokeWebServiceWithRequest:request CompletionHandler:completionBlock];
    return;
    
    
}



-(void)invokeWebServiceWithRequest:(NSURLRequest*)request CompletionHandler:(WebServiceCompletionBlock)completionHandler{
    
   

    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
   
    NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:request
                                                   completionHandler:completionHandler];

    
    [task resume];
    #ifdef LOGTIMEOFSERVER  
    ALog(@"Request began %@",[NSDate date])
    #endif

    
}

-(NSString*)storeContents:(NSString*)contentToWrite withName:(NSString*)fileName shouldAppend:(BOOL)shouldAppend
{
    
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get do
    
    NSError *fileLoadError;
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSString *contents;
    if (shouldAppend == YES) {
        
       contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (contents == nil) {
            
            contents = [[NSString alloc]init];
        }
        contents = [contents stringByAppendingString:contentToWrite];

    }
    else
    {
        contents = contentToWrite;
    }
    DLog(@"filePath %@",filePath)
    if ([contents length]>0) {
        BOOL succeed = [contents writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&fileLoadError];
        if (!succeed){
            
            ALog(@"Error with File \n %@",fileLoadError );
            return nil;
            // Handle error here
        }
        else
        {
            return  [documentsDirectory stringByAppendingPathComponent:fileName];
        }
        
    }
    
    return nil;


    
}


//It indicates the Request is done
-(void)requestFinished{
    
    if ([self isCancelled])
        return;
    
    [self willChangeValueForKey:@"isFinished"];
    
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
}







-(NSString*)jsonStringFromDictionary:(NSDictionary*)dictionary
{
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
    
}



-(TMWebOperationResponse*)webResponseFromHttpResponse:(NSHTTPURLResponse*)httpResponse
{
    TMWebOperationResponse *serviceResponse = [[TMWebOperationResponse alloc]init];

    if (httpResponse.statusCode == 200) {
        serviceResponse.responseType = TMWebAPIResponseSuccessWithNoData;
        serviceResponse.errorMessage = @"No data available from server";
    }
    else if (httpResponse.statusCode == 404)
    {
        serviceResponse.responseType = TMWebAPIResponseFail;
        serviceResponse.errorMessage = @"Some Problem with Webservices. Please contact Admin";
    }
    else
    {
        serviceResponse.responseType = TMWebAPIResponseFail;
        serviceResponse.errorMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
    }
    return serviceResponse;

}

@end
