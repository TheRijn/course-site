module LrsHelper
	
	require 'net/http'
	
	def lrs_push(grade)
		if grade.user.monitoring_consent && ENV['MONITORING_SECRET']
			Rails.logger.info "Pushing grade..."
			user = grade.user.login_id
			timestamp = Time.now.to_i
			course = "http://studiegids.uva.nl/5082IMOP6Y"
			secret = ENV['MONITORING_SECRET']
			hash_string = [user, timestamp, course, secret].join(",")
			hash = Digest::SHA256.hexdigest hash_string
			course_url = ERB::Util.url_encode(course)
			
			base_url = "https://coach2.innovatievooronderwijs.nl/storage/events/grade/"
			monitoring_url = "#{base_url}?user=#{user}&timestamp=#{timestamp}&course=#{course_url}&hash=#{hash}".html_safe 
			final_grade = grade.calculated_grade || grade.grade
			pset = "http://cdn.mprog.nl/prog-ai-new/pset#{grade.pset.name}.zip"
			
			uri = URI.parse(monitoring_url)
			http = Net::HTTP.new(uri.host, uri.port)
			Rails.logger.info "#{uri.host}:#{uri.port}"
			request = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
			request.body = "pset=#{pset}&scope=#{grade.scope}&correctness=#{grade.correctness}&design=#{grade.design}&style=#{grade.style}&grade=#{final_grade}"
			Rails.logger.info request.path
			Rails.logger.info request.body
			response = http.request(request)
			Rails.logger.info response.inspect
		end
	end
	
end
