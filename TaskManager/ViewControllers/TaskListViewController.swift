//
//  TaskListVC.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 13/09/2024.
//

import Foundation
import UIKit


class TaskListViewController:UIViewController , UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var projectArr:Array<ProjectModel> = []
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var todoNumLabel: UILabel!
    @IBOutlet weak var inProgressNumLabel: UILabel!
    @IBOutlet weak var completedNumLabel: UILabel!
    @IBOutlet weak var cancelNumLabel: UILabel!
    
    @IBOutlet weak var todoView: UIView!
    @IBOutlet weak var inProgressView: UIView!
    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var cancelView: UIView!
    
    
    
    
    var selectedDate = Date()
    var selectedDateStr = ""
    var totalSquares = [String]()
    var selectedIndex = -1
    var collectionViewHeight = 0
    var isShowAll = false
    var currentStatus:ProjectStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.showCalendarMode()
            self.setupCalendarView()
            self.setupTableView()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Constants.ReloadDataNotification), object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.ReloadDataNotification), object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func reloadData() {
        if GlobalManager.shared.isReloadData {
            if isShowAll {
                displayData(status: currentStatus)
            } else {
                displayData(byDate: selectedDateStr,status: currentStatus)
            }
            GlobalManager.shared.isReloadData = false
        }
    }
    
    func resetStatusViews(){
        todoView.backgroundColor = Constants.unselectedStatusColor
        todoView.layer.opacity = 20
        inProgressView.backgroundColor = Constants.unselectedStatusColor
        inProgressView.layer.opacity = 20
        completedView.backgroundColor = Constants.unselectedStatusColor
        completedView.layer.opacity = 20
        cancelView.backgroundColor = Constants.unselectedStatusColor
        cancelView.layer.opacity = 20
    }
    
    func setColorForSelectedStatus(status:ProjectStatus?=nil){
        resetStatusViews()
        if status == nil {return}
        else {
            switch status {
            case .Todo:
                todoView.backgroundColor = Constants.selectedStatusColor
                break
            case .InProgress:
                inProgressView.backgroundColor = Constants.selectedStatusColor
                break
            case .Completed:
                completedView.backgroundColor = Constants.selectedStatusColor
                break
            case .Cancel:
                cancelView.backgroundColor = Constants.selectedStatusColor
                break
            default:break
            }
        }
    }
    
    func displayData(byDate:String="", status:ProjectStatus?=nil){
        var data:(Array<ProjectModel>, Int, Int, Int, Int)!
        if byDate == ""{//get all
            data = GlobalManager.shared.getDatabase(status: status)
        } else {
            data = GlobalManager.shared.getDatabaseByDate(dateFrom: byDate, status: status)
        }
        projectArr = data.0
        DispatchQueue.main.async {
            if status == nil {
                self.updateStatusSumary(todoNum: data.1, processingNum: data.2, completedNum: data.3, cancelNum: data.4)
            }
            self.tableView.reloadData()
        }
    }
    
    func updateStatusSumary(todoNum:Int, processingNum:Int, completedNum:Int, cancelNum:Int){
        todoNumLabel.text = String(todoNum)
        inProgressNumLabel.text = String(processingNum)
        completedNumLabel.text = String(completedNum)
        cancelNumLabel.text = String(cancelNum)
    }
    
    func showCalendarMode(){
        currentStatus = nil
        resetStatusViews()
        isShowAll = false
        seeAllButton.isHidden = false
        seeAllButton.isEnabled = true
        calendarButton.isHidden = true
        calendarButton.isEnabled = false
        calendarView.isHidden = false
        setMonthView()
        selectedDateStr = selectedDate.toString()
        self.displayData(byDate: self.selectedDateStr)
    }
    
    func showAllMode(){
        currentStatus = nil
        resetStatusViews()
        isShowAll = true
        calendarButton.isHidden = false
        calendarButton.isEnabled = true
        seeAllButton.isHidden = true
        seeAllButton.isEnabled = false
        calendarView.isHidden = true
        changeCalendarHeight(newHeight: 0)
        self.displayData()
    }
    
    func setupTableView(){
        let nib = UINib.init(nibName: "ProjectViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "projectViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    
    func setupCalendarView(){
        setCellViews()
        setupSwipeCollection()
    }
    
    
    func changeCalendarHeight(newHeight: CGFloat) {
        if let heightConstraint = calendarView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = newHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    func setCellViews() {
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.width - 2)/8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func calcCalendarViewHeight(_ startingSpaces: Int, _ daysInMonth:Int) -> Int{
        var totalCells = startingSpaces + daysInMonth
        let tempTotalRows = totalCells.quotientAndRemainder(dividingBy: 7)
        var totalRow = tempTotalRows.quotient
        if tempTotalRows.remainder > 0 {
            totalRow += 1
        }
        totalCells = totalRow*7
        collectionViewHeight = totalRow*45 + 100
        
        return totalCells
    }
    
    func setMonthView(){
        totalSquares.removeAll()
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        let totalCells = calcCalendarViewHeight(startingSpaces, daysInMonth)
        
        
        totalSquares = Array(repeating: "", count: startingSpaces) +
        Array(1...daysInMonth).map { String($0) } +
        Array(repeating: "", count: totalCells - (startingSpaces + daysInMonth))
        monthLabel.text = "\(CalendarHelper().monthString(date: selectedDate)) \(CalendarHelper().yearString(date: selectedDate))"
        
        selectedIndex = CalendarHelper().getSelectedIndex(selectedMonth: selectedDate, compareDate: selectedDateStr)
        collectionView.reloadData()
        changeCalendarHeight(newHeight: CGFloat(collectionViewHeight))
    }
    
    func openProjectDetail(_ project:ProjectModel?=nil, _ projectIndex:Int = -1) {
        let projectDetailVC = ProjectDetailViewController()
        projectDetailVC.modalPresentationStyle = .fullScreen
        projectDetailVC.project = project
        projectDetailVC.projectIndex = projectIndex
        let navigationController = UINavigationController(rootViewController: projectDetailVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    func setupSwipeCollection(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func seeAllAC(_ sender: Any) {
        showAllMode()
    }
    
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            previousMonthAC(self)
        } else {
            nextMonthAC(self)
        }
    }
    
    @IBAction func previousMonthAC(_ sender: Any) {
        selectedIndex = -1
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    @IBAction func nextMonthAC(_ sender: Any) {
        selectedIndex = -1
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func showCalendarAC(_ sender: Any) {
        showCalendarMode()
    }
    
    @IBAction func createProjectAC(_ sender: Any) {
        openProjectDetail()
    }
    
    @IBAction func inProgressFilterAC(_ sender: Any) {
        if currentStatus != .InProgress {
            currentStatus = .InProgress
        } else {
            currentStatus = nil
        }
        filterDataByStatus(status: currentStatus)
    }
    @IBAction func todoFilterAC(_ sender: Any) {
        if currentStatus != .Todo {
            currentStatus = .Todo
        } else {
            currentStatus = nil
        }
        filterDataByStatus(status: currentStatus)
    }
    @IBAction func completedFilterAC(_ sender: Any) {
        if currentStatus != .Completed {
            currentStatus = .Completed
        } else {
            currentStatus = nil
        }
        filterDataByStatus(status: currentStatus)
    }
    @IBAction func cancelFilterAC(_ sender: Any) {
        if currentStatus != .Cancel {
            currentStatus = .Cancel
        } else {
            currentStatus = nil
        }
        filterDataByStatus(status: currentStatus)
    }
    
    func filterDataByStatus(status:ProjectStatus?=nil){
        setColorForSelectedStatus(status: status)
        if isShowAll {
            displayData(status: status)
        } else {
            displayData(byDate: selectedDateStr, status: status)
        }
    }
    
}

extension TaskListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectViewCell", for: indexPath) as? ProjectViewCell
        let project = self.projectArr[indexPath.row]
        cell?.commonInit(project)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openProjectDetail(projectArr[indexPath.row], indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let deletedProject = projectArr[indexPath.row]
                projectArr.remove(at: indexPath.row)
                GlobalManager.shared.deleteProject(projectDeleted: deletedProject)
                tableView.reloadData()
                
            }
        }
        
        // Thêm tiêu đề cho nút swipe (mặc định là "Delete")
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "Delete"
        }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        let dayText = totalSquares[indexPath.item]
        cell.dayOfMonthLabel.text = dayText
        
        cell.contentView.backgroundColor = (selectedIndex == indexPath.item) ? UIColor.orange : nil
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = cell.frame.width/2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selectedIndex
        selectedIndex = (selectedIndex == indexPath.item) ? -1 : indexPath.item
        let cellValue = totalSquares[indexPath.row]
        if cellValue == "" {return}
        
        var indexPaths = [IndexPath]()
        if previousIndex >= 0 {
            indexPaths.append(IndexPath(item: previousIndex, section: 0))
        }
        if selectedIndex >= 0 {
            indexPaths.append(IndexPath(item: selectedIndex, section: 0))
        }
        
        let monthYear = selectedDate.toString(Constants.dateFormatted_2)
        let dateFormatted3 = "\(cellValue) \(monthYear)"
        let dateStr = "\(dateFormatted3.convertFormat(Constants.dateFormatted_3, Constants.dateFormatted_1))"
        selectedDateStr = dateStr
        displayData(byDate: selectedDateStr)
        currentStatus = nil
        resetStatusViews()
        collectionView.reloadItems(at: indexPaths)
    }
}
