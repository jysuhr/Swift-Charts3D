import SwiftUI
import Charts
import Spatial

fileprivate func - (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

struct Iris: Identifiable {
    let id = UUID()
    let sepalLength: Double
    let sepalWidth: Double
    let petalLength: Double
    let petalWidth: Double
    let species: String
}

func loadIrisData() -> [Iris] {
    guard let url = Bundle.main.url(forResource: "iris", withExtension: "data"),
          let content = try? String(contentsOf: url) else { return [] }
    return content.split(separator: "\n").compactMap { line in
        let parts = line.split(separator: ",")
        if parts.count == 5,
           let sepalL = Double(parts[0]),
           let sepalW = Double(parts[1]),
           let petalL = Double(parts[2]),
           let petalW = Double(parts[3]) {
            return Iris(sepalLength: sepalL, sepalWidth: sepalW, petalLength: petalL, petalWidth: petalW, species: String(parts[4]))
        } else {
            return nil
        }
    }
}

enum ViewAngle: String, CaseIterable {
    case front = "앞면"
    case side = "옆면"
    case top = "윗면"
    
    var pose: (azimuth: Angle2D, inclination: Angle2D) {
        switch self {
        case .front:
            return (.degrees(0), .degrees(0))
        case .side:
            return (.degrees(90), .degrees(0))
        case .top:
            return (.degrees(0), .degrees(90))
        }
    }
}

enum CameraProjection: String, CaseIterable {
    case perspective = "원근"
    case orthographic = "정사영"
    
    var projection: Chart3DCameraProjection {
        switch self {
        case .perspective:
            return .perspective
        case .orthographic:
            return .orthographic
        }
    }
}

struct IrisChart: View {
    @State private var irisData: [Iris] = []
    @State private var azimuth: Angle2D = .degrees(45)
    @State private var inclination: Angle2D = .degrees(30)
    @State private var lastDrag: CGSize = .zero
    @State private var selectedView: ViewAngle = .front
    @State private var regression: LinearRegression?
    @State private var showRegression: Bool = true
    @State private var cameraProjection: CameraProjection = .perspective
    
    var body: some View {
        HStack {
            Chart3D {
                // 데이터 포인트
                ForEach(irisData) { iris in
                    PointMark(
                        x: .value("Sepal Length", iris.sepalLength),
                        y: .value("Petal Length", iris.petalLength),
                        z: .value("Petal Width", iris.petalWidth)
                    )
                    .foregroundStyle(by: .value("Species", iris.species))
                }
                
                // 회귀 평면
                if showRegression, let reg = regression {
                    SurfacePlot(x: "Sepal Length", y: "Petal Length", z: "Petal Width") { x, z in
                        reg(x, z)
                    }
                    .foregroundStyle(.blue.opacity(0.3))
                }
            }
            .chart3DPose(Chart3DPose(azimuth: azimuth, inclination: inclination))
            .chart3DCameraProjection(cameraProjection.projection)
            .chartXAxisLabel("Sepal Length (cm)")
            .chartYAxisLabel("Petal Length (cm)")
            .chartZAxisLabel("Petal Width (cm)")
            .onAppear {
                irisData = loadIrisData()
                if !irisData.isEmpty {
                    regression = LinearRegression(
                        irisData,
                        x: \.sepalLength,
                        y: \.petalLength,
                        z: \.petalWidth
                    )
                }
                azimuth = selectedView.pose.azimuth
                inclination = selectedView.pose.inclination
            }
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
            
            VStack(spacing: 16) {
                // 회귀 평면 토글
                Toggle("선형회귀 평면", isOn: $showRegression)
                    .toggleStyle(.switch)
                    .frame(width: 200)
                    .padding(.bottom, 4)
                
                // 카메라 프로젝션 선택
                VStack(alignment: .leading, spacing: 8) {
                    Text("카메라 투영")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("투영 방식", selection: $cameraProjection) {
                        ForEach(CameraProjection.allCases, id: \.self) { projection in
                            Text(projection.rawValue).tag(projection)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.bottom, 8)
                
                Divider()
                    .frame(width: 200)
                
                // 뷰 앵글 버튼
                ForEach(ViewAngle.allCases, id: \.self) { angle in
                    Button {
                        withAnimation {
                            selectedView = angle
                            azimuth = angle.pose.azimuth
                            inclination = angle.pose.inclination
                        }
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                if selectedView == angle {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            Text(angle.rawValue)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

#Preview {
    IrisChart()
}
