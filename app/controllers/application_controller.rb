class ApplicationController < ActionController::Base

	protect_from_forgery

	before_action :load_navigation
	before_action :load_schedule

	helper_method :current_user, :logged_in?
	
	def load_navigation
		@sections = Section.includes(pages: :pset)
		@sections = @sections.where("pages.public" => true) unless current_user.is_admin? || current_user.is_assistant?
	end
	
	def load_schedule
		@schedule = current_user.schedule
		@alerts = Alert.order("created_at desc")
	end
	
	def logged_in?
		return !!session[:cas_user]
	end
	
	def current_user
		if logged_in?
			# there is session information to be had containing login info
			login = Login.where(login: session[:cas_user]).first_or_create

			# create new user for this login
			login.create_user and login.save if login.user.nil?

			@current_user = login.user
		else
			# no session, so fake empty user
			@current_user = User.new
		end
		
		return @current_user
	end
	
	def require_admin
		redirect_to :root unless current_user.is_admin?
	end
	
	def require_admin_or_assistant
		redirect_to :root unless current_user.is_admin? or current_user.is_assistant?
	end
	
	def default_url_options(options={})
		{ :protocol => 'https' }
	end 
	
end
