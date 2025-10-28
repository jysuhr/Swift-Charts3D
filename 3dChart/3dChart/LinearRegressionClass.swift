//
//  LinearRegression.swift
//  3dChart
//
//  Created by 서준영 on 10/29/25.
//

import SwiftUI
import CreateML
import TabularData

final class LinearRegression: Sendable {
  let regressor: MLLinearRegressor

  init<Data: RandomAccessCollection>(
    _ data: Data,
    x xPath: KeyPath<Data.Element, Double>,
    y yPath: KeyPath<Data.Element, Double>,
    z zPath: KeyPath<Data.Element, Double>
  ) {
    let x = Column(name: "X", contents: data.map { $0[keyPath: xPath] })
    let y = Column(name: "Y", contents: data.map { $0[keyPath: yPath] })
    let z = Column(name: "Z", contents: data.map { $0[keyPath: zPath] })
    let data = DataFrame(columns: [x, y, z].map { $0.eraseToAnyColumn() })
    regressor = try! MLLinearRegressor(trainingData: data, targetColumn: "Y")
  }

  func callAsFunction(_ x: Double, _ z: Double) -> Double {
    let x = Column(name: "X", contents: [x])
    let z = Column(name: "Z", contents: [z])
    let data = DataFrame(columns: [x, z].map { $0.eraseToAnyColumn() })
    return (try? regressor.predictions(from: data))?.first as? Double ?? .nan
  }
}
