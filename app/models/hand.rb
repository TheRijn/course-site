class Hand < ActiveRecord::Base

	belongs_to :user
	belongs_to :assist, class_name: "User"
	
	scope :waiting, -> { where(assist: nil).where.not(done: true) }
	
	after_create do |hand|
		if hand.done
			hand.user.update_attribute(:last_spoken_at, DateTime.now)
		end
		if hand.success
			AttendanceRecord.create_for_user(hand.user, true)
		end
		if hand.note.present?
			user.notes.create(text: hand.note, author: hand.assist)
		end
	end

	def user_last_seen
		if attend = self.user.attendance_records.order('cutoff desc').first
			attend.cutoff
		else
			nil
		end
	end

end
