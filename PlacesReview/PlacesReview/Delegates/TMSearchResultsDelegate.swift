


class TMSearchResultsDelegate: NSObject,UITableViewDelegate,UITableViewDataSource{

  var searchResults : NSArray!
  var delegate : TMReviewInfoDelegate?
  override init() {
    searchResults = []
  }
  // MARK: - UITableViewDataSource
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    
    return 1;
  }
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    var count = searchResults!.count
    return count;
   

  }
  

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier(reviewCellIdentifier) as? UITableViewCell
    cell?.accessoryType = .DetailDisclosureButton
    cell?.textLabel?.textColor = UIColor(rgba: kReviewCellTextColor)
    var reviewInfo = searchResults?.objectAtIndex( indexPath.row) as! NSDictionary
    cell?.textLabel?.font = UIFont(name: "GillSans", size: 14)
    cell?.textLabel?.text = reviewInfo.valueForKey("text") as? String
    
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
    
    visualEffectView.frame = CGRectMake(0, 0, cell!.bounds.width, cell!.bounds.height)
    //cell!.contentView.addSubview(visualEffectView)
    
    
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    var reviewInfo = searchResults.objectAtIndex(indexPath.row) as! NSDictionary
    var objectID = reviewInfo.objectForKey("objectID") as! NSManagedObjectID
    delegate!.openDetailsReviewControllerForReviewWithManagedObjectID(objectID)
    //var filterInfoViewController = TMReviewInfoFormViewController(objectID:objectID, moc: self.managedObjectContext)
    //self.navigationController?.pushViewController(filterInfoViewController, animated: true)
    
  }
  
}
