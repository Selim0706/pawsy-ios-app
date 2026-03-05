import SwiftUI

struct TopCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 60))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 20),
            control: CGPoint(x: rect.midX, y: rect.maxY + 40)
        )
        return path
    }
}

struct MedicalHubView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBeige.ignoresSafeArea()
            
            TopCurveShape()
                .fill(Color.appMint)
                .frame(height: 220)
                .ignoresSafeArea()
            
            VStack {
                // Nav Bar
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
                    
                    Text("Medical Hub")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appDarkGreen)
                        .padding(.trailing, 44) // Balance out the left button
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        CalendarCard()
                            .padding(.top, 20)
                        
                        WeightHistoryCard()
                        
                        // Medical Activities list
                        VStack(spacing: 12) {
                            MedicalListItem(title: "Vet Visit - Dr. Lee", icon: "pawprint.fill", color: .actionBlue)
                            MedicalListItem(title: "Flea Treatment", icon: "cross.vial.fill", color: .actionMint)
                            MedicalListItem(title: "Heartworm Preventative", icon: "heart.fill", color: .appPink)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct CalendarCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {}) { Image(systemName: "chevron.left").foregroundColor(.appDarkGreen) }
                Spacer()
                Text("November 2024").font(.system(size: 16, weight: .bold)).foregroundColor(.appDarkGreen)
                Spacer()
                Button(action: {}) { Image(systemName: "chevron.right").foregroundColor(.appDarkGreen) }
            }
            .padding(.horizontal, 10)
            
            HStack {
                ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textGray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Simplified Calendar Grid
            VStack(spacing: 12) {
                HStack {
                    CalendarDay(day: "", isTarget: false)
                    CalendarDay(day: "", isTarget: false)
                    CalendarDay(day: "", isTarget: false)
                    CalendarDay(day: "1", isTarget: false)
                    CalendarDay(day: "2", isTarget: false)
                    CalendarDay(day: "3", isTarget: false)
                    CalendarDay(day: "4", isTarget: true) // highlighted
                }
                HStack {
                    CalendarDay(day: "5", isTarget: false)
                    CalendarDay(day: "6", isTarget: false)
                    CalendarDay(day: "7", isTarget: false)
                    CalendarDay(day: "8", isTarget: false)
                    CalendarDay(day: "9", isTarget: false)
                    CalendarDay(day: "10", isTarget: false)
                    CalendarDay(day: "11", isTarget: false)
                }
                HStack {
                    CalendarDay(day: "12", isTarget: false)
                    // Just filling a few rows to match screenshot
                    Text("...").frame(maxWidth: .infinity).foregroundColor(.textGray)
                    CalendarDay(day: "31", isTarget: false, isMint: true)
                }
            }
            .overlay(
                // Floating Pop-up
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vaccination Due:")
                        .font(.system(size: 14, weight: .bold))
                    Text("Rabies (Today)")
                        .font(.system(size: 14, weight: .regular))
                }
                .padding(12)
                .background(Color.actionBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                .offset(y: -40),
                alignment: .center
            )
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct CalendarDay: View {
    var day: String
    var isTarget: Bool
    var isMint: Bool = false
    
    var body: some View {
        ZStack {
            if isTarget {
                Circle().fill(Color.appMint.opacity(0.5)).frame(width: 30, height: 30)
            } else if isMint {
                Circle().fill(Color.appMint).frame(width: 30, height: 30)
            }
            Text(day)
                .font(.system(size: 14, weight: isTarget || isMint ? .bold : .medium))
                .foregroundColor(.appDarkGreen)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeightHistoryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weight History")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appDarkGreen)
            
            // Simple Line Graph Placeholder
            ZStack(alignment: .bottomLeading) {
                // Graph background
                Rectangle()
                    .fill(LinearGradient(colors: [.appPink.opacity(0.2), .white], startPoint: .top, endPoint: .bottom))
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Graph Line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 80))
                    path.addCurve(to: CGPoint(x: 100, y: 50), control1: CGPoint(x: 30, y: 80), control2: CGPoint(x: 70, y: 40))
                    path.addCurve(to: CGPoint(x: 200, y: 20), control1: CGPoint(x: 130, y: 60), control2: CGPoint(x: 170, y: 10))
                    path.addLine(to: CGPoint(x: 300, y: 20))
                }
                .stroke(Color.appPink, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(height: 100)
            }
            .frame(height: 100)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct MedicalListItem: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.appDarkGreen)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appDarkGreen)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.textGray)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}
