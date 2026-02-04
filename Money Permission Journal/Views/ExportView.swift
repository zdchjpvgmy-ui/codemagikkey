//
//  ExportView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI
import UIKit
import PDFKit

struct ExportView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showingPermissionPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    exportOptions
                    
                    Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Export & Liberation")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: shareItems)
            }
            .sheet(isPresented: $showingPermissionPicker) {
                PermissionPickerView(viewModel: viewModel) { permission in
                    shareSinglePermission(permission)
                }
            }
        }
    }
    
    private var exportOptions: some View {
        VStack(spacing: 24) {
            ExportOptionCard(
                title: "Export All Permissions",
                description: "Generate a beautiful PDF journal of all your permissions",
                icon: "doc.text",
                color: .appSkyBlue
            ) {
                exportPDF()
            }
            
            if !viewModel.allPermissions.isEmpty {
                ExportOptionCard(
                    title: "Share Single Permission",
                    description: "Create an inspirational card from any permission",
                    icon: "square.and.arrow.up",
                    color: .appSoftGold
                ) {
                    showingPermissionPicker = true
                }
            }
        }
    }
    
    private func exportPDF() {
        let pdfData = generatePDF()
        shareItems = [pdfData]
        showingShareSheet = true
    }
    
    private func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Money Permission Journal",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "My Money Permissions Journal"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            var yPosition: CGFloat = 72
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.label
            ]
            let title = "My Money Permissions Journal"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Year
            let yearAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let year = "\(Calendar.current.component(.year, from: Date()))"
            year.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: yearAttributes)
            yPosition += 40
            
            // Permissions
            let permissions = viewModel.allPermissions.sorted { $0.date > $1.date }
            
            for permission in permissions {
                // Check if we need a new page
                if yPosition > pageHeight - 150 {
                    context.beginPage()
                    yPosition = 72
                }
                
                // Statement
                let statementAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ]
                let statement = permission.statement
                let statementRect = CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 0)
                let boundingRect = statement.boundingRect(
                    with: CGSize(width: statementRect.width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: statementAttributes,
                    context: nil
                )
                statement.draw(in: CGRect(x: 72, y: yPosition, width: boundingRect.width, height: boundingRect.height), withAttributes: statementAttributes)
                yPosition += boundingRect.height + 12
                
                // Date and Impact
                let detailAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                var details = "Date: \(dateFormatter.string(from: permission.date))"
                if permission.emotionalImpact > 0 {
                    details += " • Impact: \(permission.emotionalImpact)/10"
                }
                if let category = permission.category {
                    details += " • Category: \(category)"
                }
                details.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: detailAttributes)
                yPosition += 20
                
                // Outcome if available
                if let outcome = permission.actualOutcome, !outcome.isEmpty {
                    let outcomeAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.italicSystemFont(ofSize: 12),
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                    let outcomeText = "Outcome: \(outcome)"
                    let outcomeRect = CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 0)
                    let outcomeBoundingRect = outcomeText.boundingRect(
                        with: CGSize(width: outcomeRect.width, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: outcomeAttributes,
                        context: nil
                    )
                    outcomeText.draw(in: CGRect(x: 72, y: yPosition, width: outcomeBoundingRect.width, height: outcomeBoundingRect.height), withAttributes: outcomeAttributes)
                    yPosition += outcomeBoundingRect.height + 20
                }
                
                yPosition += 20
            }
        }
        
        return data
    }
    
    private func shareSinglePermission(_ permission: MoneyPermission) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var shareText = permission.statement + "\n\n"
        shareText += "Date: \(dateFormatter.string(from: permission.date))\n"
        if permission.emotionalImpact > 0 {
            shareText += "Emotional Impact: \(permission.emotionalImpact)/10\n"
        }
        if let category = permission.category {
            shareText += "Category: \(category)\n"
        }
        if !permission.emotionalTags.isEmpty {
            shareText += "Tags: \(permission.emotionalTags.joined(separator: ", "))\n"
        }
        if let outcome = permission.actualOutcome, !outcome.isEmpty {
            shareText += "\nOutcome: \(outcome)\n"
        }
        
        shareItems = [shareText]
        showingShareSheet = true
    }
}

struct ExportOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(color.opacity(0.2))
                        )
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.custom("Georgia", size: 22))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }
}

struct PermissionPickerView: View {
    let viewModel: PermissionViewModel
    let onSelect: (MoneyPermission) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.allPermissions.sorted { $0.date > $1.date }) { permission in
                    Button(action: {
                        onSelect(permission)
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(permission.statement)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            Text(permission.date, style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Select Permission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
}
