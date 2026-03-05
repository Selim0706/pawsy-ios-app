import SwiftUI

struct AIAssistantView: View {
    @State private var messageText: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBeige.ignoresSafeArea()
            
            TopCurveShape()
                .fill(Color.appMint)
                .frame(height: 280)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation and Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appDarkGreen)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Avatar View
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            
                            Text("🤖")
                                .font(.system(size: 40))
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appDarkGreen)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Text("Ask Vetty AI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                }
                
                // Chat Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // User Request
                        HStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 12) {
                                // Image Placeholder
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#5C4033")) // Chocolate color
                                        .frame(width: 150, height: 100)
                                    Text("🍫").font(.system(size: 50))
                                }
                                
                                Text("Is this safe for Max?")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.appDarkGreen)
                            }
                            .padding(16)
                            .background(Color.appMint)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            // Custom corner rounding for chat bubble tail effect
                            .cornerRadius(4, corners: [.bottomTrailing])
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                        }
                        .padding(.leading, 60)
                        
                        // AI Response
                        HStack(alignment: .bottom, spacing: 12) {
                            // AI Mini Avatar
                            ZStack {
                                Circle().fill(Color.white).frame(width: 32, height: 32)
                                Text("🤖").font(.system(size: 16))
                            }
                            .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                    .padding(.top, 2)
                                
                                Text("No, chocolate is toxic for dogs. Keep it away!")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.appDarkGreen)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16)
                            .background(Color.chatPeach)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .cornerRadius(4, corners: [.bottomLeading])
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                            
                            Spacer()
                        }
                        .padding(.trailing, 60)
                    }
                    .padding(20)
                }
                
                // Bottom Input Area
                HStack(spacing: 12) {
                    HStack {
                        TextField("Type message...", text: $messageText)
                            .font(.system(size: 15))
                            .foregroundColor(.appDarkGreen)
                        
                        Button(action: {}) {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.textGray)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                    
                    Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.appDarkGreen)
                            .font(.system(size: 16))
                            .frame(width: 48, height: 48)
                            .background(Color.appMint)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120) // Give space for bottom tab bar
            }
        }
    }
}

// Helper to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
