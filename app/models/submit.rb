class Submit < ActiveRecord::Base

	belongs_to :user
	belongs_to :pset

	has_one :grade, dependent: :destroy

	serialize :submitted_files
	serialize :check_feedback

	def graded?
		return (self.grade && (!self.grade.grade.blank? || !self.grade.calculated_grade.blank?))
	end
	
	def retrieve_feedback
		path = File.join(Dropbox.root_folder, Settings.dropbox_folder_name, user.login_id, self.folder_name, 'check_feedback.json')
		begin
			json = Dropbox.download(path)
			contents = json.present? ? JSON.parse(json) : nil
			self.update(check_feedback: contents)
		rescue
			# go on, assuming its not there
		end

		# path = File.join(Dropbox.root_folder, Settings.dropbox_folder_name, user.login_id, self.folder_name, 'style_feedback.json')
		# begin
		# 	contents = Dropbox.download(path)
		# 	self.update(style_feedback: contents)
		# rescue
		# 	# done anyway, assuming its not there
		# end
	end
	
	def check_feedback_formatted
		return "" if self.check_feedback.blank?

		result = ""
		self.check_feedback.each do |item|
			case item["status"]
			when true
				result << ":)"
			when false
				result << ":("
			when nil
				result << ":|"
			end
			result << " " + item["description"] + "\n"
			if item["rationale"].present?
				result << "    " + item["rationale"] + "\n"
			end
		end
		
		return result
	end

end
