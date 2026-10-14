# frozen_string_literal: true

module ProfessionalNetwork
  class ProfileLogosController < BaseController
    requires_plugin ProfessionalNetwork::PLUGIN_NAME

    def create
      owner!
      profile = Profile.organizations.find_by!(user_id: current_user.id, website_key: website_key)
      file = params[:file]
      raise Discourse::InvalidParameters.new(:file) unless file.respond_to?(:tempfile)

      upload = UploadCreator.new(file.tempfile, file.original_filename, type: "composer").create_for(current_user.id)
      raise Discourse::InvalidParameters.new(:file) unless upload.persisted? &&
        FileHelper.is_supported_image?(upload.original_filename)

      profile.update!(logo_upload: upload, data: profile.data.merge("logo_url" => upload.url))
      UploadReference.ensure_exist!(upload_ids: [upload.id], target: profile)
      render json: { logo_url: upload.url }
    end
  end
end
