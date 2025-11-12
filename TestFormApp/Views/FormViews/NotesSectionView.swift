//
//  NotesSectionView.swift
//  TestFormApp
//
//  Section for managing notes
//

import SwiftUI

struct NotesSectionView: View {
    @ObservedObject var form: FilledForm

    @State private var newNoteText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Existing notes
            if form.notes.isEmpty {
                emptyState
            } else {
                ForEach(Array(form.notes.enumerated()), id: \.offset) { index, note in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "note.text")
                            .foregroundStyle(.blue)

                        Text(note)
                            .font(.body)

                        Spacer()

                        Button(role: .destructive) {
                            deleteNote(at: index)
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Add new note
            VStack(spacing: 8) {
                TextEditor(text: $newNoteText)
                    .frame(height: 80)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    addNote()
                } label: {
                    Label("Not Ekle", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "note.text")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Henüz not eklenmemiş")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func addNote() {
        let trimmedNote = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else { return }

        var notes = form.notes
        notes.append(trimmedNote)
        form.notes = notes
        newNoteText = ""
    }

    private func deleteNote(at index: Int) {
        var notes = form.notes
        notes.remove(at: index)
        form.notes = notes
    }
}

#Preview {
    let form = FilledForm(templateId: "test")

    return NotesSectionView(form: form)
        .padding()
}
