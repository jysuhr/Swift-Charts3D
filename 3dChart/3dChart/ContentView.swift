//
//  ContentView.swift
//  3dChart
//
//  Created by 서준영 on 10/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            IrisChart()
//                .padding(20)
                .tabItem {
                    Label("Iris", systemImage: "chart.scatter")
                }
            
            SurfacePlotChart()
                .padding(20)
                .tabItem {
                    Label("Surface", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SurfacePlot2()
                .padding(20)
                .tabItem {
                    Label("Surface2", systemImage:
                    "chart.line.uptrend.xyaxis")
                }
        }
    }
}

#Preview {
    ContentView()
}
