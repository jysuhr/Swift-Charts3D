// Customize the surface styles for a sinc function

import SwiftUI
import Charts
import Spatial

struct SurfacePlotChart: View {
    @State private var azimuth: Angle2D = .degrees(45)
    @State private var inclination: Angle2D = .degrees(30)
    @State private var lastDrag: CGSize = .zero
    
    var body: some View {
        Chart3D {
            SurfacePlot(x: "X", y: "Y", z: "Z") { x, y in
                let h = hypot(x, y)
                return sin(h) / h
            }
            .foregroundStyle(.normalBased)
        }
        .chartXScale(domain: -10...10, range: -0.5...0.5)
        .chartZScale(domain: -10...10, range: -0.5...0.5)
        .chartYScale(domain: -0.23...1, range: -0.5...0.5)
        .chart3DPose(Chart3DPose(azimuth: azimuth, inclination: inclination))
        
        /// 드레그 기능
        .gesture(
            DragGesture()
                .onChanged { value in
                    let delta = value.translation - lastDrag
                    azimuth += Angle2D(radians: Double(delta.width) * 0.01)
                    inclination += Angle2D(radians: Double(delta.height) * 0.01)
                    lastDrag = value.translation
                }
                .onEnded { _ in
                    lastDrag = .zero
                }
        )
    }
}

#Preview{
    SurfacePlotChart()
}

// SwiftUI의 CGSize 빼기 연산 지원용 연산자
fileprivate func - (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}
