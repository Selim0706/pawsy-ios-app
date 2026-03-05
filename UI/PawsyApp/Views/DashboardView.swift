import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            Color.appMint.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appDarkGreen)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Pawsy")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appDarkGreen)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                            
                            Circle()
                                .fill(Color.appPink)
                                .frame(width: 10, height: 10)
                                .padding(2)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -2, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Stats Card
                HStack(spacing: 20) {
                    CircularProgressView(progress: 0.90, color: .appPink, label: "Happiness")
                    Divider().frame(height: 40)
                    CircularProgressView(progress: 0.85, color: .appProgressMint, label: "Health")
                    Divider().frame(height: 40)
                    CircularProgressView(progress: 0.70, color: .appBlue, label: "Hygiene")
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // 3D Pet Placeholder
                Spacer()
                
                ZStack {
                    // Base Platform
                    Ellipse()
                        .fill(Color.appProgressMint.opacity(0.3))
                        .frame(width: 250, height: 80)
                        .offset(y: 80)
                    
                    // Dog placeholder (using emoji since 3D asset is not available)
                    Text("🐶")
                        .font(.system(size: 150))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 15) {
                    ActionButton(title: "Feed", icon: "takeoutbag.and.cup.and.straw", color: .actionPeach)
                    ActionButton(title: "Walk", icon: "figure.walk", color: .actionMint)
                    ActionButton(title: "Play", icon: "megaphone", color: .actionBlue)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Floating Pawsy badge
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.appDarkGreen)
                    Text("Pawsy")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                .padding(.bottom, 100) // Space for TabBar
            }
        }
    }
}

struct ActionButton: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appDarkGreen)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appDarkGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
