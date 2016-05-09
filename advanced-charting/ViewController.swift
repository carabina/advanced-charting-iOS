//
//  ViewController.swift
//  advanced-charting
//
//  Created by Stuart Grey on 06/05/2016.
//  Copyright © 2016 shinobicontrols. All rights reserved.
//

import UIKit


class ViewController: UIViewController, NSXMLParserDelegate, SChartDatasource {
    
    
    //some parameters to help us parse the XML activity file
    var hrElement = false
    var distElement = false
    var trackElement = false
    var value = false
    
    //The resulting data from the xml activity file
    var heartRateData : [Int] = []
    var distanceData : [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parse our xml activity file
        loadData()
        
        //add a simple chart sizing to the device
        let chart = ShinobiChart(frame: self.view.bounds)
        
        
        chart.title = "Heart Rate during run"
        chart.titleLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 40)
        
        chart.backgroundColor = .clearColor()
        
        chart.datasource = self
        
        let xAxis = SChartNumberAxis()
        xAxis.style.majorTickStyle.labelFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 17)
        xAxis.labelFormatter?.numberFormatter().multiplier = 0.001
        xAxis.labelFormatter?.numberFormatter().positiveSuffix = "km"
        xAxis.majorTickFrequency = 10000
        chart.xAxis = xAxis
        
        let yAxis = SChartNumberAxis()
        yAxis.style.majorTickStyle.labelFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 15)
        yAxis.style.lineColor = .clearColor()
        yAxis.majorTickFrequency = 25
        chart.yAxis = yAxis
        
        self.view.addSubview(chart)
        
        
    }
    
    func numberOfSeriesInSChart(chart: ShinobiChart) -> Int {
        return 4
    }
    
    func sChart(chart: ShinobiChart, seriesAtIndex index: Int) -> SChartSeries {
        let lineSeries = SChartLineSeries()
        
        //lineSeries.style().lineColor = UIColor.redColor()
        lineSeries.style().lineWidth = 3
        
        lineSeries.dataSampler = ACKNthPointSampler(nthPoint: 500)
        //lineSeries.dataSampler = ACKRamerDouglasPeuckerSampler(epsilon: 30)
        
        lineSeries.dataSmoother = ACKMidPointSmoother(numberOfPasses: index+1)
        //lineSeries.dataSmoother = ACKCatmullRomSplineSmoother(numberOfSegments: index+1)
        
        return lineSeries
    }
    
    func sChart(chart: ShinobiChart, numberOfDataPointsForSeriesAtIndex seriesIndex: Int) -> Int {
        return heartRateData.count
    }
    
    func sChart(chart: ShinobiChart, dataPointAtIndex dataIndex: Int, forSeriesAtIndex seriesIndex: Int) -> SChartData {
        let dp = SChartDataPoint()
        dp.xValue = distanceData[dataIndex]
        dp.yValue = heartRateData[dataIndex]
        return dp
    }
    
    func loadData() {
        let path = NSBundle.mainBundle().pathForResource("activity_1151910037", ofType: "tcx")
        let parser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))
        parser!.delegate = self
        parser!.parse()

    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        switch elementName {
            case "Track": trackElement = true
            case "HeartRateBpm": hrElement = true
            case "DistanceMeters": distElement = true
            case "Value": value = true
            default: break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if trackElement {
            if value && hrElement {
                heartRateData.append(Int(string)!)
            } else if distElement {
                distanceData.append(Double(string)!)
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "Track": trackElement = false
        case "HeartRateBpm": hrElement = false
        case "DistanceMeters": distElement = false
        case "Value": value = false
        default: break
        }
    }


}

