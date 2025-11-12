//
//  PDFGenerator.swift
//  TestFormApp
//
//  Generates PDF documents from filled forms
//

import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    // A4 size in points (72 points = 1 inch)
    private let pageWidth: CGFloat = 595.2
    private let pageHeight: CGFloat = 841.8
    private let margin: CGFloat = 40

    func generatePDF(from form: FilledForm, template: FormTemplate) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var yPosition: CGFloat = margin

            // Start first page
            context.beginPage()

            // Header
            yPosition = drawHeader(in: context, template: template, y: yPosition)

            // Equipment Info
            if let infoSection = template.sections.first(where: { $0.type == .info }) {
                yPosition = drawEquipmentInfo(
                    in: context,
                    section: infoSection,
                    form: form,
                    startY: yPosition
                )
            }

            // Checklist sections
            for section in template.sections where section.type == .checklist {
                // Check if we need a new page
                if yPosition > pageHeight - margin - 200 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition = drawChecklist(
                    in: context,
                    section: section,
                    form: form,
                    startY: yPosition
                )
            }

            // Issues
            if let issueSection = template.sections.first(where: { $0.type == .issueLog }) {
                if yPosition > pageHeight - margin - 200 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition = drawIssues(
                    in: context,
                    form: form,
                    startY: yPosition
                )
            }

            // Notes
            if let notesSection = template.sections.first(where: { $0.type == .notes }) {
                if yPosition > pageHeight - margin - 150 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition = drawNotes(
                    in: context,
                    form: form,
                    startY: yPosition
                )
            }

            // Attendees - always on new page
            if let attendeeSection = template.sections.first(where: { $0.type == .attendees }) {
                context.beginPage()
                yPosition = margin

                yPosition = drawAttendees(
                    in: context,
                    form: form,
                    startY: yPosition
                )
            }
        }

        return data
    }

    private func drawHeader(
        in context: UIGraphicsPDFRendererContext,
        template: FormTemplate,
        y: CGFloat
    ) -> CGFloat {
        var yPos = y

        // Title
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]

        let titleRect = CGRect(
            x: margin,
            y: yPos,
            width: pageWidth - 2 * margin,
            height: 30
        )

        template.title.draw(in: titleRect, withAttributes: titleAttrs)
        yPos += 40

        // Category and Level
        let subtitleFont = UIFont.systemFont(ofSize: 14)
        let subtitleText = "\(template.category) - Seviye \(template.level)"
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: subtitleFont,
            .foregroundColor: UIColor.gray
        ]

        let subtitleRect = CGRect(
            x: margin,
            y: yPos,
            width: pageWidth - 2 * margin,
            height: 20
        )

        subtitleText.draw(in: subtitleRect, withAttributes: subtitleAttrs)
        yPos += 30

        // Date
        let dateText = "Oluşturulma: \(form.createdDate.formatted(date: .long, time: .shortened))"
        dateText.draw(in: CGRect(x: margin, y: yPos, width: pageWidth - 2 * margin, height: 20), withAttributes: subtitleAttrs)
        yPos += 40

        return yPos
    }

    private func drawEquipmentInfo(
        in context: UIGraphicsPDFRendererContext,
        section: FormSection,
        form: FilledForm,
        startY: CGFloat
    ) -> CGFloat {
        var yPos = startY

        // Section title
        yPos = drawSectionTitle(in: context, title: section.title, y: yPos)

        // Draw fields in a table-like format
        guard let fields = section.fields else { return yPos + 20 }

        let labelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let valueFont = UIFont.systemFont(ofSize: 11)

        for field in fields {
            let value = form.equipmentInfo[field.id] ?? "-"

            // Draw field label
            let labelRect = CGRect(
                x: margin,
                y: yPos,
                width: 150,
                height: 20
            )

            field.label.draw(in: labelRect, withAttributes: [
                .font: labelFont,
                .foregroundColor: UIColor.darkGray
            ])

            // Draw field value
            let valueRect = CGRect(
                x: margin + 160,
                y: yPos,
                width: pageWidth - margin * 2 - 160,
                height: 20
            )

            value.draw(in: valueRect, withAttributes: [
                .font: valueFont,
                .foregroundColor: UIColor.black
            ])

            // Draw line
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: margin, y: yPos + 22))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yPos + 22))
            context.cgContext.strokePath()

            yPos += 25
        }

        return yPos + 20
    }

    private func drawChecklist(
        in context: UIGraphicsPDFRendererContext,
        section: FormSection,
        form: FilledForm,
        startY: CGFloat
    ) -> CGFloat {
        var yPos = startY

        // Section title
        yPos = drawSectionTitle(in: context, title: section.title, y: yPos)

        guard let items = section.items else { return yPos + 20 }

        let responses = form.checklistResponses[section.id]?.items ?? [:]

        // Header
        let headerFont = UIFont.systemFont(ofSize: 9, weight: .bold)
        let cellFont = UIFont.systemFont(ofSize: 9)

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.white
        ]

        // Draw header background
        context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
        context.cgContext.fill(CGRect(
            x: margin,
            y: yPos,
            width: pageWidth - 2 * margin,
            height: 20
        ))

        // Header texts
        "No".draw(in: CGRect(x: margin + 5, y: yPos + 5, width: 30, height: 15), withAttributes: headerAttrs)
        "Açıklama".draw(in: CGRect(x: margin + 40, y: yPos + 5, width: 200, height: 15), withAttributes: headerAttrs)
        "Kontrol Metodu".draw(in: CGRect(x: margin + 280, y: yPos + 5, width: 100, height: 15), withAttributes: headerAttrs)
        "Durum".draw(in: CGRect(x: margin + 390, y: yPos + 5, width: 100, height: 15), withAttributes: headerAttrs)

        yPos += 25

        // Items
        for item in items {
            let status = responses[item.number] ?? .unchecked
            let statusText = status.displayText

            // Check if need new page
            if yPos > pageHeight - margin - 50 {
                context.beginPage()
                yPos = margin
            }

            // Draw row background (alternating colors)
            if item.number % 2 == 0 {
                context.cgContext.setFillColor(UIColor.systemGray6.cgColor)
                context.cgContext.fill(CGRect(
                    x: margin,
                    y: yPos,
                    width: pageWidth - 2 * margin,
                    height: 30
                ))
            }

            let cellAttrs: [NSAttributedString.Key: Any] = [
                .font: cellFont,
                .foregroundColor: UIColor.black
            ]

            // Number
            "\(item.number)".draw(in: CGRect(x: margin + 5, y: yPos + 8, width: 30, height: 15), withAttributes: cellAttrs)

            // Description (truncated if too long)
            let description = item.description.count > 60 ? String(item.description.prefix(57)) + "..." : item.description
            description.draw(in: CGRect(x: margin + 40, y: yPos + 8, width: 230, height: 15), withAttributes: cellAttrs)

            // Control method
            let controlMethod = item.controlMethod ?? "-"
            controlMethod.draw(in: CGRect(x: margin + 280, y: yPos + 8, width: 100, height: 15), withAttributes: cellAttrs)

            // Status with checkmark symbol
            let statusSymbol: String
            switch status {
            case .yes:
                statusSymbol = "☑️ EVET"
            case .no:
                statusSymbol = "☒ HAYIR"
            case .notApplicable:
                statusSymbol = "⊝ N/A"
            case .unchecked:
                statusSymbol = "☐"
            }

            statusSymbol.draw(in: CGRect(x: margin + 390, y: yPos + 8, width: 100, height: 15), withAttributes: cellAttrs)

            // Draw border
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: margin, y: yPos + 30))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yPos + 30))
            context.cgContext.strokePath()

            yPos += 30
        }

        return yPos + 20
    }

    private func drawIssues(
        in context: UIGraphicsPDFRendererContext,
        form: FilledForm,
        startY: CGFloat
    ) -> CGFloat {
        var yPos = startY

        yPos = drawSectionTitle(in: context, title: "Problem Kayıtları", y: yPos)

        if form.issues.isEmpty {
            let font = UIFont.systemFont(ofSize: 11)
            "Problem kaydı bulunmamaktadır.".draw(
                in: CGRect(x: margin, y: yPos, width: pageWidth - 2 * margin, height: 20),
                withAttributes: [.font: font, .foregroundColor: UIColor.gray]
            )
            return yPos + 30
        }

        let font = UIFont.systemFont(ofSize: 9)

        for (index, issue) in form.issues.enumerated() {
            if yPos > pageHeight - margin - 80 {
                context.beginPage()
                yPos = margin
            }

            // Issue box
            context.cgContext.setStrokeColor(UIColor.orange.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.stroke(CGRect(
                x: margin,
                y: yPos,
                width: pageWidth - 2 * margin,
                height: 60
            ))

            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]

            "Problem #\(index + 1) - Madde: \(issue.itemNumber)".draw(
                in: CGRect(x: margin + 5, y: yPos + 5, width: 200, height: 15),
                withAttributes: attrs
            )

            issue.description.draw(
                in: CGRect(x: margin + 5, y: yPos + 20, width: pageWidth - 2 * margin - 10, height: 15),
                withAttributes: attrs
            )

            "Sorumluluk: \(issue.responsibility)".draw(
                in: CGRect(x: margin + 5, y: yPos + 38, width: 300, height: 15),
                withAttributes: attrs
            )

            yPos += 70
        }

        return yPos + 20
    }

    private func drawNotes(
        in context: UIGraphicsPDFRendererContext,
        form: FilledForm,
        startY: CGFloat
    ) -> CGFloat {
        var yPos = startY

        yPos = drawSectionTitle(in: context, title: "Notlar", y: yPos)

        if form.notes.isEmpty {
            let font = UIFont.systemFont(ofSize: 11)
            "Not bulunmamaktadır.".draw(
                in: CGRect(x: margin, y: yPos, width: pageWidth - 2 * margin, height: 20),
                withAttributes: [.font: font, .foregroundColor: UIColor.gray]
            )
            return yPos + 30
        }

        let font = UIFont.systemFont(ofSize: 10)

        for (index, note) in form.notes.enumerated() {
            if yPos > pageHeight - margin - 40 {
                context.beginPage()
                yPos = margin
            }

            "• \(note)".draw(
                in: CGRect(x: margin, y: yPos, width: pageWidth - 2 * margin, height: 30),
                withAttributes: [.font: font, .foregroundColor: UIColor.black]
            )

            yPos += 35
        }

        return yPos + 20
    }

    private func drawAttendees(
        in context: UIGraphicsPDFRendererContext,
        form: FilledForm,
        startY: CGFloat
    ) -> CGFloat {
        var yPos = startY

        yPos = drawSectionTitle(in: context, title: "Katılımcılar", y: yPos)

        let font = UIFont.systemFont(ofSize: 11)
        let boldFont = UIFont.systemFont(ofSize: 12, weight: .bold)

        for attendee in form.attendees {
            if yPos > pageHeight - margin - 150 {
                context.beginPage()
                yPos = margin
            }

            // Company
            attendee.company.draw(
                in: CGRect(x: margin, y: yPos, width: pageWidth - 2 * margin, height: 20),
                withAttributes: [.font: boldFont, .foregroundColor: UIColor.systemBlue]
            )
            yPos += 25

            // Name
            "İsim: \(attendee.name.isEmpty ? "_______________" : attendee.name)".draw(
                in: CGRect(x: margin + 10, y: yPos, width: pageWidth - 2 * margin, height: 20),
                withAttributes: [.font: font, .foregroundColor: UIColor.black]
            )
            yPos += 25

            // Date
            if let date = attendee.date {
                "Tarih: \(date.formatted(date: .long, time: .omitted))".draw(
                    in: CGRect(x: margin + 10, y: yPos, width: pageWidth - 2 * margin, height: 20),
                    withAttributes: [.font: font, .foregroundColor: UIColor.black]
                )
                yPos += 25
            }

            // Signature
            "İmza:".draw(
                in: CGRect(x: margin + 10, y: yPos, width: 100, height: 20),
                withAttributes: [.font: font, .foregroundColor: UIColor.black]
            )
            yPos += 25

            // Draw signature box
            let signatureBox = CGRect(x: margin + 10, y: yPos, width: 200, height: 60)
            context.cgContext.setStrokeColor(UIColor.gray.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.stroke(signatureBox)

            // Draw signature image if available
            if let signatureData = attendee.signatureData,
               let signatureImage = UIImage(data: signatureData) {
                signatureImage.draw(in: signatureBox)
            }

            yPos += 80
        }

        return yPos
    }

    private func drawSectionTitle(
        in context: UIGraphicsPDFRendererContext,
        title: String,
        y: CGFloat
    ) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        title.draw(
            in: CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 25),
            withAttributes: attrs
        )

        // Draw underline
        context.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: margin, y: y + 22))
        context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: y + 22))
        context.cgContext.strokePath()

        return y + 30
    }
}
