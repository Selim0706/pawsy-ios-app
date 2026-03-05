import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBeige.ignoresSafeArea()
            
            TopCurveShape()
                .fill(Color.appMint)
                .frame(height: 250)
                .ignoresSafeArea()
            
            VStack {
                // Top Navigation
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
                    
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "person")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appDarkGreen)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Profile Avatar Area
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 90, height: 90)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            .overlay(Text("👩🐶").font(.system(size: 40)))
                        
                        // Online indicator
                        Circle()
                            .fill(Color.appProgressMint)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.appMint, lineWidth: 3))
                            .offset(x: -4, y: -4)
                    }
                    
                    // Level / Status Pill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.actionBlue)
                        .frame(width: 100, height: 20)
                }
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // My Pets Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("My Pets")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.appDarkGreen)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textGray)
                            }
                            
                            // Pet Card list
                            HStack {
                                PetCard(name: "Milo", emoji: "🐶")
                                Spacer()
                            }
                        }
                        
                        // Community Map Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Community Map")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.appDarkGreen)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.actionMint)
                                    .clipShape(Capsule())
                                Spacer()
                            }
                            
                            // Map Placeholder Diagram
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.5))
                                    .frame(height: 140)
                                    // A faint map background
                                    .background(
                                        Image(systemName: "map")
                                            .font(.system(size: 100))
                                            .foregroundColor(.appBeige)
                                            .opacity(0.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                
                                // Floating map avatars
                                MapAvatar(emoji: "🐩", size: 40)
                                    .position(x: 50, y: 90)
                                MapAvatar(emoji: "🐕", size: 60)
                                    .position(x: 140, y: 70)
                                    .overlay(Circle().stroke(Color.appMint, lineWidth: 2).position(x: 140, y: 70))
                                MapAvatar(emoji: "🐕‍🦺", size: 45)
                                    .position(x: 230, y: 40)
                            }
                        }
                        
                        Spacer(minLength: 100) // Padding for tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
            }
        }
    }
}

struct PetCard: View {
    var name: String
    var emoji: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appMint.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Text(emoji)
                    .font(.system(size: 40))
            }
            
            Text(name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.appDarkGreen)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct MapAvatar: View {
    var emoji: String
    var size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
            
            Text(emoji)
                .font(.system(size: size * 0.5))
        }
    }
}
