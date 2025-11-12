//
//  ProgressBar.swift
//  TestFormApp
//
//  Progress bar component for showing completion percentage
//

import SwiftUI

struct ProgressBar: View {
    let percentage: Double
    let height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)

                // Foreground
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(percentage / 100), height: height)
            }
        }
        .frame(height: height)
    }

    private var progressColor: Color {
        switch percentage {
        case 0..<30:
            return .red
        case 30..<70:
            return .orange
        case 70..<100:
            return .blue
        default:
            return .green
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(alignment: .leading) {
            Text("0%")
            ProgressBar(percentage: 0)
                .frame(height: 8)
        }

        VStack(alignment: .leading) {
            Text("25%")
            ProgressBar(percentage: 25)
                .frame(height: 8)
        }

        VStack(alignment: .leading) {
            Text("50%")
            ProgressBar(percentage: 50)
                .frame(height: 8)
        }

        VStack(alignment: .leading) {
            Text("75%")
            ProgressBar(percentage: 75)
                .frame(height: 8)
        }

        VStack(alignment: .leading) {
            Text("100%")
            ProgressBar(percentage: 100)
                .frame(height: 8)
        }
    }
    .padding()
}
