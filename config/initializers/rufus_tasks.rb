scheduler = Rufus::Scheduler.new

# If you want to change the mailing frequency, note that this frequency is
# present in two places in this code. One for running the scheduler regularly,
# and one for making sure only grades of a certain age are emailed, to allow
# for corrections within that timeframe.

scheduler.every '15m' do
	if Settings['mail_address']
		Grade.where("grades.updated_at < ? and grades.mailed_at < grades.updated_at and grades.done is ? and grades.public is ?", 2.hours.ago, false, true).joins([:submit]).find_each do |g|
			GradeMailer.new_mail(g).deliver
			g.touch(:mailed_at)
		end
	end
end
