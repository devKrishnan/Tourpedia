

import UIKit

// TODO:  Performance IMprovement by using fetch Limit and batch size should be completed - NSFetchedResultsController - Done
//http://www.iosnomad.com/blog/2014/4/21/fluent-pagination
// TODO: Add filter floating icon - Done
// TODO: add dynamic search bar - Done
// TODO: add Pagination support - Not done
// TODO: Search - Anangram  - Done - Not yet tested
// TODO: Sort by time - Completed
// TODO: UI Effects https://github.com/ide/UIVisualEffects - Not done
// TODO: Cell Animation - Not done
// TODO: Delete Previous filter results when a new filter request is made - Done
// TODO: Unit tests for new features - Not done
// TODO: THe navigation bar right button - toolbar - frame is visible explicitly - Not done
// TODO: Fetch More info of the reviews - in background thread - Feature not neccessary
// TODO: Landscape orientation - toolbar and Filter icon is not aligned - No support for Landscape orientation
//http://stackoverflow.com/questions/6378125/auto-resize-height-of-uitoolbar-in-landscape-orientation
// TODO: Indexing in core data? - Not supported
// TODO: Detailed View Controller for more info on the Reviews - Done
// TODO: Rating of the review also has to be shown - Done
// TODO: Date of review - Not done
// TODO: Adaptive-Userinfterfaces- Landscape orientation - testing -http://www.learnswift.io/blog/2014/6/12/size-classes-with-xcode-6-and-swift
// TODO: For each unique fetch request, assign a unique ID to all its results, so  that it is easy to delete them when a new fetch request is made - Done

let reviewCellIdentifier = "ReviewCell"



enum SearchMode {
  case SearchAnagramMode
  case SearchFuzzyMode
}


class ViewController: UIViewController
{
  
  @IBOutlet weak var filterButton: UIButton!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var reviewTableView: UITableView!
  var refreshButtonItem : UIBarButtonItem?
  var notification: JSNotifier?
  var navigationRightButton : UIBarButtonItem?
  lazy var searchResultsLabel : UILabel =
  {
    var screenBounds = JSScreenBounds()
    //var top = screenBounds.size.height-;
    var width = screenBounds.size.width as CGFloat
    var height :CGFloat = 40
    var totalSearchResultLabel = UILabel(frame: CGRectMake(0, 500, width,height))
    totalSearchResultLabel.backgroundColor = UIColor.redColor()
    return totalSearchResultLabel
    }()
  lazy var titleLabel :UILabel =
  {
    var screenBounds = JSScreenBounds()
    var titleLabel : UILabel = UILabel(frame: CGRectMake(0, 0, screenBounds.size.width/3, 60))
    titleLabel.textAlignment = NSTextAlignment.Center
    titleLabel.text = "Tour Pedia"
    titleLabel.textColor = UIColor.whiteColor()
    titleLabel.font = UIFont(name: "GillSans", size: 30)
    titleLabel.adjustsFontSizeToFitWidth = true
    return titleLabel
    }()
  lazy var searchBar : UISearchBar = {
    
    assert(self.reviewTableView != nil, "Review table view should be set")
    var tempSearchBar = UISearchBar()
    tempSearchBar.showsCancelButton = true;
    tempSearchBar.tintColor = UIColor.whiteColor()
    tempSearchBar.delegate = self
    return tempSearchBar
    
    }()
  
  var searchViewController : UISearchController?
  var fetchedResultsController:NSFetchedResultsController?
  //http://useyourloaf.com/blog/2015/02/16/updating-to-the-ios-8-search-controller.html
  
  
  lazy var searchDelegate : TMSearchResultsDelegate =
  {
    var tempSearchDelegate = TMSearchResultsDelegate()
    tempSearchDelegate.delegate = self
    return tempSearchDelegate
    
    }()
  var activeFilterRequest : TMFilterRequest?
  var listOfCategories : NSArray?
  var listOfPlaces : NSArray?
  var reviewList : NSArray?
  var isReviewsSortedByDateWithLatestAtTop: Bool?
  var isSearchTriggeredForReviewsInSqlite : Bool?
  lazy var searchMode : SearchMode = {
    
    return SearchMode.SearchAnagramMode
    
    }()
  
