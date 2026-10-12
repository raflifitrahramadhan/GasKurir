//
//  RootTabView.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import SwiftUI

enum AppTab: Hashable {
    case beranda, transaksi, laporan, pengaturan
}

struct RootTabView: View {

    @State private var selectedTab: AppTab = .beranda
    @State private var tampilkanFormTambah = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Beranda", systemImage: "house.fill", value: AppTab.beranda) { BerandaView() }
            Tab("Transaksi", systemImage: "scroll.fill", value: AppTab.transaksi) { TransaksiView() }
            Tab("Laporan", systemImage: "chart.bar.fill", value: AppTab.laporan) { LaporanView() }
            Tab("Pengaturan", systemImage: "gearshape.fill", value: AppTab.pengaturan) { PengaturanView() }
        }
        .tint(Color.biruAksen)
        .tabBarMinimizeBehavior(.onScrollDown)
        // Pengganti tombol "+" tengah: aksi utama yang selalu tersedia di atas tab bar
        .tabViewBottomAccessory { tombolTambah }
        .sheet(isPresented: $tampilkanFormTambah) {
            FormTambahPlaceholderView()
        }
    }

    private var tombolTambah: some View {
        Button {
            tampilkanFormTambah = true
        } label: {
            Label("Tambah Transaksi", systemImage: "plus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.biruAksen)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// Ganti dengan form tambah transaksi Anda yang sebenarnya.
private struct FormTambahPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Form Transaksi",
                systemImage: "square.and.pencil",
                description: Text("Ganti tampilan ini dengan form tambah transaksi.")
            )
            .navigationTitle("Tambah Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    RootTabView()
}
