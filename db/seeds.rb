# coding: utf-8

User.create!(name:  "Sample User",
             email: "sample@email.com",
             password:              "password",
             password_confirmation: "password",
             admin: true)

User.create!(name:  "superior１",
             email: "superior1@email.com",
             password:              "password",
             password_confirmation: "password",
             superior: true)
             
User.create!(name:  "superior2",
             email: "superior2@email.com",
             password:              "password",
             password_confirmation: "password",
             superior: true)
             

60.times do |n|
  name  = Faker::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end