  var managedObjectContext : NSManagedObjectContext?
  var coreDataUtility : TMCoreDataUtility?
  var webRequestDelegate: TMWebRequestDelegate?
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    initializationOfGeneralItems()
    initializeFetchResultsController()
    initializeNavigationBar()
    initializeSearchController()
    self.reviewTableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier:reviewCellIdentifier )
    logReviewInfo()
    doLocalFetch()
    print(filterButton)
    self.view.bringSubviewToFront(filterButton)
    var reviewCount : Int! = fetchedResultsController?.fetchedObjects?.count
    var reviewsAvailbleMessage =  NSLocalizedString("CountReviewsAvailable", comment: "")
    var totalCountMessage = "\(reviewCount) \(reviewsAvailbleMessage)"
    self.showMessage(totalCountMessage, time: 10.0);
    
    //fetchReviews("",placeName: "")
    
    // Do any additional setup after loading the view, typically from a nib.
  }
  func initializationOfGeneralItems()
  {
    var objectID:NSManagedObjectID? = TMUtilities.objectIDOfLastFilterRequestForManagedObjectContext(managedObjectContext)
    if objectID != nil
    {
      activeFilterRequest = managedObjectContext?.objectWithID(objectID!) as? TMFilterRequest
    }
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    webRequestDelegate = TMWebRequestDelegate(operation:  appDelegate.webRequestQueue, withParentContext: managedObjectContext)
    webRequestDelegate?.statusDelegate = self;
    
    self.notification = JSNotifier()
    coreDataUtility = TMCoreDataUtility(managedContext: managedObjectContext)
    
    isReviewsSortedByDateWithLatestAtTop = true
    self.reviewTableView.contentInset = UIEdgeInsetsZero
    self.automaticallyAdjustsScrollViewInsets = true;
    self.isSearchTriggeredForReviewsInSqlite = false
    
  }
  func initializeFetchResultsController()
  {
    var objectIDDescription = NSExpressionDescription()
    objectIDDescription.name = "objectID"
    objectIDDescription.expression = NSExpression.expressionForEvaluatedObject()
    objectIDDescription.expressionResultType = NSAttributeType.ObjectIDAttributeType
    
    var sortDescriptors = [NSSortDescriptor(key: "time", ascending: isReviewsSortedByDateWithLatestAtTop!)]
    var fetchRequest : NSFetchRequest = NSFetchRequest(entityName: NSStringFromClass(TMReview.self))
    //fetchRequest.predicate
    fetchRequest.sortDescriptors = sortDescriptors
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    
    fetchedResultsController?.fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType;
    fetchedResultsController?.fetchRequest.propertiesToFetch = ["text","detailsURL",objectIDDescription]
    
    //http://stackoverflow.com/questions/17591616/nsexpression-respect-a-subquery-nspredicate
    var expressionSelf : NSExpression = NSExpression(forConstantValue: self)
    
    
    //fetchedResultsController?.fetchRequest.predicate = predicate
    //  [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"createdAt"]];
  }
  
  func logReviewInfo()
  {
    
    //var reviewList = coreDataUtility?.allEntitiesOfTMReviewWithSearchText("INfo")
    var reviewList = coreDataUtility?.allEntitiesOfClass(TMReview.self)
    print("Total Reviews\n")
    println(reviewList?.count)
  }
  
  func initializeSearchController()
  {
    
    
    
  }
  func initializeNavigationBar()
  {
    
    
    self.navigationItem.titleView = titleLabel
    self.navigationController?.navigationBar.barTintColor = UIColor(rgba: kAppnavigationBarGlobalColor)
    self.navigationController?.navigationBar.translucent = true
    var filterImage = UIImage(named: "filter")
    filterImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    filterButton.setImage(filterImage, forState: UIControlState.Normal)
    filterButton.tintColor = UIColor(rgba: kAppnavigationBarGlobalColor)
    var rightToolBar = UIToolbar(frame: CGRectMake(0, 10, 120, 32));
    rightToolBar.barTintColor = UIColor(rgba: kAppnavigationBarGlobalColor)
    
    // rightToolBar.backgroundColor = UIColor.clearColor()
    var rightBarSearchButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: Selector("searchReviewList:"))
    rightBarSearchButtonItem.tintColor = UIColor.whiteColor()
    var rightBarSortButtonItem = UIBarButtonItem(image: UIImage(named: "sort"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sortReviewList:"))
    rightBarSortButtonItem.tintColor = UIColor.whiteColor()
    rightToolBar.setItems([rightBarSearchButtonItem,rightBarSortButtonItem], animated: true)
    self.refreshButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action:Selector("refreshReviewList:"))
    self.navigationItem.leftBarButtonItem = refreshButtonItem
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    ;
    self.navigationRightButton =  UIBarButtonItem(customView: rightToolBar)
    self.navigationItem.rightBarButtonItem = navigationRightButton
    // self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    
  }
  func fetchReviews()
  {
    
    
    if(listOfPlaces?.count <= 0 || listOfCategories?.count <= 0)
    {
      
      
      var message: String = NSLocalizedString("ChooseCategoryPlace", comment: "")
      self.showMessage(message, time: 3.0)
      var dispatchBlock : dispatch_block_t = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) { // 3
        
        self.openFilterScreen(self.filterButton)
      }
      dispatch_after_delay(1, queue: dispatch_get_main_queue(), block: dispatchBlock)
      
      
      
      
      
    }
    else
    {
      if (activeFilterRequest != nil)
      {
        deleteCurrentFilterRequestAndReviews()
      }
      
      
      //Reset the search each time a new filter is chosen
      self.isSearchTriggeredForReviewsInSqlite = false
      var reviewOperation: TMReviewFetchOperation = TMReviewFetchOperation()
      var urlToRequestForServices = urlFromCurrentFilter()
      var uniqueFetchRequestID = TMUtilities.uniqueIDForObject(urlToRequestForServices)
      reviewOperation.objectToSend = urlToRequestForServices
      
      
      var predicate = NSPredicate(format: "uniqueHashID == %@",uniqueFetchRequestID )
      var  tempFilterRequest = coreDataUtility?.itemWithPredicate(predicate, withEntityType: TMFilterRequest.self) as? TMFilterRequest
      
      
      if(tempFilterRequest?.uniqueHashID != uniqueFetchRequestID)
      {
        var parsingUtility : TMParsingUtility?
        parsingUtility = TMParsingUtility(managedObjectContext: self.managedObjectContext)
        
        var error: NSError?
        if(false == parsingUtility!.insertFetchRequestWithUniqueID(uniqueFetchRequestID, withError: &error))
        {
          println("Problem with persisting the information \(error)")
          abort()
        }
        self.managedObjectContext?.save(&error)
        tempFilterRequest = coreDataUtility?.itemWithPredicate(predicate, withEntityType: TMFilterRequest.self) as? TMFilterRequest
        activeFilterRequest = tempFilterRequest
        println(activeFilterRequest?.uniqueHashID)
        
      }
      else
      {
        activeFilterRequest = tempFilterRequest
        //coreDataUtility?.coreDataDeleteAllFromEntityName(<#entityName: String!#>)
        deleteCurrentFilterRequestAndReviews()
        //assert(false, "THis case is not possible")
      }
 
      
      TMUtilities.setFilterRequest(activeFilterRequest?.objectID)
      
      
      reviewOperation.filterRequestUniqueID = activeFilterRequest?.objectID
      webRequestDelegate!.addWebOperation(reviewOperation)
    }
    
  }
  override func didReceiveMemoryWarning() {
    
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func refreshReviewList(barButtonItem: UIBarButtonItem)
  {
    removeSearchBar()
    fetchReviews();
  }
  func searchReviewList(barButtonItem: UIBarButtonItem)
  {
    self.isSearchTriggeredForReviewsInSqlite = true
    UIView.animateWithDuration(0.2, animations: {
      
      self.titleLabel.alpha = 1.0
      self.navigationRightButton?.enabled = false
      
      }, completion: {
        (value: Bool) in
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.titleView = self.searchBar
        
        UIView.animateWithDuration(0.5, animations: {
          
          self.searchBar.alpha = 1.0
          }, completion: {
            (value: Bool) in
            
            self.searchBar.becomeFirstResponder()
            self.reviewTableView.dataSource = self.searchDelegate
            self.reviewTableView.delegate = self.searchDelegate
        })
        
    })
    
  }
  func sortReviewList(barButtonItem: UIBarButtonItem)
  {
    if   true == isReviewsSortedByDateWithLatestAtTop
      
    {
      isReviewsSortedByDateWithLatestAtTop = false
    }
    else
    {
      isReviewsSortedByDateWithLatestAtTop = true
    }
    
    doLocalFetch()
    
    self.reviewTableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
  }
  
  // MARK: - Others
  //http://stackoverflow.com/questions/24085140/nsdictionaryofvariablebindings-swift-equivalent
  func dictionaryOfNames(arr:UIView...) -> Dictionary<String,UIView> {
    var d = Dictionary<String,UIView>()
    for (ix,v) in enumerate(arr) {
      d["v\(ix+1)"] = v
    }
    return d
  }
  
  func deleteCurrentFilterRequestAndReviews()
  {
    
    var error: NSError?
  println("Filter Request to be deleted \(activeFilterRequest?.uniqueHashID) \(activeFilterRequest) ")
    
    println("ObjectID \(activeFilterRequest!.objectID)")
    var hashIDToDelete = activeFilterRequest?.uniqueHashID;
    if(hashIDToDelete == nil)
    {
     activeFilterRequest =  managedObjectContext?.objectWithID(activeFilterRequest!.objectID) as? TMFilterRequest
      hashIDToDelete = activeFilterRequest?.uniqueHashID;
    }
    // let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    //dispatch_async(dispatch_get_global_queue(priority, 0)) {
      
      var predicate = NSPredicate(format: "ANY reviewsForRequest.uniqueHashID == %@", hashIDToDelete!)
      self.coreDataUtility?.coreDataDeleteAllFromEntityName(NSStringFromClass(TMReview.self), withPredicate: predicate)
      self.activeFilterRequest?.removeHasReviews(self.activeFilterRequest?.hasReviews)
      //self.managedObjectContext?.deleteObject(activeFilterRequest!)
      var saveOperationStatus  = self.managedObjectContext?.save(&error)
      if false == saveOperationStatus
      {
        println("Delete operation failed \(error)")
        abort()
      }
      println("Filter Request to be deleted \(self.activeFilterRequest?.uniqueHashID) \(self.activeFilterRequest) \(self.activeFilterRequest!.objectID)")
      
    // dispatch_async(dispatch_get_main_queue()) {
  
    // }
      
    //}
    
   
    
  }
  // Nice helper function for dispatch_after
  func dispatch_after_delay(delay: NSTimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, queue, block)
  }
  
  @IBAction func openFilterScreen(sender: AnyObject) {
    
    
    var filterViewController  = TMFilterViewController(selectedCatList: listOfCategories as? Array<String>, selectedLocList: listOfPlaces as? Array<String>) as TMFilterViewController
    filterViewController.filterDelegate = self
    //filterViewController.formController.form = filterFormInfo
    
    var navigationController = UINavigationController(rootViewController: filterViewController)
    
    self.presentViewController(navigationController, animated: true, completion: nil)
    
    
  }
  
  
  func saveParentContext()
  {
    var error : NSError?
    self.managedObjectContext?.save(&error)
    self.managedObjectContext?.reset()
  }
}

