//
//  BerandaView.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import SwiftUI
import Charts
import SwiftData

struct BerandaView: View {

    @StateObject private var viewModel = BerandaViewModel()
    @State private var adaNotifikasi = true
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var ukuranAngka: CGFloat = 52

    // 3 tile sejajar normal, 1 kolom saat ukuran teks aksesibilitas
    private var kolomStok: [GridItem] {
        let jumlah = dynamicTypeSize.isAccessibilitySize ? 1 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .top), count: jumlah)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                kartuUtama
                kartuUtama

                seksi("Stok & distribusi") { tileStok }
                seksi("Penjualan hari ini") { grafikPenjualan }

                if viewModel.adaPengingat {
                    seksi("Pengingat") { pengingatTabung }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .background(Color.latar.ignoresSafeArea())
        .task { viewModel.muat(context: modelContext) }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave, object: modelContext)) { _ in
            viewModel.muat(context: modelContext)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.sapaan)
                        .font(.footnote.bold())
                        .foregroundStyle(.primary)
                    Text("\(viewModel.namaKurir)!")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }

                Spacer(minLength: 0)
                tombolNotifikasi
            }

            Text(viewModel.sapaan1)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tombolNotifikasi: some View {
        Button {
            // TODO: buka halaman notifikasi
            print("Notif Ditekan")
        } label: {
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44) // target sentuh minimal HIG
                .background(Color.kartu, in: .circle)
                .overlay(alignment: .topTrailing) {
                    if adaNotifikasi {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.kartu, lineWidth: 2))
                            .padding(8)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifikasi")
        .accessibilityValue(adaNotifikasi ? "Ada yang baru" : "Tidak ada yang baru")
    }

    // MARK: - Kartu utama

    private var kartuUtama: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Tabung Isi", systemImage: "flame.fill")
                .font(.subheadline.weight(.medium))

            Text("\(viewModel.stokTabungIsi)")
                .font(.system(size: ukuranAngka, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("siap diantar")
                .font(.footnote)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.biru)
        .overlay(alignment: .bottomTrailing) {
            // Hiasan halus, tidak dibaca VoiceOver
            Image(systemName: "flame.fill")
                .font(.system(size: 110))
                .foregroundStyle(.white.opacity(0.12))
                .offset(x: 24, y: 24)
                .accessibilityHidden(true)
        }
        .clipShape(.rect(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tabung isi")
        .accessibilityValue("\(viewModel.stokTabungIsi), siap diantar")
    }

    // MARK: - Tile stok

    private var tileStok: some View {
        LazyVGrid(columns: kolomStok, spacing: 10) {
            TileStokView(judul: "Tabung Kosong", nilai: "\(viewModel.stokTabungKosong)",
                         ikon: "flame", warna: .tileBiru)
            TileStokView(judul: "Tabung Tertinggal", nilai: "\(viewModel.tabungDiPelanggan)",
                         ikon: "arrow.left.arrow.right", warna: .tileMerah)
            TileStokView(judul: "Tabung Terjual", nilai: "\(viewModel.tabungTerjualHariIni)",
                         ikon: "shippingbox.fill", warna: .tileNavy)
        }
    }

    // MARK: - Grafik

    private var grafikPenjualan: some View {
        Chart(viewModel.dataPenjualan) { titik in
            AreaMark(
                x: .value("Waktu", titik.waktu),
                yStart: .value("Dasar", 0),
                yEnd: .value("Jumlah", titik.penjualan),
                series: .value("Seri", "Hari ini")
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.biruAksen.opacity(0.25), Color.biruAksen.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(x: .value("Waktu", titik.waktu), y: .value("Jumlah", titik.penjualan))
                .foregroundStyle(by: .value("Seri", "Hari ini"))
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

            LineMark(x: .value("Waktu", titik.waktu), y: .value("Jumlah", titik.sebelumnya))
                .foregroundStyle(by: .value("Seri", "Periode sebelumnya"))
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4]))
        }
        .chartForegroundStyleScale([
            "Hari ini": Color.biruAksen,
            "Periode sebelumnya": Color.secondary.opacity(0.6)
        ])
        .chartYScale(domain: .automatic(includesZero: true))
        .chartXAxis {
            AxisMarks(values: ["00.00", "06.00", "12.00", "18.00"]) { _ in
                AxisValueLabel().font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine().foregroundStyle(Color.secondary.opacity(0.2))
                AxisValueLabel().font(.caption2)
            }
        }
        .chartLegend(position: .bottom, alignment: .leading, spacing: 12)
        .frame(height: 200)
        .gayaKartu()
    }

    // MARK: - Pengingat

    private var pengingatTabung: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.14), in: .rect(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pengingat Tabung")
                    .font(.subheadline.weight(.semibold))

                Text("\(viewModel.namaWarungTerlambat) belum mengembalikan tabung selama \(viewModel.hariBelumKembali) hari.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .gayaKartu()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Seksi

    private func seksi<Content: View>(
        _ judul: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(judul)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

// MARK: - Gaya kartu

private extension View {
    /// Kartu putih/abu sistem dengan sudut membulat, dipakai grafik dan pengingat.
    func gayaKartu() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.kartu, in: .rect(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Tile

private struct TileStokView: View {

    let judul: String
    let nilai: String
    let ikon: String
    let warna: Color

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var ukuranIkon: CGFloat = 36

    var body: some View {
        // 2 baris dicadangkan agar tinggi semua tile sama; bebas membungkus di teks aksesibilitas
        let aksesibilitas = dynamicTypeSize.isAccessibilitySize

        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: ikon)
                .font(.subheadline.weight(.semibold))
                .frame(width: ukuranIkon, height: ukuranIkon)
                .background(.white.opacity(0.2), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(nilai)
                    .font(.title2.bold())
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(judul)
                    .font(.footnote)
                    .lineLimit(aksesibilitas ? Int.max : 2, reservesSpace: !aksesibilitas)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(warna, in: .rect(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Beranda") {
    BerandaView().modelContainer(PreviewData.container)
}
