//
//  CreateProjectViewController.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 14/09/2024.
//

import UIKit

enum ActionMode:String {
    case Create, Edit
}

class ProjectDetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate , UITableViewDelegate, UITableViewDataSource{
    static let priorityMaxHeight = 50
    static let priorityMinHeight = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var taskCancelButton: UIButton!
    @IBOutlet weak var taskSubmitButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var priorityButton: UIButton!
    
    @IBOutlet weak var priorityManagerView: UIView!
    @IBOutlet weak var lowPriorityView: UIView!
    @IBOutlet weak var mediumPriorityView: UIView!
    @IBOutlet weak var highPriorityView: UIView!
    @IBOutlet weak var urgentPriorityView: UIView!
    
    @IBOutlet weak var calendarFromView: UIView!
    @IBOutlet weak var calendarToView: UIView!
    
    
    @IBOutlet weak var collectionViewFrom: UICollectionView!
    @IBOutlet weak var collectionViewTo: UICollectionView!
    
    @IBOutlet weak var dateFromButton: UIButton!
    @IBOutlet weak var dateToButton: UIButton!
    
    @IBOutlet weak var monthFromLabel: UILabel!
    @IBOutlet weak var monthToLabel: UILabel!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    
    var project:ProjectModel?
    var projectActionMode:ActionMode?
    var taskActionMode:ActionMode?
    var priorityHeight = priorityMinHeight
    var calendarFromHeight = 0
    var calendarToHeight = 0
    
    var selectedDateFrom = Date()
    var selectedDateTo = Date()
    var totalSquaresFrom = [String]()
    var totalSquaresTo = [String]()
    var selectedIndexDateFrom = -1
    var selectedIndexDateTo = -1
    var selectedIndexTask = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let taskNib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        taskTableView.register(taskNib, forCellReuseIdentifier: "taskTableViewCell")
        let calendarNib = UINib(nibName: "CalendarViewCell", bundle: nil)
        collectionViewFrom.register(calendarNib, forCellWithReuseIdentifier: "calendarViewCell")
        collectionViewTo.register(calendarNib, forCellWithReuseIdentifier: "calendarViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        scrollView.delegate = self
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupViews()
            self.detectActionMode()
            self.projectNameTextField.delegate = self
            self.taskNameTextField.delegate = self
            self.projectNameTextField.addTarget(self, action: #selector(self.projectTextFieldDidChange(_ :)), for: .editingChanged)
            self.taskNameTextField.addTarget(self, action: #selector(self.taskTextFieldDidChange(_ :)), for: .editingChanged)
        }
        
        
        
    }
    
    func findActiveTextField(in view: UIView) -> UITextField? {
        for subview in view.subviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            } else if let foundTextField = findActiveTextField(in: subview) {
                return foundTextField
            }
        }
        return nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            if let activeTextField = findActiveTextField(in: view) {
                let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.view)
                let screenHeight = UIScreen.main.bounds.height
                let distanceFromBottom = screenHeight - textFieldFrame.maxY
                        
