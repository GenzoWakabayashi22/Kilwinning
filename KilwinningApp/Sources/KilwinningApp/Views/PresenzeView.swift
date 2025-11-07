import SwiftUI
import Charts

struct PresenzeView: View {
    let brother: Brother
    @StateObject private var dataService = DataService.shared
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    var statistics: PresenceStatistics {
        dataService.calculateStatistics(for: brother.id, year: selectedYear)
    }
    
    var monthlyData: [(month: String, presences: Int)] {
        let calendar = Calendar.current
        var data: [(String, Int)] = []
        
        for month in 1...12 {
            let monthTornate = dataService.tornate.filter { tornata in
                let components = calendar.dateComponents([.year, .month], from: tornata.date)
                return components.year == selectedYear && components.month == month
            }
            
            let monthPresences = monthTornate.filter { tornata in
                dataService.getPresenceStatus(brotherId: brother.id, tornataId: tornata.id) == .presente
            }.count
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            let monthName = formatter.shortMonthSymbols[month - 1]
            
            data.append((monthName.capitalized, monthPresences))
        }
        
        return data
    }
    
    var recentTornate: [Tornata] {
        dataService.tornate
            .filter { Calendar.current.component(.year, from: $0.date) == selectedYear }
            .sorted { $0.date > $1.date }
            .prefix(10)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Presenze")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Selettore anno
                Menu {
                    ForEach(2020...2030, id: \.self) { year in
                        Button(String(year)) {
                            selectedYear = year
                        }
                    }
                } label: {
                    HStack {
                        Text(String(selectedYear))
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.masonicBlue.opacity(0.1))
                    .foregroundColor(AppTheme.masonicBlue)
                    .cornerRadius(8)
                }
            }
            
            // Statistiche principali
            StatisticsOverviewCard(statistics: statistics)
            
            // Grafico mensile
            MonthlyChartCard(data: monthlyData)
            
            // Ultime tornate partecipate
            RecentTornateCard(tornate: recentTornate, brother: brother)
            
            // Record personali
            RecordCard(statistics: statistics)
        }
    }
}

struct StatisticsOverviewCard: View {
    let statistics: PresenceStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Riepilogo Annuale")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            HStack(spacing: 15) {
                StatBox(
                    title: "Presenti",
                    value: String(statistics.presences),
                    color: AppTheme.success
                )
                
                StatBox(
                    title: "Assenti",
                    value: String(statistics.absences),
                    color: AppTheme.error
                )
                
                StatBox(
                    title: "Totali",
                    value: String(statistics.totalTornate),
                    color: AppTheme.masonicBlue
                )
                
                StatBox(
                    title: "Media",
                    value: statistics.formattedAttendanceRate,
                    color: AppTheme.masonicGold
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MonthlyChartCard: View {
    let data: [(month: String, presences: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Andamento Mensile")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            if #available(iOS 16.0, macOS 13.0, *) {
                Chart {
                    ForEach(data, id: \.month) { item in
                        BarMark(
                            x: .value("Mese", item.month),
                            y: .value("Presenze", item.presences)
                        )
                        .foregroundStyle(AppTheme.masonicBlue)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel() {
                            if let month = value.as(String.self) {
                                Text(month)
                                    .font(.caption2)
                            }
                        }
                    }
                }
            } else {
                // Fallback per versioni precedenti
                SimpleBarChart(data: data)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SimpleBarChart: View {
    let data: [(month: String, presences: Int)]
    
    var maxValue: Int {
        data.map { $0.presences }.max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(data.indices, id: \.self) { index in
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.masonicBlue)
                        .frame(height: CGFloat(data[index].presences) / CGFloat(maxValue) * 150)
                    
                    Text(data[index].month.prefix(1))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 200)
    }
}

struct RecentTornateCard: View {
    let tornate: [Tornata]
    let brother: Brother
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ultime Tornate")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            if tornate.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    message: "Nessuna tornata registrata"
                )
                .padding()
            } else {
                ForEach(tornate) { tornata in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tornata.shortDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(tornata.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        PresenceStatusBadge(
                            status: dataService.getPresenceStatus(
                                brotherId: brother.id,
                                tornataId: tornata.id
                            )
                        )
                    }
                    .padding(.vertical, 4)
                    
                    if tornata.id != tornate.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct RecordCard: View {
    let statistics: PresenceStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Record Personali")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Presenze Consecutive")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("\(statistics.consecutivePresences)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicGold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Record Personale")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("\(statistics.personalRecord)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.success)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    PresenzeView(brother: Brother(
        firstName: "Paolo Giulio",
        lastName: "Gazzano",
        email: "demo@kilwinning.it",
        degree: .maestro,
        role: .venerabileMaestro,
        isAdmin: true
    ))
}