// MARK: - TMWebOperationStatusDelegate
extension ViewController: TMWebOperationStatusDelegate,UISearchResultsUpdating,UISearchBarDelegate  {
  
  func delegate(delegate: TMWebRequestDelegate!, didOperationStart webOperation: TMReviewFetchOperation!) {
    self.view.showActivityViewWithLabel("Loading Reviews");
    
    var message: String = NSLocalizedString("ReviewLoadBegan", comment: "")
    self.showMessage(message, time: 100)
    refreshButtonItem?.enabled = false
    
    println("Operation started")
  }
  func delegate(delegate: TMWebRequestDelegate!, didFailWithResponse webResponse: TMWebOperationResponse!, forOperation webOperation: TMReviewFetchOperation!) {
    self.view.hideActivityView()
    saveParentContext()
    refreshButtonItem?.enabled = true
    var message: String = NSLocalizedString("ReviewLoadFailed", comment: "")
    self.showMessage(message, time: 100)
    println("Failed")
    
  }
  
  func delegate(delegate: TMWebRequestDelegate!, didSucceedWithDataResponse webResponse: TMWebOperationResponse!, forOperation webOperation: TMReviewFetchOperation!) {
    self.view.hideActivityView()
    saveParentContext()
    var message: String = NSLocalizedString("ReviewLoadEnd", comment: "")
    
    refreshButtonItem?.enabled = true
    
    doLocalFetch()
    println("success with data")
    logReviewInfo()
    
  }
  
