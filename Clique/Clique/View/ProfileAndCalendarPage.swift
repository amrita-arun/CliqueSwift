//
//  ProfileAndCalendarPage.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import UIKit

//@available(iOS 17.0, *)
struct ProfileAndCalendarPage: View {
    
    @ObservedObject var userViewModel: UserViewModel
    @State var didSignOut = false
    @State private var selectedDate = Date()
    @StateObject private var feedVM: FeedViewModel
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        _feedVM = StateObject(wrappedValue: FeedViewModel(userViewModel: userViewModel))
    }


    var body: some View {
        NavigationStack {
            ScrollView {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150, alignment: .center)
                    .clipShape(Circle())
                    .padding(.top, 20)
                Text("@\(userViewModel.user?.username ?? "")")
                    .font(.largeTitle)
                    .bold()

                
                Button("Sign out") {
                    Task {
                        userViewModel.signOut()
                    }
                    
                }
                
                
                VStack(alignment: .leading) {
                    UIDatePickerView(date: $selectedDate)
                        .frame(height: 500)
                        .padding(.horizontal, 15)
                    
                    // trigger fetch whenever user picks a new date
                        .onChange(of: selectedDate) { newDate in
                    Task { await feedVM.fetchPosts(on: newDate) }
                    }
                    
                   // also fetch when screen appears
                    .task {
                        await feedVM.fetchPosts(on: selectedDate)
                    }
                    
                    // Show the chosen date in SwiftUI
                    Text("Selected: \(selectedDate.formatted(.dateTime.month().day().year()))")
                                            .font(.subheadline)
                                           .foregroundColor(.gray)
                                           .padding(.leading, 15)
                    
                    // MARK: — show posts for that date
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(feedVM.posts) { post in
                            // find the group name
                            let gName = userViewModel.groups
                                .first(where: { $0.id == post.groupID })?.name
                            ?? "Group"
                    
                            HomePostView(
                                username:  feedVM.usernamesById[post.userID] ?? "Unknown",
                                groupName: gName,
                                post:      post
                            )
                            .padding(15)
                        }
                    }
                    .padding(.top, 20)
                    
                }
            }
            .task {
                await userViewModel.fetchCurrentUserProfile()
            }

        }
    }
}

struct UIDatePickerView: UIViewRepresentable {
    @Binding var date: Date
    var mode: UIDatePicker.Mode = .date

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: UIDatePickerView
        init(_ parent: UIDatePickerView) { self.parent = parent }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}

struct WeekBox: View {
    let weekNum: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Week \(weekNum)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .font(.headline)
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.gray)
        .cornerRadius(10)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 10)
    }
    
}


