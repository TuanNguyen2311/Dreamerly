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
    
    var selectedDate = Date()
    var totalSquares = [String]()
    var selectedIndex = -1
    var collectionViewHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.chooseViewMode(mode: 0)
            self.setupTableView()
            self.initProjectArr()
            self.setupCalendarView()
            self.tableView.reloadData()
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    /// 0: calendar
    /// 1: see all
    func chooseViewMode(mode: Int){
        switch mode {
        case 0:
            showCalendarMode()
            break
        default: 
            showAllMode()
            break
        }
    }
    
    func showCalendarMode(){
        seeAllButton.isHidden = false
        seeAllButton.isEnabled = true
        calendarButton.isHidden = true
        calendarButton.isEnabled = false
        calendarView.isHidden = false
        setMonthView()
    }
    
    func showAllMode(){
        calendarButton.isHidden = false
        calendarButton.isEnabled = true
        seeAllButton.isHidden = true
        seeAllButton.isEnabled = false
        calendarView.isHidden = true
        changeCalendarHeight(newHeight: 0)
    }
    
    func setupTableView(){
        let nib = UINib.init(nibName: "ProjectViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "projectViewCell")
        tableView.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func initProjectArr(){
        let taskList1 = [TaskModel(description: "Task1", status: .Completed), TaskModel(description: "Task2"), TaskModel(description: "Task3"), TaskModel(description: "Task4"), TaskModel(description: "Task5"), TaskModel(description: "Task6"), TaskModel(description: "Task7"), TaskModel(description: "Task8")]
        let taskList2 = [TaskModel(description: "Task1", status: .Completed), TaskModel(description: "Task2", status: .Completed), TaskModel(description: "Task3", status: .Completed), TaskModel(description: "Task4"), TaskModel(description: "Task5"), TaskModel(description: "Task6"), TaskModel(description: "Task7"), TaskModel(description: "Task8")]
        projectArr.append(ProjectModel(name: "Cưới vợ", taskList: taskList1))
        projectArr.append(ProjectModel(name: "Mua nhà",  taskList: taskList2))
        projectArr.append(ProjectModel(name: "Trả hết nợ"))
        projectArr.append(ProjectModel(name: "Mua xe"))
        projectArr.append(ProjectModel(name: "Prj1"))
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
        collectionView.reloadData()
        changeCalendarHeight(newHeight: CGFloat(collectionViewHeight))
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
        chooseViewMode(mode: 1)
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
    
    func openProjectDetail(_ project:ProjectModel?=nil) {
        let projectDetailVC = ProjectDetailViewController()
        projectDetailVC.modalPresentationStyle = .fullScreen
        projectDetailVC.project = project
        let navigationController = UINavigationController(rootViewController: projectDetailVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func createProjectAC(_ sender: Any) {
        openProjectDetail()
//        let createProjectVC = ProjectDetailViewController()
//        createProjectVC.modalPresentationStyle = .fullScreen
//        let navigationController = UINavigationController(rootViewController: createProjectVC)
//        present(navigationController, animated: true, completion: nil)
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
        openProjectDetail(projectArr[indexPath.row])
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
        
        var indexPaths = [IndexPath]()
        if previousIndex >= 0 {
            indexPaths.append(IndexPath(item: previousIndex, section: 0))
        }
        if selectedIndex >= 0 {
            indexPaths.append(IndexPath(item: selectedIndex, section: 0))
        }
        
        collectionView.reloadItems(at: indexPaths)
    }
}