  func delegate(delegate: TMWebRequestDelegate!, didSucceedWithWithoutDataResponse webResponse: TMWebOperationResponse!, forOperation webOperation: TMReviewFetchOperation!) {
    
    self.view.hideActivityView()
    saveParentContext()
    refreshButtonItem?.enabled = true
    
    println("success without data")
    logReviewInfo()
  }
  
  func delegate(delegate: TMWebRequestDelegate!, numberOfReviewsReceived reviewCount: UInt, forOperation webOperation: TMReviewFetchOperation!) {
    
    
    
    println(self.notification)
    dispatch_async(dispatch_get_main_queue(),{
      
      var reviewsAvailbleMessage =  NSLocalizedString("CountReviewsAvailable", comment: "")
      var totalCountMessage = "\(reviewCount) \(reviewsAvailbleMessage)"
      self.showMessage(totalCountMessage, time: 10.0);
      
      
    })
    
    
  }
  
  
  // MARK: - UISearchResultsUpdating
  func updateSearchResultsForSearchController(searchController: UISearchController)
  {
    
  }
  
  func showMessage(message: String, time:float_t)
  {
    notification?.hide()
    self.notification = nil
    notification = JSNotifier(title: message)
    notification?.showFor(time)
  }
  
  func doLocalFetch()
  {
    var sortDescriptors = [NSSortDescriptor(key: "time", ascending: isReviewsSortedByDateWithLatestAtTop!)]
    
    if(isSearchTriggeredForReviewsInSqlite == true && count(searchBar.text) > 0)
    {
      
      //var predicate : NSPredicate = NSPredicate(format: "ANY text CONTAINS[cd] %@",searchBar.text) as NSPredicate
      //NSFetchedResultsController.deleteCacheWithName("ReviewList")
      
      var predicate : NSPredicate = NSPredicate(block: { (celInfo:AnyObject!,  [NSObject : AnyObject]!) -> Bool in
        
        var reviewDictionary: AnyObject! = celInfo;
        
        println("predicate.predicateFormat \(reviewDictionary)")
        return false
      })
      //predicate  = NSPredicate(format: "ANY text CONTAINS[cd] %@",searchBar.text) as NSPredicate
      // predicate = NSPredicate(format: "FUNCTION(self,'filteredResultsForAnagramSearch',nil)")
      //fetchedResultsController?.fetchRequest.predicate = predicate
      println("predicate.predicateFormat \(predicate.predicateFormat)")
    }
    fetchedResultsController?.fetchRequest.sortDescriptors = sortDescriptors
    var error : NSError?
    var didFetchResults = fetchedResultsController?.performFetch(&error)
    if(false == didFetchResults)
    {
      println(error?.userInfo)
      abort()
    }
    
    
    
    if(isSearchTriggeredForReviewsInSqlite == true)
    {
      if (activeFilterRequest == nil)
      {
        //var message: String =   NSLocalizedString("NoFilterExists", comment: "")
        //self.showMessage(message, time: 3.0)
        // return
        
      }
      if(count(searchBar.text ) <= 0  )
      {
        self.showMessage( NSLocalizedString("SearchTextEmpty", comment: ""), time: 10)
        
      }
      else
      {
        self.view.showActivityViewWithLabel("Searching...")
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
          
          var listOfFilteredObjects : Array<NSDictionary>  = []
          self.navigationItem.leftBarButtonItem?.enabled = false
          autoreleasepool()
            {
              listOfFilteredObjects =  self.filteredResultsForAnagramSearch()
          }
          
          
          dispatch_async(dispatch_get_main_queue()) {
            
            
            var message: String =   NSLocalizedString("SearchCountReviewsAvailable", comment: "")
            var searchResultCount : Int = (listOfFilteredObjects.count as Int?)!
            
            
            var totalSearchCountMessage = "\(searchResultCount) \(message)"
            
            self.showMessage(totalSearchCountMessage, time: 3.0)
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.searchDelegate.searchResults = listOfFilteredObjects
            self.reviewTableView.reloadData()
            self.view.hideActivityView()
            
            // update some UI
            println("Anagram Search Results \(listOfFilteredObjects.count)")
            
          }
        }
      }
    }
    else
    {
      
      self.reviewTableView?.reloadData()
    }
    
    
    
  }
  // MARK: - Anagram Search
  func filteredResultsForAnagramSearch() -> Array<NSDictionary>
  {
    
    var listOfItems = fetchedResultsController?.fetchedObjects
    
    
    var listOfFilteredItems : Array<NSDictionary> =  listOfItems?.filter({(review:AnyObject)->Bool in
      
      var reviewInfo : NSDictionary = review as! NSDictionary
      
      var isAngramOfSearchTextPresent  =  self.doesAngramOfSearchKeyWordExistsInReview(self.searchBar.text, reviewText: reviewInfo.valueForKey("text") as! String)
      
      return isAngramOfSearchTextPresent;
    }) as! Array<NSDictionary>
    
    return listOfFilteredItems;
    
  }
  // MARK: - Anagram Search
  func filteredResultsForFuzzySearch() -> Array<NSDictionary>
  {
    
    assert(false, "work in progress")
    var listOfItems = fetchedResultsController?.fetchedObjects
    var listOfFilteredItems : Array<NSDictionary> =  listOfItems?.filter({(review:AnyObject)->Bool in
      
      var reviewInfo : NSDictionary = review as! NSDictionary
      
      var isAngramOfSearchTextPresent  =  self.doesAngramOfSearchKeyWordExistsInReview(self.searchBar.text, reviewText: reviewInfo.valueForKey("text") as! String)
      
      return isAngramOfSearchTextPresent;
    }) as! Array<NSDictionary>
    
    return listOfFilteredItems;
    
  }
  
  
  func doesAngramOfSearchKeyWordExistsInReview( searchAnagramKey: String,reviewText: String)->Bool
  {
    
    var charatersToConsiderForIndividualItem = NSMutableCharacterSet();
    charatersToConsiderForIndividualItem.formUnionWithCharacterSet(NSCharacterSet(charactersInString: "  "))
    charatersToConsiderForIndividualItem.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    charatersToConsiderForIndividualItem.formUnionWithCharacterSet(NSCharacterSet.nonBaseCharacterSet())
    
    charatersToConsiderForIndividualItem.formUnionWithCharacterSet(NSCharacterSet.illegalCharacterSet())
    charatersToConsiderForIndividualItem.formUnionWithCharacterSet(NSCharacterSet.controlCharacterSet())
    
    var listOfWordsInArray = reviewText.componentsSeparatedByCharactersInSet(charatersToConsiderForIndividualItem) as NSArray
    
    var emptyStringPredicate : NSPredicate = NSPredicate(format: "length > 0") as NSPredicate
    
    var tempListOfWords =  listOfWordsInArray.filteredArrayUsingPredicate(emptyStringPredicate)
    var listOfWords = tempListOfWords as! Array<String>
    
    println(listOfWords)
    
    var isPresent:Bool = false;
    for (index,element  ) in enumerate(listOfWords)
    {
      isPresent =  isAnagramOfSearchTextPresent(searchAnagramKey, wordInReviewText: element)
      if(isPresent == true)
      {
        break;
      }
    }
    return isPresent;
  }
  
  func isAnagramOfSearchTextPresent(searchText: String, wordInReviewText:String)->Bool
  {
    var searchString : NSString = searchText as NSString
    var wordInReviewString : NSString = wordInReviewText as NSString
    //return  wordInReviewString.doesItContainAnagramOfString(searchText)
    return wordInReviewString.containsAnagramOfString(searchText, isDistinct: false)
    
    
  }
  // scroll view delegate methods
}


