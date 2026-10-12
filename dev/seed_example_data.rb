# frozen_string_literal: true

# Local development helper invoked by dev/seed-example-data.sh.
# This file runs inside the Discourse Rails environment and seeds example
# member profiles for manual testing of the directory and network graph.
# Idempotent: safe to rerun after `docker compose down -v`.

WEBSITE_KEY = "default"
DEV_PASSWORD = ENV.fetch("DEV_ADMIN_PASSWORD", "LocalDevelopment123!")

def find_or_create_account(email:, username:, name:)
  user = User.find_by_email(email)
  return user if user

  user = User.new(email: email, username: username, name: name, password: DEV_PASSWORD, active: true, approved: true)
  user.save!
  user.activate unless user.email_confirmed?
  user
end

def seed_profile(user, data, aspirations: nil)
  profile = ProfessionalNetwork::Profile.find_or_initialize_by(user_id: user.id, website_key: WEBSITE_KEY)
  profile.data = ProfessionalNetwork::ProfileData.normalize(data)
  profile.public_profile = true
  profile.save!

  if aspirations
    wrapper = ProfessionalNetwork::Aspirations.new(user)
    wrapper.assign(aspirations)
    wrapper.save!
  end

  profile
end

puts "Seeding example members..."

amara = find_or_create_account(email: "amara.okafor@example.test", username: "amara_okafor", name: "Amara Okafor")
seed_profile(amara, {
  "name" => "Amara Okafor", "headline" => "Product Designer", "company" => "Lumen Studio",
  "city" => "Lisbon", "country" => "Portugal",
  "about" => "Product designer focused on fintech onboarding flows for diaspora communities.",
  "fields_of_expertise" => %w[design product],
  "skills" => ["Figma", "User Research", "Prototyping"],
  "languages" => %w[English Portuguese], "experience_level" => "senior", "membership_type" => "remote",
  "website" => "https://amaraokafor.example", "linkedin_url" => "https://www.linkedin.com/in/amaraokafor",
  "experience" => [{ "title" => "Product Designer", "company" => "Lumen Studio", "years" => "2021-Present" }],
  "education" => [{ "school" => "University of Lagos", "degree" => "BSc Industrial Design" }],
}, aspirations: { "field" => "Design Leadership", "mentoring_interests" => ["mentoring_opportunity"] })

diego = find_or_create_account(email: "diego.fernandez@example.test", username: "diego_fernandez", name: "Diego Fernández")
seed_profile(diego, {
  "name" => "Diego Fernández", "headline" => "Senior Backend Engineer", "company" => "Illyrian Tech Hub",
  "city" => "Berlin", "country" => "Germany",
  "about" => "Backend engineer building payments infrastructure; enjoys mentoring junior engineers.",
  "fields_of_expertise" => %w[engineering backend],
  "skills" => %w[Ruby Rails PostgreSQL],
  "languages" => %w[English Spanish German], "experience_level" => "senior", "membership_type" => "hybrid",
  "linkedin_url" => "https://www.linkedin.com/in/diegofernandez",
  "experience" => [{ "title" => "Senior Backend Engineer", "company" => "Illyrian Tech Hub", "years" => "2022-Present" }],
  "education" => [{ "school" => "Technical University of Madrid", "degree" => "BSc Computer Science" }],
}, aspirations: { "field" => "Engineering Leadership", "mentoring_interests" => ["mentoring_opportunity"] })

priya = find_or_create_account(email: "priya.nair@example.test", username: "priya_nair", name: "Priya Nair")
seed_profile(priya, {
  "name" => "Priya Nair", "headline" => "Marketing Lead", "company" => "Diaspora Builders Network",
  "city" => "Lisbon", "country" => "Portugal",
  "about" => "Growth marketer helping diaspora-led organizations reach their communities.",
  "fields_of_expertise" => %w[marketing growth],
  "skills" => ["SEO", "Content Strategy", "Community Building"],
  "languages" => %w[English Hindi Portuguese], "experience_level" => "senior", "membership_type" => "remote",
  "linkedin_url" => "https://www.linkedin.com/in/priyanair",
  "experience" => [{ "title" => "Marketing Lead", "company" => "Diaspora Builders Network", "years" => "2020-Present" }],
})

tomas = find_or_create_account(email: "tomas.novak@example.test", username: "tomas_novak", name: "Tomáš Novák")
seed_profile(tomas, {
  "name" => "Tomáš Novák", "headline" => "Backend Engineer", "company" => "Freelance",
  "city" => "Berlin", "country" => "Germany",
  "about" => "Early-career backend engineer looking to grow into a senior role.",
  "fields_of_expertise" => %w[engineering backend],
  "skills" => %w[Ruby Kubernetes],
  "languages" => %w[English Czech German], "experience_level" => "junior", "membership_type" => "hybrid",
}, aspirations: { "field" => "Engineering Leadership", "mentoring_interests" => ["mentor_connection", "career_coaching"] })

sofia = find_or_create_account(email: "sofia.rossi@example.test", username: "sofia_rossi", name: "Sofia Rossi")
seed_profile(sofia, {
  "name" => "Sofia Rossi", "headline" => "Founder", "company" => "Adriatic Ventures",
  "city" => "Rome", "country" => "Italy",
  "about" => "Founder backing early-stage startups across the Adriatic diaspora.",
  "fields_of_expertise" => %w[business-development entrepreneurship],
  "skills" => %w[Fundraising Strategy],
  "languages" => %w[English Italian], "experience_level" => "senior", "membership_type" => "hybrid",
  "linkedin_url" => "https://www.linkedin.com/in/sofiarossi",
}, aspirations: { "business_interests" => %w[project_funding client_partner_intro] })

lucas = find_or_create_account(email: "lucas.martins@example.test", username: "lucas_martins", name: "Lucas Martins")
seed_profile(lucas, {
  "name" => "Lucas Martins", "headline" => "Business Development Associate", "company" => "Adriatic Ventures",
  "city" => "Rome", "country" => "Italy",
  "about" => "Business development associate connecting founders with diaspora investors.",
  "fields_of_expertise" => %w[business-development],
  "skills" => %w[Fundraising Networking],
  "languages" => %w[English Portuguese Italian], "experience_level" => "mid", "membership_type" => "hybrid",
}, aspirations: { "business_interests" => %w[project_funding client_partner_intro] })

puts "Seeded 6 member profiles."
