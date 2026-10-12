//
//  DetailPendapatanView.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import SwiftUI

struct DetailPendapatanView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {

                // Sapaan
                VStack(alignment: .leading, spacing: 6) {
                    Text("Good Morning,")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.black)

                    Text("Rafli!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            Color(red: 0.10, green: 0.70, blue: 0.68)
                        )

                    Text("Welcome back to your dashboard")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)

                // Tombol notifikasi
                Button {
                    // TODO: Buka halaman notifikasi
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 23, weight: .regular))
                            .foregroundStyle(.black.opacity(0.75))
                            .frame(width: 50, height: 50)
                            .background(.white.opacity(0.85))
                            .clipShape(Circle())

                        Circle()
                            .fill(
                                Color(red: 0.10, green: 0.70, blue: 0.68)
                            )
                            .frame(width: 15, height: 15)
                            .overlay {
                                Text("3")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .offset(x: -2, y: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("3 notifikasi")
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(red: 0.91, green: 0.97, blue: 0.98)
            )
    }
}

#Preview {
    DetailPendapatanView()
}
