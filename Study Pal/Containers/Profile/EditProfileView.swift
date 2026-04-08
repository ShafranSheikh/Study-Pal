import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var dateOfBirth = ""
    @State private var gender = "Male"
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 10)
            
            Text("Edit Profile")
                .font(.system(size: 28, weight: .bold))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Fields
                    CustomInputField(title: "First Name", placeholder: "Jhon", text: $firstName)
                    CustomInputField(title: "Last Name", placeholder: "Doe", text: $lastName)
                    CustomInputField(title: "Email", placeholder: "jhondoe@mail.com", text: $email)
                    CustomInputField(title: "Date of Birth", placeholder: "yyyy-mm-dd", text: $dateOfBirth)
                    
                    // Gender Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Menu {
                            ForEach(genders, id: \.self) { g in
                                Button(g) { gender = g }
                            }
                        } label: {
                            HStack {
                                Text(gender)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Buttons
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
}

struct CustomInputField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
        }
    }
}

#Preview {
    EditProfileView()
}
