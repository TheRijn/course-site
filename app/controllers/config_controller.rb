require 'dropbox'

class ConfigController < ApplicationController

	before_filter CASClient::Frameworks::Rails::Filter
	before_filter :require_admin
	
	def index
		@dropbox_linked = Dropbox.connected?
		@secret = Settings.webhook_secret
		@all_sections = Section.includes(pages: :pset)
	end
	
	# allows setting arbitrary settings in the settings model
	def settings
		if setting = params["settings"]
			setting.each do |k,v|
				v = v == "1" if v == "1" or v == "0"
				logger.debug "Setting #{k} to #{v.inspect}"
				Settings[k] = v
			end
		end
		render nothing: true
	end
	
	def page_update
		p = Page.find(params[:id])
		p.update!(params.require(:page).permit(:public))
		render json: p
	end
	
	def section_update
		p = Section.find(params[:id])
		p.update!(params.require(:page).permit(:display))
		render json: p
	end

	def schedule_registration
		p = Schedule.find(params[:id])
		p.update!(params.require(:schedule).permit(:self_register))
		render json: p
	end
	
	def schedule_self_service
		p = Schedule.find(params[:id])
		p.update!(params.require(:schedule).permit(:self_service))
		render nothing: true
	end
	
	def permissions
		@users = User.staff.order(:role, :name)
		@schedules = Schedule.all
		@groups = Group.all

		respond_to do |format|
			format.js { render 'permissions' }
		end
	end

	def git_repo_save
		if Settings.git_repo.present?
			redirect_to :back, alert: 'You already cloned a repo once!'
		else
			Settings.git_repo = params[:repo_url]
			Settings.git_branch = params[:repo_branch]
			CourseLoader.new.run
			redirect_to :back, notice: 'The course content was successfully cloned.'
		end
	end
	
	def generate_secret
		secret = SecureRandom.hex(20)
		Settings.webhook_secret = secret
		redirect_to :back
	end

end
