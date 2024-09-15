//
//  ChartViewController.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 16/09/2024.
//

import UIKit
//import DGCharts

class ChartViewController: UIViewController {
    
//    @IBOutlet weak var pieChartView: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpChart()
        // Do any additional setup after loading the view.
    }
    
//    func getProjectStatusData(projects: Array<ProjectModel>) -> [ProjectStatus: Int] {
//        var statusCount: [ProjectStatus: Int] = [.Todo: 0, .InProgress: 0, .Completed: 0, .Cancel: 0]
//        
//        for project in projects {
//            statusCount[project.status]! += 1
//        }
//        
//        return statusCount
//    }
//    
//    
//    func setUpChart() {
//        let projectData = GlobalManager.shared.getDatabase().0
//        let projectStatusData = getProjectStatusData(projects: projectData)
//            
//            let dataEntries = projectStatusData.map { status, count -> PieChartDataEntry in
//                PieChartDataEntry(value: Double(count), label: status.rawValue)
//            }
//            
//            let dataSet = PieChartDataSet(entries: dataEntries, label: "Project Status")
//            dataSet.colors = ChartColorTemplates.joyful() // You can customize the colors
//            let data = PieChartData(dataSet: dataSet)
//            
//            pieChartView.data = data
//        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
