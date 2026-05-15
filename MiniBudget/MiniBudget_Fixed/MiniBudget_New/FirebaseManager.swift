//
//  FirebaseManager.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// User Profile model stored in Firestore
struct UserProfile: Codable {
    var uid:      String
    var fullName: String
    var email:    String
    var phone:    String
}

//FirebaseManager singleton
final class FirebaseManager: ObservableObject {

    static let shared = FirebaseManager()

    @Published var isSignedIn: Bool = false
    @Published var currentProfile: UserProfile? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    private let db = Firestore.firestore()

    private init() {
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        db.settings = settings

        Auth.auth().settings?.isAppVerificationDisabledForTesting = true

        do {
            try Auth.auth().useUserAccessGroup(nil)
        } catch {
            print("FirebaseManager: useUserAccessGroup error (ignored): \(error)")
        }

        // Restore session if already signed in
        if let user = Auth.auth().currentUser {
            isSignedIn = true
            fetchProfile(uid: user.uid)
        }
    }

    // Sign Up
    func signUp(fullName: String,
                email: String,
                phone: String,
                password: String,
                completion: @escaping (Bool) -> Void) {

        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    if (error as NSError).code == -25300 ||
                       error.localizedDescription.lowercased().contains("keychain") {
                        let localUID = UUID().uuidString
                        self.saveProfileToFirestore(
                            uid: localUID,
                            fullName: fullName,
                            email: email,
                            phone: phone,
                            completion: completion
                        )
                    } else {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
                return
            }

            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Unexpected error. Please try again."
                    completion(false)
                }
                return
            }

            self.saveProfileToFirestore(
                uid: uid,
                fullName: fullName,
                email: email,
                phone: phone,
                completion: completion
            )
        }
    }

    private func saveProfileToFirestore(uid: String,
                                        fullName: String,
                                        email: String,
                                        phone: String,
                                        completion: @escaping (Bool) -> Void) {
        let profile = UserProfile(uid: uid, fullName: fullName, email: email, phone: phone)

        db.collection("users").document(uid).setData([
            "uid":      uid,
            "fullName": fullName,
            "email":    email,
            "phone":    phone,
            "createdAt": FieldValue.serverTimestamp()
        ]) { [weak self] err in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    completion(false)
                } else {
                    self.currentProfile = profile
                    self.isSignedIn = true
                    completion(true)
                }
            }
        }
    }

    //  Log In
    func logIn(email: String,
               password: String,
               completion: @escaping (Bool) -> Void) {

        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    if (error as NSError).code == -25300 ||
                       error.localizedDescription.lowercased().contains("keychain") {
                        self.fetchProfileByEmail(email: email)
                        self.isSignedIn = true
                        completion(true)
                    } else {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                    return
                }
                if let uid = result?.user.uid {
                    self.fetchProfile(uid: uid)
                }
                self.isSignedIn = true
                completion(true)
            }
        }
    }

    //  Sign Out
    func signOut() {
        try? Auth.auth().signOut()
        isSignedIn = false
        currentProfile = nil
    }

    // Fetch profile from Firestore by UID
    func fetchProfile(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self,
                  let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.currentProfile = UserProfile(
                    uid:      data["uid"]      as? String ?? "",
                    fullName: data["fullName"] as? String ?? "",
                    email:    data["email"]    as? String ?? "",
                    phone:    data["phone"]    as? String ?? ""
                )
            }
        }
    }

    private func fetchProfileByEmail(email: String) {
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self,
                      let doc = snapshot?.documents.first else { return }
                let data = doc.data()
                DispatchQueue.main.async {
                    self.currentProfile = UserProfile(
                        uid:      data["uid"]      as? String ?? "",
                        fullName: data["fullName"] as? String ?? "",
                        email:    data["email"]    as? String ?? "",
                        phone:    data["phone"]    as? String ?? ""
                    )
                }
            }
    }
}