extension ViewController:TMFilterDataCollectionDelegate
{
  func filterParameterChosen(categoryList: NSArray!, locationList: NSArray!) {
    
    self.listOfCategories = categoryList
    self.listOfPlaces = locationList
    
    fetchReviews( )
    
  }
  func noFilterParametersChosen() {
    
  }
  
  func urlFromCurrentFilter()->String
  {
    
    
    var preferredLanguage: AnyObject = NSLocale.preferredLanguages()[0]
    
    
    var urlPartList : Array<String> = []
    for category in self.listOfCategories as! Array<AnyObject>
    {
      urlPartList.append("category=\(category.lowercaseString)")
      
    }
    
    
    if self.listOfPlaces?.count > 0
    {
      for location in self.listOfPlaces as! Array<AnyObject>
      {
        urlPartList.append("location=\(location)")
      }
    }
    
    urlPartList.append("language=\(preferredLanguage)")
    
    
    let formedURLString = "&".join(urlPartList)
    println(formedURLString)
    return formedURLString
    
  }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate
{
  
  // MARK: - UITableViewDataSource
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    
    return 1;
  }
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if let count = fetchedResultsController?.fetchedObjects?.count
    {
      println("count of results \(count)")
      return count;
    }
    
    println("no  results ")
    return 0
    //unexpectedly found nil while unwrapping an Optional value
    //https://robots.thoughtbot.com/functional-swift-for-dealing-with-optional-values
    
    
    //        reviewList =  coreDataUtility?.allEntitiesOfClass(TMReview.self, withPredicate: nil, withSortDescriptorList: sortDescriptors, withFetchOffset: 0, withFetchLimit: 0)
    //        println(self.reviewList?.count)
    //        return (self.reviewList?.count)!
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    
    var direction: CGFloat =  1
    
    
    cell.transform = CGAffineTransformMakeTranslation(cell.bounds.size.width * direction, 0)
    UIView.animateWithDuration(0.25, animations: {
      {
        cell.transform = CGAffineTransformIdentity;
        
      }
    })
    
    
    
    
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier(reviewCellIdentifier) as? UITableViewCell
    cell?.accessoryType = .DetailDisclosureButton
    cell?.textLabel?.textColor = UIColor(rgba: kReviewCellTextColor)
    var reviewInfo = fetchedResultsController?.objectAtIndexPath(indexPath) as! NSDictionary
    cell?.textLabel?.font = UIFont(name: "GillSans", size: 14)
    cell?.textLabel?.text = reviewInfo.valueForKey("text") as? String
    
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
    
