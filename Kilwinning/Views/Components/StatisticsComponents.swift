import SwiftUI

// MARK: - StatItem Component

/// Reusable statistics item component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .blue

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - TornataCard Component

/// Reusable tornata card component
struct TornataCard: View {
    let tornata: Tornata
    var showActions: Bool = false
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and status
            HStack {
                Text(tornata.data, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                StatoBadge(stato: tornata.stato)
            }

            // Discussion/Title
            Text(tornata.discussione)
                .font(.headline)
                .foregroundColor(.primary)

            // Location
            Label {
                Text(tornata.location)
                    .font(.subheadline)
            } icon: {
                Image(systemName: "mappin.circle.fill")
            }
            .foregroundColor(.secondary)

            // Dinner indicator
            if tornata.cena {
                Label {
                    Text("Cena")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "fork.knife")
                }
                .foregroundColor(.orange)
            }

            // Admin actions
            if showActions {
                HStack(spacing: 12) {
                    Button(action: { onEdit?() }) {
                        Label("Modifica", systemImage: "pencil")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    Button(action: { onDelete?() }) {
                        Label("Elimina", systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - StatoBadge Component

/// Status badge for tornate
struct StatoBadge: View {
    let stato: String

    var body: some View {
        Text(stato.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }

    private var badgeColor: Color {
        switch stato.lowercased() {
        case "programmata":
            return .blue
        case "completata":
            return .green
        case "annullata":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - ProgressBar Component

/// Reusable progress bar component
struct ProgressBar: View {
    let value: Int // 0-100
    var height: CGFloat = 24
    var showPercentage: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)

                // Progress
                Rectangle()
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(value) / 100, height: height)

                // Percentage text
                if showPercentage {
                    Text("\(value)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: height)
        .cornerRadius(4)
    }

    private var progressColor: Color {
        switch value {
        case 90...100:
            return .green
        case 70..<90:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - ConsecutiveBadge Component

/// Badge showing consecutive presences with fire emoji
struct ConsecutiveBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.title3)

            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(12)
    }
}

// MARK: - DegreeBadge Component

/// Badge showing masonic degree with icon
struct DegreeBadge: View {
    let grado: String

    var body: some View {
        HStack(spacing: 4) {
            Text(degreeIcon)
                .font(.caption)

            Text(grado)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.blue)
        .cornerRadius(8)
    }

    private var degreeIcon: String {
        switch grado.lowercased() {
        case "maestro", "maestri":
            return "🔶"
        case "compagno", "compagni":
            return "🔷"
        case "apprendista", "apprendisti":
            return "🔹"
        default:
            return "◆"
        }
    }
}

// MARK: - StatisticsCard Component

/// Card showing fratello statistics
struct StatisticsCard: View {
    let statistics: PresenceStatistics

    var body: some View {
        VStack(spacing: 16) {
            Text("Le Mie Statistiche")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatItem(
                    icon: "list.bullet",
                    value: "\(statistics.totalTornate)",
                    label: "Tornate",
                    color: .blue
                )

                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(statistics.presences)",
                    label: "Presenze",
                    color: .green
                )

                StatItem(
                    icon: "percent",
                    value: statistics.formattedAttendanceRate,
                    label: "Percentuale",
                    color: .orange
                )
            }

            // Consecutive presences
            if statistics.consecutivePresences > 0 {
                HStack {
                    Text("Presenze consecutive:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    ConsecutiveBadge(count: statistics.consecutivePresences)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Previews

#Preview("StatItem") {
    StatItem(
        icon: "checkmark.circle.fill",
        value: "24",
        label: "Presenze",
        color: .green
    )
    .padding()
}

#Preview("TornataCard") {
    TornataCard(
        tornata: Tornata(
            id: 1,
            title: "Discussione sulla filosofia massonica",
            date: Date(),
            type: .ordinaria,
            introducedBy: "Fr. Mario Rossi",
            hasDinner: true,
            stato: "programmata",
            status: .programmata
        ),
        showActions: true
    )
    .padding()
}

#Preview("ProgressBar") {
    VStack(spacing: 20) {
        ProgressBar(value: 95)
        ProgressBar(value: 75)
        ProgressBar(value: 45)
    }
    .padding()
}

#Preview("ConsecutiveBadge") {
    ConsecutiveBadge(count: 12)
}

#Preview("DegreeBadge") {
    HStack {
        DegreeBadge(grado: "Maestro")
        DegreeBadge(grado: "Compagno")
        DegreeBadge(grado: "Apprendista")
    }
}
