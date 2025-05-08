import SwiftUI

struct AddGroupView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var groupName    = ""
    @State private var searchEmail  = ""
    @State private var searchResult: CliqueUser?
    @State private var members: [CliqueUser] = []
    @State private var errorMessage: String?
    @State private var isCreating   = false

    var body: some View {
        NavigationStack {
            Form {
                groupNameSection
                addMembersSection
                
                if !members.isEmpty {
                    membersSection
                }

                if let error = errorMessage {
                    Section { Text(error).foregroundColor(.red) }
                }

                Section {
                    Button("Create Group") {
                        Task { await createGroup() }
                    }
                    .disabled(groupName.isEmpty || members.isEmpty || isCreating)
                }
            }
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var groupNameSection: some View {
        Section("Group Name") {
            TextField("Enter a name", text: $groupName)
        }
    }

    private var addMembersSection: some View {
        Section("Add Members") {
            HStack {
                TextField("Search by email", text: $searchEmail)
                    .autocapitalization(.none)
                Button("🔍") {
                    Task { await performSearch() }
                }
                .disabled(searchEmail.isEmpty)
            }

            if let user = searchResult {
                HStack {
                    VStack(alignment: .leading) {
                        Text(user.name)
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if !members.contains(where: { $0.id == user.id }) {
                        Button("Add") {
                            members.append(user)
                            searchResult = nil
                            searchEmail = ""
                        }
                    }
                }
            }
        }
    }

    private var membersSection: some View {
        Section("Members") {
            ForEach(members, id: \.id) { member in
                HStack {
                    Text(member.name)
                    Spacer()
                    Text("@\(member.username)")
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func performSearch() async {
        do {
            if let user = try await userViewModel.fetchUser(byEmail: searchEmail) {
                searchResult = user
                errorMessage  = nil
            } else {
                errorMessage  = "No user found with that email."
                searchResult  = nil
            }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }

    private func createGroup() async {
        isCreating = true
        do {
            let memberIDs = members.map(\.id)
            try await userViewModel.createGroup(
                name:       groupName,
                memberUIDs: memberIDs + [userViewModel.currentUser!.uid]
            )
            dismiss()
        } catch {
            errorMessage = "Could not create group: \(error.localizedDescription)"
        }
        isCreating = false
    }
}
