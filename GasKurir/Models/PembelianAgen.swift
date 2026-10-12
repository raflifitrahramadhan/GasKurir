//
//  PembelianAgen.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//

import Foundation
import SwiftData

@Model
final class PembelianAgen {
    @Attribute(.unique) var id: UUID
    var tanggal: Date
    var jumlahIsiDibeli: Int
    var jumlahKosongDisetor: Int
    var totalHarga: Decimal
    var catatan: String?

    init(
        tanggal: Date = .now,
        jumlahIsiDibeli: Int,
        jumlahKosongDisetor: Int,
        totalHarga: Decimal,
        catatan: String? = nil
    ) {
        self.id = UUID()
        self.tanggal = tanggal
        self.jumlahIsiDibeli = jumlahIsiDibeli
        self.jumlahKosongDisetor = jumlahKosongDisetor
        self.totalHarga = totalHarga
        self.catatan = catatan
    }
}
