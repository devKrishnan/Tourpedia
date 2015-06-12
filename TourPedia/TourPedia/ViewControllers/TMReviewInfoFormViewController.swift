
class TMReviewInfoFormViewController: FXFormViewController {
  
  var reviewInfo : TMReview?
  lazy var reviewFormInfo : TMReviewDetailsForm =
  {
    var tempreviewFormInfo : TMReviewDetailsForm = TMReviewDetailsForm()
    tempreviewFormInfo.text = self.reviewInfo!.text;
    tempreviewFormInfo.rating = self.reviewInfo!.rating;
    tempreviewFormInfo.source = self.reviewInfo!.source;
    tempreviewFormInfo.time = self.reviewInfo!.time;
    
    return tempreviewFormInfo
    }()
  
  init(objectID: NSManagedObjectID?,moc:NSManagedObjectContext?){
    
    super.init(nibName: nil, bundle: nil)
    reviewInfo = moc?.objectWithID(objectID!) as? TMReview
    
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.formController.form = reviewFormInfo
    self.navigationController?.navigationBar.barTintColor = UIColor(rgba: kAppnavigationBarGlobalColor)
    
    // Set rating view to accessory view.
    var ratingView = AXRatingView();
    var baseColor = UIColor(rgba: "#242739")
    ratingView.baseColor = baseColor.colorWithAlphaComponent(0.5)
    ratingView.highlightColor = UIColor(rgba: "#F3F3F9")
    ratingView.stepInterval = 1.0;
    ratingView.numberOfStar = 5
    var starValue = reviewInfo?.rating.floatValue
    ratingView.value =  starValue!
    ratingView.frame = CGRectMake(0, 30, 120, 40)
    ratingView.userInteractionEnabled = false
    self.navigationItem.titleView = ratingView
    var imageName = TMUtilities.imageNameForSource(reviewInfo?.source)
    
    println("Image Name \(imageName)")
    var sourceImageView : UIBarButtonItem  = UIBarButtonItem(image: UIImage(named: imageName), style: UIBarButtonItemStyle.Plain, target: nil, action: "")

    self.navigationItem.rightBarButtonItem = sourceImageView
    self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    
    var timeInString =   self.reviewInfo!.time.timeAgoSinceNow;
    var timeLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 100, 100))
    timeLabel.textAlignment = NSTextAlignment.Center
    timeLabel.text = timeInString() + "\t"+self.reviewInfo!.time.formattedDateWithStyle(NSDateFormatterStyle.LongStyle)
    timeLabel.textColor = UIColor.blackColor()
    timeLabel.font = UIFont(name: "GillSans", size: 15)
   
    self.tableView.tableFooterView =  timeLabel;
    
    
  }
}
