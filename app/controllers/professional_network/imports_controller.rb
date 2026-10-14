# frozen_string_literal: true
module ProfessionalNetwork
  class ImportsController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME
    before_action :owner!

    def create
      upload = params[:file]
      raise Discourse::InvalidParameters.new(:file) unless upload.respond_to?(:tempfile)
      max_bytes = SiteSetting.professional_network_max_pdf_mb * 1024 * 1024
      raise Discourse::InvalidParameters.new(:file) if upload.size > max_bytes || upload.size < 100
      upload.tempfile.rewind
      raise Discourse::InvalidParameters.new(:file) unless upload.tempfile.read(5) == "%PDF-"
      upload.tempfile.rewind
      # Route PDF-derived data through the same ProfileData checks hand-edited
      # data gets via #update -- otherwise a draft confirmed unedited would
      # write unbounded/unvalidated strings straight from a crafted PDF.
      data = ProfileData.normalize(PdfParser.parse(PdfParser.extract_pdf(upload.tempfile)))
      draft = ImportDraft.create!(user_id: current_user.id, website_key: website_key, data: data)
      render json: { id: draft.id, website_key: draft.website_key, status: draft.status, preview: draft.data }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def show
      draft = owned_draft
      render json: { id: draft.id, website_key: draft.website_key, status: draft.status, preview: draft.data }
    end

    def update
      draft = owned_draft
      raise Discourse::InvalidAccess unless draft.status == "pending"
      draft.update!(data: profile_params)
      render json: { id: draft.id, preview: draft.data }
    end

    def destroy
      draft = owned_draft
      draft.destroy!
      head :no_content
    end

    def confirm
      draft = owned_draft
      raise Discourse::InvalidAccess unless draft.status == "pending"
      Profile.transaction do
        profile = Profile.lock.find_or_initialize_by(user_id: current_user.id, website_key: draft.website_key)
        # The member-reviewed draft replaces the previous imported profile.
        # Existing data is retained if no new value is provided.
        profile.data = profile.data.merge(draft.data)
        profile.reviewed_at = Time.current
        profile.save!
        draft.update!(status: "confirmed")
      end
      render json: { success: true, website_key: draft.website_key,
                     profile: Profile.find_by(user_id: current_user.id, website_key: draft.website_key).data }
    end

    private
    def owned_draft
      ImportDraft.find_by!(id: params[:id], user_id: current_user.id)
    end
  end
end
