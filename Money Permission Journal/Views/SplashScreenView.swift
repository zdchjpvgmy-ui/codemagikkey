
import SwiftUI

struct SplashScreenView: View {
    @State private var showChain = true
    @State private var showFeathers = false
    @State private var showTitle = false
    
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showChain = false
                    showFeathers = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showTitle = true
                }
            }
        }
    }
}
