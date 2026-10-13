# frozen_string_literal: true

require "json"
require "net/http"
require "securerandom"
require "uri"

# Local development helper invoked by dev/import-discourse-people.sh. It copies
# regular active accounts from another Discourse without passwords or privileges.
class DiscoursePeopleImporter
  PAGE_SIZE = 100
  TRUE_VALUES = %w[1 true yes].freeze

  def initialize(env: ENV, output: $stdout)
    @source_url = parse_source_url(env.fetch("SOURCE_DISCOURSE_URL"), env)
    @api_key = env.fetch("SOURCE_DISCOURSE_API_KEY")
    @api_username = env.fetch("SOURCE_DISCOURSE_API_USERNAME")
    @website_key = env.fetch("IMPORT_WEBSITE_KEY", "default")
    @limit = Integer(env.fetch("IMPORT_LIMIT", "0"), 10)
    @dry_run = enabled?(env["IMPORT_DRY_RUN"])
    @publish_profiles = enabled?(env["IMPORT_PUBLISH_PROFILES"])
    @output = output
    @counts = Hash.new(0)
  end

  def run
    validate!
    each_source_user do |source_user|
      break if limit_reached?

      import(source_user)
    end
    report
  end

  private

  def parse_source_url(value, env)
    uri = URI.parse(value)
    allowed_schemes = ["https"]
    allowed_schemes << "http" if enabled?(env["IMPORT_ALLOW_HTTP"])
    raise ArgumentError, "source URL must use #{allowed_schemes.join(" or ")}" unless allowed_schemes.include?(uri.scheme)
    raise ArgumentError, "source URL must include a host" if uri.host.blank?
    raise ArgumentError, "source URL must not contain credentials" if uri.userinfo

    uri.path = uri.path.sub(%r{/+\z}, "")
    uri.query = nil
    uri.fragment = nil
    uri
  rescue URI::InvalidURIError
    raise ArgumentError, "source URL is invalid"
  end

  def validate!
    raise ArgumentError, "IMPORT_WEBSITE_KEY is invalid" unless @website_key.match?(ProfessionalNetwork::Profile::WEBSITE_KEY)
    raise ArgumentError, "IMPORT_LIMIT cannot be negative" if @limit.negative?
  end

  def each_source_user
    page = 1
    loop do
      users = fetch_page(page)
      break if users.empty?

      users.each { |user| yield user }
      break if users.length < PAGE_SIZE || limit_reached?

      page += 1
    end
  end

  def fetch_page(page)
    uri = @source_url.dup
    uri.path = "#{@source_url.path}/admin/users/list/active.json"
    uri.query = URI.encode_www_form(page: page, show_emails: true)
    request = Net::HTTP::Get.new(uri)
    request["Api-Key"] = @api_key
    request["Api-Username"] = @api_username

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 30) do |http|
      http.request(request)
    end
    raise "source Discourse returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    raise "source Discourse returned an unexpected response" unless body.is_a?(Array)

    body
  rescue JSON::ParserError
    raise "source Discourse did not return valid JSON"
  end

  def import(source_user)
    if skipped?(source_user)
      @counts[:skipped] += 1
      return
    end

    if @dry_run
      @output.puts "Would import #{source_user.fetch("username")} <#{source_user.fetch("email")}>"
      @counts[:previewed] += 1
      return
    end

    User.transaction do
      user, created = find_or_create_user(source_user)
      upsert_profile(user, source_user)
      @counts[created ? :created : :updated] += 1
    end
  rescue ActiveRecord::RecordInvalid, Discourse::InvalidParameters => error
    @counts[:failed] += 1
    @output.puts "Skipped #{source_user["username"] || "unknown"}: #{error.message}"
  end

  def skipped?(source_user)
    source_user["email"].blank? || source_user["username"].blank? || source_user["staged"] ||
      source_user["admin"] || source_user["moderator"] || source_user["suspended_at"].present?
  end

  def find_or_create_user(source_user)
    user = User.find_by_email(source_user.fetch("email"))
    return [user, false] if user

    username = UserNameSuggester.suggest(source_user.fetch("username"))
    user = User.new(
      email: source_user.fetch("email"),
      username: username,
      name: source_user["name"].presence || username,
      password: SecureRandom.hex(32),
      active: true,
      approved: true,
    )
    user.save!
    user.activate unless user.email_confirmed?
    [user, true]
  end

  def upsert_profile(user, source_user)
    profile = ProfessionalNetwork::Profile.find_or_initialize_by(user_id: user.id, website_key: @website_key)
    if profile.persisted? && profile.profile_type != "person"
      profile.errors.add(:profile_type, "is already an organization")
      raise ActiveRecord::RecordInvalid.new(profile)
    end

    profile.profile_type ||= "person"
    profile.data = ProfessionalNetwork::ProfileData.normalize(profile.data.merge(profile_data(source_user)))
    profile.public_profile = true if @publish_profiles
    profile.save!
  end

  def profile_data(source_user)
    data = {
      "name" => source_user["name"].presence || source_user.fetch("username"),
      "headline" => source_user["title"],
      "profile_url" => source_profile_url(source_user.fetch("username")),
    }
    data.compact_blank
  end

  def source_profile_url(username)
    uri = @source_url.dup
    uri.path = "#{@source_url.path}/u/#{URI.encode_uri_component(username)}"
    uri.query = nil
    uri.to_s
  end

  def limit_reached?
    @limit.positive? && imported_count >= @limit
  end

  def imported_count
    @counts.values_at(:created, :updated, :previewed).sum
  end

  def report
    summary = @counts.sort.map { |key, value| "#{key}=#{value}" }.join(" ")
    @output.puts "Import complete: #{summary.presence || "no users found"}"
  end

  def enabled?(value)
    TRUE_VALUES.include?(value.to_s.downcase)
  end
end

DiscoursePeopleImporter.new.run
