//
//  PreviewData.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//
//  Database sementara (di memori) berisi data contoh, khusus untuk #Preview.
//  Pakai: BerandaView().modelContainer(PreviewData.container)
//

import Foundation
import SwiftData

@MainActor
enum PreviewData {

    // try! hanya di helper preview ini, kalau gagal biarkan crash agar ketahuan.
    static let container: ModelContainer = {
        let konfigurasi = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Warung.self, Transaksi.self, PembelianAgen.self, Konfigurasi.self,
            configurations: konfigurasi
        )
        PreviewData.isi(container.mainContext)
        return container
    }()

    private static func isi(_ context: ModelContext) {
        context.insert(Konfigurasi(namaAgen: "Rafli", hargaSatuanDefault: 20_000))

        let ida = Warung(nama: "Warung Teh Ida")
        let maju = Warung(nama: "Warung Maju")
        let joko = Warung(nama: "Pak Joko")
        let sari = Warung(nama: "Toko Sari")
        [ida, maju, joko, sari].forEach { context.insert($0) }

        context.insert(PembelianAgen(
            tanggal: waktu(hariLalu: 14, jam: 8),
            jumlahIsiDibeli: 70, jumlahKosongDisetor: 30, totalHarga: 1_190_000
        ))
        context.insert(PembelianAgen(
            tanggal: waktu(hariLalu: 7, jam: 8),
            jumlahIsiDibeli: 50, jumlahKosongDisetor: 30, totalHarga: 850_000
        ))

        func tx(_ hariLalu: Int, _ jam: Int, _ w: Warung, _ isi: Int, _ kosong: Int, bayar: Decimal? = nil) {
            let total = Decimal(isi) * 20_000
            context.insert(Transaksi(
                warung: w,
                tanggal: waktu(hariLalu: hariLalu, jam: jam),
                jumlahIsiDiberikan: isi,
                jumlahKosongDiterima: kosong,
                hargaSatuanSaatItu: 20_000,
                totalHarga: total,
                jumlahDibayar: bayar ?? total
            ))
        }

        tx(12, 9, ida, 5, 5);  tx(12, 10, maju, 6, 6)
        tx(11, 9, joko, 4, 4); tx(10, 9, sari, 3, 3)
        tx(9, 9, ida, 5, 5);   tx(9, 11, maju, 6, 6)
        tx(8, 9, joko, 4, 4);  tx(6, 9, sari, 3, 3)
        tx(6, 11, maju, 6, 6)
        tx(5, 9, ida, 5, 2)            // Teh Ida: 3 tabung belum kembali, terakhir 5 hari lalu
        tx(4, 9, sari, 3, 3);  tx(3, 9, joko, 6, 6)
        tx(2, 9, maju, 6, 6)
        tx(1, 8, maju, 6, 6);  tx(1, 10, sari, 4, 4); tx(1, 14, joko, 5, 5)
        tx(0, 8, maju, 6, 6);  tx(0, 10, sari, 4, 3, bayar: 40_000); tx(0, 14, joko, 5, 4, bayar: 0)

        try? context.save()
    }

    /// Jam tertentu pada N hari lalu. Tidak pernah melewati "sekarang",
    /// supaya preview yang dibuka pagi hari tidak berisi transaksi di masa depan.
    private static func waktu(hariLalu: Int, jam: Int) -> Date {
        let kalender = Calendar.current
        let awalHari = kalender.startOfDay(for: .now)
        let hari = kalender.date(byAdding: .day, value: -hariLalu, to: awalHari) ?? awalHari
        let target = kalender.date(bySettingHour: jam, minute: 0, second: 0, of: hari) ?? hari
        return min(target, Date.now.addingTimeInterval(-60))
    }
}
