# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email: "admin@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
end

# Tables (capacity)
[
  ["T1", 2], ["T2", 2], ["T3", 4], ["T4", 4], ["T5", 6]
].each do |name, cap|
  Table.find_or_create_by!(name: name) { |t| t.capacity = cap }
end

# TimeSlots (next 3 months, 10am–9pm hourly)
start_date = Date.current
end_date   = Date.current + 3.months

(start_date..end_date).each do |date|
  (9..21).each do |hour|
    starts = Time.zone.local(date.year, date.month, date.day, hour, 0, 0)

    TimeSlot.find_or_create_by!(starts_at: starts) do |s|
      s.max_tables = 5
      s.active = true
    end
  end
end

