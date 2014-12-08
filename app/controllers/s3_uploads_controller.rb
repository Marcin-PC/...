class S3UploadsController < ApplicationController
  before_action :get_deposit

  # GET /source_files
  # GET /source_files.json
  def index
    @source_files = @deposit.source_files #SourceFile.all
    #render plain: @source_files.to_json and return

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @source_files.map(&:to_jq_upload) }
    end
  end

  # POST /source_files
  # POST /source_files.json
  def create
    parameters = params.require(:source_file).permit(:url, :bucket, :key)
    @source_file = SourceFile.new(parameters)
    @source_file.attributes = { deposit: @deposit }
    respond_to do |format|
      if @source_file.save
        format.html {
          render :json => @source_file.to_jq_upload,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: @source_file.to_jq_upload, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @source_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_files/1
  # DELETE /source_files/1.json
  def destroy
    @source_file = SourceFile.find(params[:id])
    @source_file.destroy

    respond_to do |format|
      format.html { redirect_to source_files_url }
      format.json { head :no_content }
      format.xml { head :no_content }
    end
  end

  # used for s3_uploader
  def generate_key
    #uid = SecureRandom.uuid.gsub(/-/,'')

    render json: {
      key: ENV['institution'] + "/upload/#{@deposit.folder_name}/#{params[:filename]}",
      success_action_redirect: "/"
    }
  end

  private

  def get_deposit
    @deposit = Deposit.find(params[:deposit_id])
  end
end