    visualEffectView.frame = CGRectMake(0, 0, cell!.bounds.width, cell!.bounds.height)
    //cell!.contentView.addSubview(visualEffectView)
    
    
    
    return cell!
  }
  //MARK: -UITableViewDelegate
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    var reviewInfo = fetchedResultsController?.objectAtIndexPath(indexPath) as! NSDictionary
    var objectID = reviewInfo.objectForKey("objectID") as! NSManagedObjectID
    openDetailsReviewControllerForReviewWithManagedObjectID(objectID)
      //var filterInfoViewController = TMReviewInfoFormViewController(objectID:objectID, moc: self.managedObjectContext)
    //self.navigationController?.pushViewController(filterInfoViewController, animated: true)
    
  }
  
  
}
extension ViewController : TMReviewInfoDelegate
{
  func openDetailsReviewControllerForReviewWithManagedObjectID(reviewObjectID: NSManagedObjectID!) {
    
    var filterInfoViewController = TMReviewInfoFormViewController(objectID:reviewObjectID, moc: self.managedObjectContext)
    self.navigationController?.pushViewController(filterInfoViewController, animated: true)

    
  }
}
extension ViewController : UISearchBarDelegate
{
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    
    
    println("\(searchText)")
  }
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    searchResultsLabel.removeFromSuperview()
    
    searchBar.resignFirstResponder()
  }
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    
    searchResultsLabel.removeFromSuperview()
    
    doLocalFetch()
    println("\(searchBar.text)")
  }
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    
    
    
    removeSearchBar()
    doLocalFetch()
  }
  func removeSearchBar()
  {
    searchResultsLabel.removeFromSuperview()
    self.isSearchTriggeredForReviewsInSqlite = false
    UIView.animateWithDuration(0.5, animations: {
      self.searchBar.text  = ""
      self.searchBar.resignFirstResponder()
      self.searchBar.alpha  = 0.0
      }, completion: {
        (value: Bool) in
        
        self.navigationItem.titleView = self.titleLabel
        self.navigationItem.rightBarButtonItem = self.navigationRightButton
        
        UIView.animateWithDuration(0.5, animations: {
          
          self.navigationRightButton?.enabled = true;
          self.titleLabel.alpha = 1.0
          }, completion: {
            (value: Bool) in
            
            self.reviewTableView.dataSource = self
            self.reviewTableView.delegate = self
            self.reviewTableView.reloadData()
            
        })
        
    })
    
  }
  
  
}