                if distanceFromBottom < keyboardHeight {
                    self.view.frame.origin.y = -(keyboardHeight - distanceFromBottom + 100)
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func setupViews(){
        changePriorityManagerView(newHeight: CGFloat(priorityHeight))
        changeCalendarHeight(newHeight: CGFloat(calendarFromHeight), calendarView: calendarFromView)
        changeCalendarHeight(newHeight: CGFloat(calendarToHeight), calendarView: calendarToView)
        setupCalendarView()
        setupTableView()
    }
    
    func setupTableView(){
        func setupTableView(){
            let nib = UINib.init(nibName: "TaskTableViewCell", bundle: nil)
            taskTableView.register(nib, forCellReuseIdentifier: "taskTableViewCell")
            taskTableView.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
    }
    
    func changeCalendarHeight(newHeight: CGFloat, calendarView:UIView) {
        if let heightConstraint = calendarView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = newHeight
            if newHeight == 0 {
                calendarView.isHidden = true
                heightConstraint.priority = UILayoutPriority(750)
            } else {
                calendarView.isHidden = false
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changePriorityManagerView(newHeight: CGFloat){
        if let heightConstraint = priorityManagerView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = newHeight
            if newHeight == 0 {
                priorityManagerView.isHidden = true
                heightConstraint.priority = UILayoutPriority(750)
            } else {
                priorityManagerView.isHidden = false
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setupCalendarView(){
        setCellViews(collectionViewFrom)
        setCellViews(collectionViewTo)
        setupSwipeCollection(collectionViewFrom)
        setupSwipeCollection(collectionViewTo)
    }
    
    func setCellViews(_ collectionView:UICollectionView) {
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.width - 2)/8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setupSwipeCollection(_ collectionView:UICollectionView){
        let isDateFrom = collectionView == collectionViewFrom
        if isDateFrom {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDateFrom(_:)))
            swipeLeft.direction = .left
            collectionView.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDateFrom(_:)))
            swipeRight.direction = .right
            collectionView.addGestureRecognizer(swipeRight)
        } else {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDateTo(_:)))
            swipeLeft.direction = .left
            collectionView.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDateTo(_:)))
            swipeRight.direction = .right
            collectionView.addGestureRecognizer(swipeRight)
        }
        
    }
    
    func setMonthView(_ collectionView:UICollectionView){
        let isDateFrom = collectionView == collectionViewFrom
        
        isDateFrom ? totalSquaresFrom.removeAll():totalSquaresTo.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: isDateFrom ? selectedDateFrom:selectedDateTo)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: isDateFrom ? selectedDateFrom:selectedDateTo)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        let totalCells = calcCalendarViewHeight(isDateFrom,startingSpaces, daysInMonth)
        
        if isDateFrom {
            totalSquaresFrom = Array(repeating: "", count: startingSpaces) +
            Array(1...daysInMonth).map { String($0) } +
            Array(repeating: "", count: totalCells - (startingSpaces + daysInMonth))
        } else {
            totalSquaresTo = Array(repeating: "", count: startingSpaces) +
            Array(1...daysInMonth).map { String($0) } +
            Array(repeating: "", count: totalCells - (startingSpaces + daysInMonth))
        }
        
        
        if isDateFrom {
            monthFromLabel.text = selectedDateFrom.toString(Constants.dateFormatted_2)
        } else {
            monthToLabel.text = selectedDateTo.toString(Constants.dateFormatted_2)
        }
        collectionView.reloadData()
        changeCalendarHeight(newHeight: CGFloat(isDateFrom ? calendarFromHeight:calendarToHeight), calendarView: isDateFrom ? calendarFromView:calendarToView)
    }
    
    func calcCalendarViewHeight(_ isDateFrom:Bool,_ startingSpaces: Int, _ daysInMonth:Int) -> Int{
        var totalCells = startingSpaces + daysInMonth
        let tempTotalRows = totalCells.quotientAndRemainder(dividingBy: 7)
        var totalRow = tempTotalRows.quotient
        if tempTotalRows.remainder > 0 {
            totalRow += 1
        }
        totalCells = totalRow*7
        if isDateFrom {
            calendarFromHeight = totalRow*45 + 100
        } else {
            calendarToHeight = totalRow*45 + 100
        }
        
        
        return totalCells
    }
    
    @objc func handleSwipeDateFrom(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            previousMonthFromAC(self)
        } else {
            nextMonthFromAC(self)
        }
    }
    @objc func handleSwipeDateTo(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            previousMonthToAC(self)
        } else {
            nextMonthToAC(self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let activeTextField = self.taskNameTextField else {
            return
        }
        
        // Tính toán frame của UITextField trong coordinate system của scrollView
        let textFieldFrame = scrollView.convert(activeTextField.frame, from: activeTextField.superview)
        let textFieldY = textFieldFrame.origin.y
        activeTextField.resignFirstResponder()
        // Kiểm tra xem UITextField có bị che khuất bởi cuộn không
//        if !scrollView.bounds.contains(textFieldFrame) {
//            // Ẩn keyboard nếu UITextField bị che khuất
//            activeTextField.resignFirstResponder()
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func detectActionMode(){
        if let _ = project {
            submitButton.isEnabled = true
            projectActionMode = .Edit
            submitButton.setTitle("Update", for: .normal)
            headerTitleLabel.text = "Edit project"
        } else {
            project = ProjectModel(name: "")
            submitButton.isEnabled = false
            projectActionMode = .Create
            submitButton.setTitle("Create", for: .normal)
            headerTitleLabel.text = "Create project"
        }
        fillOutProjectDetail()
    }
    
    func fillOutProjectDetail(){
        guard let projectData = project else {
            print("Project is null")
            return
        }
        projectNameTextField.text = projectData.name
        displayPriority(projectData.priority)
        let dateFromStr = projectData.dateFrom
        if dateFromStr.isEmpty {
            selectedDateFrom = Date()
        } else {
            selectedDateFrom = dateFromStr.toDate(Constants.dateFormatted_1) ?? Date()
        }
        let dateToStr = projectData.dateTo
        if dateToStr.isEmpty {
            selectedDateTo = Date()
        } else {
            selectedDateTo = dateToStr.toDate(Constants.dateFormatted_1) ?? Date()
        }
        
        dateFromButton.setTitle(selectedDateFrom.toString(Constants.dateFormatted_1), for: .normal)
        dateToButton.setTitle(selectedDateTo.toString(Constants.dateFormatted_1), for: .normal)
        
    }
    
    func displayPriority(_ priority:ProjectPriority){
        resetPriorityViews()
        switch priority {
        case .Low:
            self.priorityButton.setTitle("Low", for: .normal)
            self.priorityButton.backgroundColor = Constants.lowPriorityColor
            self.lowPriorityView.backgroundColor = UIColor.red
            break
        case .Medium:
            self.priorityButton.setTitle("Medium", for: .normal)
            self.priorityButton.backgroundColor = Constants.mediumPriorityColor
            self.mediumPriorityView.backgroundColor = UIColor.red
            break
        case .High:
            self.priorityButton.setTitle("High", for: .normal)
            self.priorityButton.backgroundColor = Constants.highPriorityColor
            self.highPriorityView.backgroundColor = UIColor.red
            break
        case .Urgent:
            self.priorityButton.setTitle("Urgent", for: .normal)
            self.priorityButton.backgroundColor = Constants.urgentPriorityColor
            self.urgentPriorityView.backgroundColor = UIColor.red
            break
        }
    }
    
    func setPriority(priority:ProjectPriority){
        guard let _ = project else {
            print("Project is null")
            return
        }
        project!.priority = priority
        displayPriority(project!.priority)
    }
    
    func resetPriorityViews(){
        self.lowPriorityView.backgroundColor = UIColor.clear
        self.mediumPriorityView.backgroundColor = UIColor.clear
        self.highPriorityView.backgroundColor = UIColor.clear
        self.urgentPriorityView.backgroundColor = UIColor.clear
    }
    
    @objc func projectTextFieldDidChange(_ textField: UITextField) {
        guard let _ = project else {
            return
        }
        let projectName = textField.text
        project!.name = projectName ?? ""
        submitButton.isEnabled = textField.text == ""
    }
    @objc func taskTextFieldDidChange(_ textField: UITextField) {
        taskSubmitButton.isEnabled = !(textField.text == "")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func cancelAC(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submitAC(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func lowPriorityAC(_ sender: Any) {
        setPriority(priority: .Low)
    }
    
    @IBAction func mediumPriorityAC(_ sender: Any) {
        setPriority(priority: .Medium)
    }
    
    @IBAction func highPriorityAC(_ sender: Any) {
        setPriority(priority: .High)
    }
    
    @IBAction func urgentPriorityAC(_ sender: Any) {
        setPriority(priority: .Urgent)
    }
    
    @IBAction func showPriorityAC(_ sender: Any) {
        if priorityHeight == ProjectDetailViewController.priorityMinHeight {
            priorityHeight = ProjectDetailViewController.priorityMaxHeight
        } else {
            priorityHeight = ProjectDetailViewController.priorityMinHeight
        }
        changePriorityManagerView(newHeight: CGFloat(priorityHeight))
    }
    @IBAction func calendarFromAC(_ sender: Any) {
        dateFromButton.setTitleColor(calendarFromHeight == 0 ? .red:.black, for: .normal)
        if calendarFromHeight == 0 {
            setMonthView(collectionViewFrom)
        } else {
            calendarFromHeight = 0
            changeCalendarHeight(newHeight: CGFloat(calendarFromHeight), calendarView: calendarFromView)
        }
    }
    
    @IBAction func calendarToAC(_ sender: Any) {
        dateToButton.setTitleColor(calendarToHeight == 0 ? .red:.black, for: .normal)
        if calendarToHeight == 0 {
            setMonthView(collectionViewTo)
        } else {
            calendarToHeight = 0
            changeCalendarHeight(newHeight: CGFloat(calendarToHeight), calendarView: calendarToView)
        }
    }
    
    @IBAction func previousMonthFromAC(_ sender: Any) {
        selectedIndexDateFrom = -1
        selectedDateFrom = CalendarHelper().minusMonth(date: selectedDateFrom)
        setMonthView(collectionViewFrom)
    }
    
    @IBAction func nextMonthFromAC(_ sender: Any) {
        selectedIndexDateFrom = -1
        selectedDateFrom = CalendarHelper().minusMonth(date: selectedDateFrom)
        setMonthView(collectionViewFrom)
    }
    
    @IBAction func previousMonthToAC(_ sender: Any) {
        selectedIndexDateTo = -1
        selectedDateTo = CalendarHelper().minusMonth(date: selectedDateTo)
        setMonthView(collectionViewTo)
    }
    
    @IBAction func nextMonthToAC(_ sender: Any) {
        selectedIndexDateTo = -1
        selectedDateTo = CalendarHelper().minusMonth(date: selectedDateTo)
        setMonthView(collectionViewTo)
    }
    
    @IBAction func taskSubmitAC(_ sender: Any) {
        let taskContent = taskNameTextField.text!
        if taskActionMode == .Create {
            project?.taskList.append(TaskModel(description: taskContent))
        } else {
            if selectedIndexTask > -1 && selectedIndexTask < project?.taskList.count ?? 0 {
                project?.taskList[selectedIndexTask].description = taskContent
            }
        }
        taskNameTextField.text = ""
    }
    @IBAction func taskCancelAC(_ sender: Any) {
        taskCancelButton.isEnabled = false
        taskCancelButton.alpha = 0
        selectedIndexTask = -1
        //todo reload tableview
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ProjectDetailViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isDateFrom = collectionView == collectionViewFrom
        return isDateFrom ? totalSquaresFrom.count:totalSquaresTo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isDateFrom = collectionView == collectionViewFrom
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarViewCell", for: indexPath) as? CalendarViewCell else {
            return UICollectionViewCell()
        }
        let dayText = isDateFrom ? totalSquaresFrom[indexPath.item]:totalSquaresTo[indexPath.item]
        cell.dayOfMonthLabel.text = dayText
        
        cell.contentView.backgroundColor = ((isDateFrom ? selectedIndexDateFrom:selectedIndexDateTo) == indexPath.item) ? UIColor.orange : nil
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = cell.frame.width/2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isDateFrom = collectionView == collectionViewFrom
        let previousIndex = isDateFrom ? selectedIndexDateFrom:selectedIndexDateTo
        let cellValue = isDateFrom ? totalSquaresFrom[indexPath.row]:totalSquaresTo[indexPath.row]
        if cellValue == "" {return}
        if isDateFrom {
            selectedIndexDateFrom = (selectedIndexDateFrom == indexPath.item) ? -1 : indexPath.item
        } else {
            selectedIndexDateTo = (selectedIndexDateTo == indexPath.item) ? -1 : indexPath.item
        }
        var indexPaths = [IndexPath]()
        if previousIndex >= 0 {
            indexPaths.append(IndexPath(item: previousIndex, section: 0))
        }
        if isDateFrom {
            if selectedIndexDateFrom >= 0 {
                let monthYear = selectedDateFrom.toString(Constants.dateFormatted_2)
                let dateFormatted3 = "\(cellValue) \(monthYear)"
                dateFromButton.setTitle("\(dateFormatted3.convertFormat(Constants.dateFormatted_3, Constants.dateFormatted_1))", for: .normal)
                indexPaths.append(IndexPath(item: selectedIndexDateFrom, section: 0))
            }
        } else {
            if selectedIndexDateTo >= 0 {
                let monthYear = selectedDateFrom.toString(Constants.dateFormatted_2)
                let dateFormatted3 = "\(cellValue) \(monthYear)"
                dateToButton.setTitle("\(dateFormatted3.convertFormat(Constants.dateFormatted_3, Constants.dateFormatted_1))", for: .normal)
                indexPaths.append(IndexPath(item: selectedIndexDateTo, section: 0))
            }
        }
        collectionView.reloadItems(at: indexPaths)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project?.taskList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell", for: indexPath) as? TaskTableViewCell
        guard let projectData = project else {
            return UITableViewCell()
        }
        if projectData.taskList.count <= indexPath.row {
            return UITableViewCell()
        } else {
            cell?.commonInit(projectData.taskList[indexPath.row])
        }
        return cell!
    }
    
}
