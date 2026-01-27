import SwiftUI

struct ProgressBarView: View {
    var value: Int
    var total: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(value) / Double(total), 0), 1)
    }
    
    func circleColor(for stepProgress: Double, currentProgress: Double) -> Color {
        return currentProgress >= stepProgress ? .mint : Color.gray.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("200")
                    .font(Font.largeTitle.bold())
                    .padding(.leading, 8)
                Image(systemName: "star.fill").foregroundColor(.mint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Reward Points")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            
            ZStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(Color.mint)
                            .frame(
                                width: geometry.size.width * CGFloat(progress),
                                height: 12
                            )
                            .animation(.spring(), value: value)
                        
                    }
                }
                .offset(y:0)
                .frame(height: 20)
                
                VStack {
                    Circle()
                        .fill(circleColor(for: 0.25, currentProgress: progress))
                        .stroke(circleColor(for: 0.25, currentProgress: progress), lineWidth: 2)
                        .frame(width: 20, height: 14)
                    
                    Text("25")
                        .font(.headline)
                        .italic()
                }
                .offset(x: -100, y: 9)
                
                VStack {
                    Circle()
                        .fill(circleColor(for: 0.5, currentProgress: progress))
                        .stroke(circleColor(for: 0.5, currentProgress: progress), lineWidth: 2)
                        .frame(width: 20, height: 14)
                    
                    Text("50")
                        .font(.headline)
                        .italic()
                }
                .offset(y: 9)
                
                VStack {
                    Circle()
                        .fill(circleColor(for: 0.75, currentProgress: progress))
                        .stroke(circleColor(for: 0.75, currentProgress: progress), lineWidth: 2)
                        .frame(width: 20, height: 14)
                    
                    Text("75")
                        .font(.headline)
                        .italic()
                }
                .offset(x: 100, y: 9)
                
                
            }
            .frame(height: 50)
        }
        }
}

#Preview {
    VStack {
        ProgressBarView(value: 25, total: 100)
    }
    //.background(.red)
}

