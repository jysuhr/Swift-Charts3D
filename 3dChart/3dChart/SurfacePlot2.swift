import SwiftUI
import Charts
import Spatial

fileprivate func - (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

struct SurfacePlot2: View {
    @State private var azimuth: Angle2D = .degrees(45)
    @State private var inclination: Angle2D = .degrees(30)
    @State private var lastDrag: CGSize = .zero
    
    var body: some View {
        Chart3D {
            SurfacePlot(x: "X", y: "Y", z: "Z") { x, z in
                (sin(5 * x) + sin(5 * z)) / 2
            }
            .foregroundStyle(.heightBased)
        }
        .chart3DPose(Chart3DPose(azimuth: azimuth, inclination: inclination))
        .chartXAxisLabel("X축")
        .chartYAxisLabel("Y축")
        .chartZAxisLabel("Z축")
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

#Preview {
    SurfacePlot2()
        .padding()
}
