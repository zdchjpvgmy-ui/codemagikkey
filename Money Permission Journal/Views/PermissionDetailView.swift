//
//  PermissionDetailView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct PermissionDetailView: View {
    let permission: MoneyPermission
    @State var viewModel: PermissionViewModel
    @State private var showingEdit = false
    @State private var showingOutcomeUpdate = false
    @State private var currentPermission: MoneyPermission
    @Environment(\.dismiss) var dismiss
    
    init(permission: MoneyPermission, viewModel: PermissionViewModel) {
        self.permission = permission
        _viewModel = State(initialValue: viewModel)
        _currentPermission = State(initialValue: permission)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statementSection
                
                categoryAndTagsSection
                
                intentOutcomeSection
                
                emotionalImpactSection
                
                actionButtons
                
                Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            .padding(24)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Permission Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            PermissionFormView(permission: currentPermission, viewModel: viewModel)
        }
        .sheet(isPresented: $showingOutcomeUpdate) {
            OutcomeUpdateView(permission: currentPermission, viewModel: viewModel)
        }
        .onChange(of: showingEdit) { _, isShowing in
            if !isShowing {
                // Refresh permission after editing
                refreshPermission()
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
        .onChange(of: showingOutcomeUpdate) { _, isShowing in
            if !isShowing {
                // Refresh permission after updating outcome
                refreshPermission()
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
        .onAppear {
            refreshPermission()
        }
    }
    
    private func refreshPermission() {
        let context = PersistenceController.shared.container.viewContext
        context.refresh(currentPermission, mergeChanges: true)
        // Force view update
        let refreshed = currentPermission
        currentPermission = refreshed
    }
    
    private var statementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentPermission.statement)
                .font(.custom("Georgia", size: 32))
                .foregroundColor(.primary)
                .lineSpacing(8)
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var categoryAndTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let category = currentPermission.category {
                HStack {
                    Text("Category:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(category)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appSkyBlue.opacity(0.2))
                        )
                }
            }
            
            if !currentPermission.emotionalTags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(currentPermission.emotionalTags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.appGentleLavender.opacity(0.3))
                                )
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var intentOutcomeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let expectedImpact = currentPermission.expectedImpact, !expectedImpact.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Expected Impact")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(expectedImpact)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.appSoftGold.opacity(0.15))
                )
            }
            
            if let actualOutcome = currentPermission.actualOutcome, !actualOutcome.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actual Outcome")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(actualOutcome)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.appSkyBlue.opacity(0.15))
                )
            } else {
                Button(action: {
                    showingOutcomeUpdate = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Outcome")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.appSkyBlue, Color.appGentleLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(24)
                }
            }
        }
    }
    
    @ViewBuilder
    private var emotionalImpactSection: some View {
        if currentPermission.emotionalImpact > 0 {
            VStack(alignment: .leading, spacing: 12) {
                Text("Emotional Impact")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                HStack {
                    ForEach(1...10, id: \.self) { index in
                        Circle()
                            .fill(index <= Int(currentPermission.emotionalImpact) ? Color.appSoftGold : Color.gray.opacity(0.2))
                            .frame(width: 20, height: 20)
                    }
                    
                    Spacer()
                    
                    Text("\(currentPermission.emotionalImpact)/10")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appSoftGold)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingEdit = true
            }) {
                Text("Edit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appSkyBlue)
                    .cornerRadius(24)
            }
            
            Button(action: {
                viewModel.deletePermission(currentPermission)
                NotificationCenter.default.post(name: NSNotification.Name("PermissionDataChanged"), object: nil)
                dismiss()
            }) {
                Text("Archive")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appGentleLavender)
                    .cornerRadius(24)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        PermissionDetailView(
            permission: MoneyPermission(context: PersistenceController.shared.container.viewContext),
            viewModel: PermissionViewModel(context: PersistenceController.shared.container.viewContext)
        )
    }
}
