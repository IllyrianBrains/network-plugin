# frozen_string_literal: true

# Local development helper invoked by dev/create-admin.sh.
# This file runs inside the Discourse Rails environment.

email = ENV.fetch("DEV_ADMIN_EMAIL", "admin@example.test")
password = ENV.fetch("DEV_ADMIN_PASSWORD", "LocalDevelopment123!")

user = User.find_by_email(email) || User.new(email: email)
user.username ||= UserNameSuggester.suggest(email)
user.password = password
user.active = true
user.approved = true
user.save!
user.grant_admin!
user.change_trust_level!(1) if user.trust_level < 1
user.activate unless user.email_confirmed?

# New Discourse installations route every anonymous request to
# /finish-installation while this flag is set. admin:create normally clears it
# through a model callback, but make the local bootstrap explicit and
# idempotent so an existing admin also completes setup.
SiteSetting.has_login_hint = false
SiteSetting.global_notice = ""

puts "Local administrator ready: #{email}"
