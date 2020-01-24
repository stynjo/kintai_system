# coding: utf-8

User.create!(name: "管理ユーザー",
             email: "sample@example.com",
             employee_number: 1,
             uid: 1,
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "上長ユーザー1",
             email: "superior1@email.com",
             employee_number: 2,
             uid: 2,
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "上長ユーザー2",
             email: "superior2@email.com",
             employee_number: 3,
             uid: 3,
             password: "password",
             password_confirmation: "password",
             superior: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample#{n+4}@example.com"
  employee_number = n + 4
  uid = n + 4
  password = "password"
  User.create!(name: name,
               email: email,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password)
end
