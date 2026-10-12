//
//  BerandaView.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import SwiftUI
import Charts

// MARK: - Warna

extension Color {
    /// Teal brand, sedikit lebih gelap agar kontras teks di atas latar putih lebih terbaca.
    static let aksen = Color(red: 0.04, green: 0.56, blue: 0.54)
    static let periodeSebelumnya = Color(red: 0.50, green: 0.56, blue: 0.85)
}


// MARK: - Beranda

struct BerandaView: View {

    @StateObject private var viewModel = BerandaViewModel()
    @State private var adaNotifikasi = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // 2 kolom normal, 1 kolom saat ukuran teks aksesibilitas (Dynamic Type besar)
    private var kolom: [GridItem] {
        let jumlah = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: jumlah)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                kartuStatistik
                grafikPenjualan
                pengingatTabung
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.sapaan)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Rafli!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.aksen)

                Text(viewModel.sapaan1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            tombolNotifikasi
        }
    }

    private var tombolNotifikasi: some View {
        Button {
            // TODO: buka halaman notifikasi
        } label: {
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(Color.aksen)
                .frame(width: 44, height: 44) // target sentuh minimal HIG
                .overlay(alignment: .topTrailing) {
                    if adaNotifikasi {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle().stroke(Color(.systemGroupedBackground), lineWidth: 2)
                            )
                            .padding(10)
                    }
                }
        }
        .accessibilityLabel("Notifikasi")
        .accessibilityValue(adaNotifikasi ? "Ada yang baru" : "Tidak ada yang baru")
    }

    // MARK: Kartu statistik

    private var kartuStatistik: some View {
        LazyVGrid(columns: kolom, spacing: 12) {
            KartuStatistikView(
                judul: "Tabung Isi",
                nilai: "\(viewModel.stokTabungIsi)",
                ikon: "flame.fill",
                warna: Color(red: 0.93, green: 0.30, blue: 0.46)
            )
            KartuStatistikView(
                judul: "Tabung Kosong",
                nilai: "\(viewModel.stokTabungKosong)",
                ikon: "flame",
                warna: Color(red: 0.96, green: 0.45, blue: 0.57)
            )
            KartuStatistikView(
                judul: "Tabung Tertinggal",
                nilai: "\(viewModel.tabungDiPelanggan)",
                ikon: "arrow.left.arrow.right",
                warna: .periodeSebelumnya
            )
            KartuStatistikView(
                judul: "Terjual Hari Ini",
                nilai: "\(viewModel.tabungTerjualHariIni)",
                ikon: "shippingbox.fill",
                warna: Color(red: 87.0 / 255, green: 89.0 / 255, blue: 201.0 / 255)
            )
        }
    }

    // MARK: Grafik

    private var grafikPenjualan: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Penjualan Hari Ini")
                .font(.headline)

            Chart {
                ForEach(viewModel.dataPenjualan) { titik in
                    // Area di bawah garis "Hari ini"
                    AreaMark(
                        x: .value("Waktu", titik.waktu),
                        yStart: .value("Dasar", 0),
                        yEnd: .value("Jumlah", titik.penjualan),
                        series: .value("Seri", "Hari ini")
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange.opacity(0.25), .orange.opacity(0.01)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.monotone)

                    // Setiap garis punya series sendiri -> tidak lagi tersambung zig-zag
                    LineMark(
                        x: .value("Waktu", titik.waktu),
                        y: .value("Jumlah", titik.penjualan)
                    )
                    .foregroundStyle(by: .value("Seri", "Hari ini"))
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .interpolationMethod(.monotone)

                    LineMark(
                        x: .value("Waktu", titik.waktu),
                        y: .value("Jumlah", titik.sebelumnya)
                    )
                    .foregroundStyle(by: .value("Seri", "Periode sebelumnya"))
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    .interpolationMethod(.monotone)
                }
            }
            .chartForegroundStyleScale([
                "Hari ini": Color.orange,
                "Periode sebelumnya": Color.periodeSebelumnya
            ])
            .chartYScale(domain: .automatic(includesZero: true))
            // Hanya 4 label agar tidak sesak di iPhone SE
            .chartXAxis {
                AxisMarks(values: ["00.00", "06.00", "12.00", "18.00"]) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.2))
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartLegend(position: .bottom, alignment: .leading, spacing: 12)
            .frame(height: 200)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: .rect(cornerRadius: 20, style: .continuous)
        )
    }

    // MARK: Pengingat

    @ViewBuilder
    private var pengingatTabung: some View {
        if viewModel.adaPengingat {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pengingat Tabung")
                        .font(.subheadline.weight(.semibold))

                    Text("\(viewModel.namaWarungTerlambat) belum mengembalikan tabung selama \(viewModel.hariBelumKembali) hari.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: .rect(cornerRadius: 16, style: .continuous)
            )
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - Komponen Kartu

private struct KartuStatistikView: View {

    let judul: String
    let nilai: String
    let ikon: String
    let warna: Color

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var ukuranIkon: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: ikon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(warna)
                .frame(width: ukuranIkon, height: ukuranIkon)
                .background(
                    warna.opacity(0.15),
                    in: .rect(cornerRadius: 10, style: .continuous)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(nilai)
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(judul)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    // 1 baris agar tinggi kartu seragam; boleh membungkus di ukuran teks aksesibilitas
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: .rect(cornerRadius: 20, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview("Beranda") {
    BerandaView()
}
