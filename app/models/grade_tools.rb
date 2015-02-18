class GradeTools

	def initialize
		@grading = Settings['grading']
	end
	
	def calc_final_grade(subs)
		@grading['calculation'].each do |name, formula|
			grade = calc_final_grade_formula(subs, formula)
			if grade > 0
				return grade
			end
		end
		return 0
	end
	
	private

	def calc_final_grade_formula(subs, formula)
		total = 0
		total_weight = 0
		
		formula.each do |subtype, weight|
			grade = calc_final_grade_subtype(subs, subtype)
			return 0 if grade == 0
			total += grade * weight
			total_weight += weight
		end
		
		return (1.0 * total / total_weight).round(1)
	end
	
	def calc_final_grade_subtype(subs, subtype)
		return 0 if !@grading[subtype]['grades']

		total = 0
		total_weight = 0
		
		@grading[subtype]['grades'].each do |grade, weight|
			return 0 if subs[grade].nil?
			total += subs[grade] * weight
			total_weight += weight
		end
		
		return (1.0 * total / total_weight).round(1)
	end

end
