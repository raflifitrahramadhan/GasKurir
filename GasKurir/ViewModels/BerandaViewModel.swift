//
//  BerandaViewModel.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import Foundation
import Combine
import SwiftData

struct GreetingManager {
    let currentHour: Int

    init(date: Date = Date()) {
        self.currentHour = Calendar.current.component(.hour, from: date)
    }

    var sapaan: String {
        switch currentHour {
        case 5..<10:
            return "Selamat Pagi"
        case 10..<14:
            return "Selamat Siang"
        case 14..<18:
            return "Selamat Sore"
        default:
            return "Selamat Malam"
        }
    }

    var sapaan1: String {
        switch currentHour {
        case 5..<18:
            return "Mau Ngirim Kemana Hari Ini?"
        default:
            return "Masih Ada Pengantaran Jam Segini?"
        }
    }
}

struct TitikPenjualan: Identifiable {
    let id = UUID()
    let waktu: String
    let penjualan: Double
    let sebelumnya: Double
}

@MainActor
final class BerandaViewModel: ObservableObject {

    // Sapaan
    var sapaan: String {
        let manager: GreetingManager = GreetingManager()
        return manager.sapaan
    }

    var sapaan1: String {
        let manager: GreetingManager = GreetingManager()
        return manager.sapaan1
    }

    // Data ringkasan (diisi dari SwiftData lewat muat(context:))
    @Published var namaKurir = "Kurir"
    @Published var stokTabungIsi = 0
    @Published var stokTabungKosong = 0
    @Published var tabungDiPelanggan = 0
    @Published var tabungTerjualHariIni = 0

    // Data grafik
    @Published var dataPenjualan: [TitikPenjualan] = []

    // Pengingat tabung (warung yang paling lama menahan tabung)
    @Published var namaWarungTerlambat = ""
    @Published var hariBelumKembali = 0
    @Published var tabungHilang = 0   // jumlah tabung yang belum kembali dari warung tsb

    // Kalau pembacaan database gagal
    @Published var pesanKesalahan: String?

    var adaPengingat: Bool {
        !namaWarungTerlambat.isEmpty
    }

    /// Dipanggil View saat muncul dan setiap kali data tersimpan.
    func muat(context: ModelContext) {
        do {
            let hasil = try BerandaRepository(context: context).ringkasan()

            namaKurir = hasil.namaKurir.isEmpty ? "Kurir" : hasil.namaKurir
            stokTabungIsi = hasil.stokIsi
            stokTabungKosong = hasil.stokKosong
            tabungDiPelanggan = hasil.tabungDiPelanggan
            tabungTerjualHariIni = hasil.tabungTerjualHariIni
            dataPenjualan = hasil.dataPenjualan

            namaWarungTerlambat = hasil.pengingat?.namaWarung ?? ""
            hariBelumKembali = hasil.pengingat?.hari ?? 0
            tabungHilang = hasil.pengingat?.jumlahTabung ?? 0

            pesanKesalahan = nil
        } catch {
            pesanKesalahan = error.localizedDescription
        }
    }
}
