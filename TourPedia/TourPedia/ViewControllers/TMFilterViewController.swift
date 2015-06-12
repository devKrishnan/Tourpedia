

protocol TMFilterDataCollectionDelegate
{
  
  func filterParameterChosen(categoryList:  NSArray!, locationList:NSArray!)
  func noFilterParametersChosen()
  
}
class TMFilterViewController: FXFormViewController {
  
  var filterDelegate:TMFilterDataCollectionDelegate?
  var locationNotification :JSNotifier?
  var selectedLocationList: Array<String>?
  var selectedCategoryList: Array<String>?
  lazy var filterFormInfo : TMFilterForm =
  {
    var tempFilterFormInfo : TMFilterForm = TMFilterForm()
    tempFilterFormInfo.selectedCategoryList = self.selectedCategoryList
    tempFilterFormInfo.selectedLocationList = self.selectedLocationList
    
    return tempFilterFormInfo
    }()
  init(selectedCatList: Array<String>?,selectedLocList:Array<String>?){
    
    super.init(nibName: nil, bundle: nil)
    selectedCategoryList = selectedCatList
    selectedLocationList = selectedLocList
    
  }
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.formController.form = filterFormInfo
    self.navigationController?.navigationBar.barTintColor = UIColor(rgba: kAppnavigationBarGlobalColor)
    var cancelButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItemStyle.Plain, target: self, action: ("dontSaveFilter:"))
    var saveButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action:Selector("saveFilter:"))
    //var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action:Selector("dontSaveFilter:"))
    
    var titleLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 100, 60))
    titleLabel.textAlignment = NSTextAlignment.Center
    titleLabel.text = "Filter"
    titleLabel.textColor = UIColor.whiteColor()
    titleLabel.font = UIFont(name: "GillSans", size: 25)
    self.navigationItem.titleView = titleLabel
    
    self.navigationItem.leftBarButtonItem = cancelButtonItem
    self.navigationItem.rightBarButtonItem = saveButtonItem
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    
  }
  
  func saveFilter(barButtonItem: UIBarButtonItem)
  {
    var filterForm : TMFilterForm = self.formController.form as! TMFilterForm
    if (filterForm.selectedLocationList?.count <= 0)
    {
      locationNotification?.hide()
      self.locationNotification = nil
      self.locationNotification = JSNotifier(title: "Select atlease one location")
      locationNotification?.showFor(10.0)
      
    }
    else
    {
      
      println(filterForm.selectedCategoryList)
      println(filterForm.selectedLocationList)
      filterDelegate?.filterParameterChosen(filterForm.selectedCategoryList, locationList: filterForm.selectedLocationList)
      //filterDelegate?.filterParameterChosen(filterForm.selectedCategoryList, locationList: filterForm.selectedLocationList)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
  }
  
  func dontSaveFilter(barButtonItem: UIBarButtonItem)
  {
    filterDelegate?.noFilterParametersChosen()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  
}
