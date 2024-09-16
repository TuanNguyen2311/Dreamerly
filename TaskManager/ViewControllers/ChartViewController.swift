//
//  ChartViewController.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 16/09/2024.
//

import UIKit
import DGCharts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarChart()
    }
    
    func getProjectStatusData(projects: [ProjectModel]) -> [ProjectStatus: Int] {
        var statusCount: [ProjectStatus: Int] = [.Todo: 0, .InProgress: 0, .Completed: 0, .Cancel: 0]
        
        for project in projects {
            statusCount[project.status]! += 1
        }
        
        return statusCount
    }
    
    func setUpBarChart() {
        let projectData = GlobalManager.shared.getDatabase().0
        let projectStatusData = getProjectStatusData(projects: projectData)
        
        // Extract and sort statuses based on the order you want
        let sortedStatuses = projectStatusData.keys.sorted { lhs, rhs in
            return lhs.rawValue < rhs.rawValue
        }
        
        // Create BarChartDataEntry
        let dataEntries = sortedStatuses.enumerated().map { index, status -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(index), y: Double(projectStatusData[status] ?? 0))
        }
        
        // DataSet creation with customization
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Project Status")
        
        // Customizing colors and appearance
        dataSet.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0),
            UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0),
            UIColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
        ]
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 16, weight: .bold)
        
        // Data and formatter
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
        
        // Customize the bar chart appearance
        barChartView.xAxis.labelPosition = .bottom
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.labelCount = sortedStatuses.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sortedStatuses.map { $0.rawValue })
        barChartView.xAxis.granularity = 1
        
        // Animation for smooth appearance
        barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutCubic)
        
        // Customizing legend
        barChartView.legend.enabled = true
        barChartView.legend.font = .systemFont(ofSize: 14, weight: .medium)
        barChartView.legend.textColor = UIColor.label
        barChartView.legend.orientation = .horizontal
        barChartView.legend.horizontalAlignment = .center
    }

}

