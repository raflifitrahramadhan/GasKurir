//
//  BerandaRepositories.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//
//  Satu-satunya tempat yang "bicara" ke SwiftData untuk kebutuhan Beranda.
//  ViewModel cukup minta ringkasan, tanpa tahu cara menghitungnya.
//

import Foundation
import SwiftData

struct PengingatTabung {
    let namaWarung: String
    let hari: Int
    let jumlahTabung: Int
}

struct RingkasanBeranda {
    var namaKurir: String
    var stokIsi: Int
    var stokKosong: Int
    var tabungDiPelanggan: Int
    var tabungTerjualHariIni: Int
    var dataPenjualan: [TitikPenjualan]
    var pengingat: PengingatTabung?
}

struct BerandaRepository {

    let context: ModelContext

    func ringkasan(sekarang: Date = .now) throws -> RingkasanBeranda {
        let konfigurasi = try Konfigurasi.current(in: context)
        let transaksi = try context.fetch(FetchDescriptor<Transaksi>())
        let pembelian = try context.fetch(FetchDescriptor<PembelianAgen>())

        // Stok dihitung ulang dari riwayat, tidak disimpan sebagai angka.
        let isiMasuk = pembelian.reduce(0) { $0 + $1.jumlahIsiDibeli }
        let kosongKeluar = pembelian.reduce(0) { $0 + $1.jumlahKosongDisetor }
        let isiKeluar = transaksi.reduce(0) { $0 + $1.jumlahIsiDiberikan }
        let kosongMasuk = transaksi.reduce(0) { $0 + $1.jumlahKosongDiterima }

        let kalender = Calendar.current
        let terjualHariIni = transaksi
            .filter { kalender.isDate($0.tanggal, inSameDayAs: sekarang) }
            .reduce(0) { $0 + $1.jumlahIsiDiberikan }

        return RingkasanBeranda(
            namaKurir: konfigurasi.namaAgen,
            stokIsi: isiMasuk - isiKeluar,
            stokKosong: kosongMasuk - kosongKeluar,
            tabungDiPelanggan: isiKeluar - kosongMasuk,
            tabungTerjualHariIni: terjualHariIni,
            dataPenjualan: titikPenjualan(dari: transaksi, sekarang: sekarang),
            pengingat: cariPengingat(
                dari: transaksi,
                ambangHari: konfigurasi.reminderTabungHari,
                sekarang: sekarang
            )
        )
    }

    // MARK: - Grafik penjualan

    /// Blok 2 jam (00.00 ... 22.00), hanya sampai jam sekarang.
    /// "sebelumnya" = blok jam yang sama kemarin.
    private func titikPenjualan(dari transaksi: [Transaksi], sekarang: Date) -> [TitikPenjualan] {
        let kalender = Calendar.current
        let kemarin = kalender.date(byAdding: .day, value: -1, to: sekarang) ?? sekarang

        var hariIni = Array(repeating: 0.0, count: 12)
        var hariKemarin = Array(repeating: 0.0, count: 12)

        for t in transaksi {
            let blok = kalender.component(.hour, from: t.tanggal) / 2
            if kalender.isDate(t.tanggal, inSameDayAs: sekarang) {
                hariIni[blok] += Double(t.jumlahIsiDiberikan)
            } else if kalender.isDate(t.tanggal, inSameDayAs: kemarin) {
                hariKemarin[blok] += Double(t.jumlahIsiDiberikan)
            }
        }

        // Minimal 2 blok supaya garis tetap terlihat dini hari
        let jumlahBlok = max(2, kalender.component(.hour, from: sekarang) / 2 + 1)

        return (0..<jumlahBlok).map { blok in
            TitikPenjualan(
                waktu: String(format: "%02d.00", blok * 2),
                penjualan: hariIni[blok],
                sebelumnya: hariKemarin[blok]
            )
        }
    }

    // MARK: - Pengingat

    /// Warung yang masih menahan tabung paling lama, dan sudah melewati ambang hari.
    private func cariPengingat(
        dari transaksi: [Transaksi],
        ambangHari: Int,
        sekarang: Date
    ) -> PengingatTabung? {
        let berWarung = transaksi.compactMap { t in
            t.warung.map { (warung: $0, transaksi: t) }
        }
        let perWarung = Dictionary(grouping: berWarung, by: { $0.warung.id })

        var terburuk: PengingatTabung?

        for (_, item) in perWarung {
            let jumlah = item.reduce(0) { $0 + $1.transaksi.selisihTabung }
            guard jumlah > 0,
                  let terakhir = item.map({ $0.transaksi.tanggal }).max()
            else { continue }

            let hari = Calendar.current.dateComponents([.day], from: terakhir, to: sekarang).day ?? 0
            guard hari >= ambangHari else { continue }

            if hari > (terburuk?.hari ?? -1) {
                terburuk = PengingatTabung(
                    namaWarung: item[0].warung.nama,
                    hari: hari,
                    jumlahTabung: jumlah
                )
            }
        }
        return terburuk
    }
}
