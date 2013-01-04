class Course

	COURSE_DIR = "public/course"
	@@settings = nil

	def self.reload
		# get update from from git remote (pull)
		Rails.logger.info "updating course in dir #{COURSE_DIR}..."
		update_repo(COURSE_DIR)

		# remove all previous content
		Section.delete_all
		Page.delete_all
		Subpage.delete_all
		Answer.delete_all
		PageSubmission.delete_all

		# add course info pages and all sections, recursively
		process_info(COURSE_DIR)
		process_sections(COURSE_DIR)
	end
	
	def self.method_missing(method_id)
		if @@settings == nil
			load_config
		end
		if @@settings.has_key?(method_id.to_s)
			return @@settings[method_id.to_s]
		end
	end
	
	private
	
	def self.load_config()
		@@settings = self.read_config(File.join(COURSE_DIR, 'course.yml'))
	end
	
	def self.update_repo(dir)
		
		# simply performs a 'git pull'
		g = Git.open dir, :log => Rails.logger
		g.pull
		
	end

	def self.process_info(dir)
		
		# info should be a subdir of the root course dir and contain markdown files
		# NOT IMPLEMENTED
		info_dir = File.join(dir, 'info')
		if File.exist?(info_dir)
			Rails.logger.debug info_dir
			info_page = Page.create(:title => self.course['title'], :position => 0, :path => info_dir, :form => false)
			process_subpages(info_dir, info_page)
		end

	end
	
	def self.process_sections(dir)
		
		# sections should be direct descendants of the root course dir
		Dir.glob(subdirs(dir)) do |section|
			
			section_path = File.basename(section)
			next if section_path == "info" # skip info directory
			section_info = split_info(section_path)
			
			db_sec = Section.create(:title => section_info[2], :position => section_info[1], :path => section_path)

			process_pages(section, db_sec)
		end

	end
	
	def self.process_pages(dir, parent_section)
		
		# each page is a descendant of a section and contains one or more markdown subpages
		Dir.glob(subdirs(dir)) do |page|
			
			page_path = File.basename(page)    # only the directory name
			page_info = split_info(page_path)  # array of position and page name

			# load submit.yml config file which contains items to submit
			submit_config = read_config(files(page, "submit.yml"))
			
			# create the page
			db_page = parent_section.pages.create(:title => page_info[2], :position => page_info[1], :path => page_path, :form => submit_config && submit_config['form'])

			# if there was actually a config file present
			if submit_config
				['required', 'optional'].each do |modus|
					if submit_config[modus]
						submit_config[modus].each do |file|
							db_page.page_submissions.create(:filename => file, :required => modus == 'required')
						end
					end
				end
			end

			process_subpages(page, db_page)
		end
		
	end
	
	def self.process_subpages(dir, parent_page)
		
		Rails.logger.debug dir
		
		# a subpage is a markdown document that is copied into the database
		Dir.glob(files(dir, "*.md")) do |subpage|

			subpage_path = File.basename(subpage)
			subpage_info = split_info(subpage_path)
			
			file = IO.read(File.join(dir, subpage_path))
			parent_page.subpages.create(:title => subpage_info[2], :position => subpage_info[1], :content => file)
		end
		
	end

	def self.subdirs(*name)
		return File.join(name, "*/")
	end

	def self.files(*name)
		return File.join(name)
	end

	def self.split_info(object)
		return object.match('(\d)\s+([^\.]*)')
	end
	
	def self.read_config(filename)
		if File.exists?(filename)
			return YAML.load_file(filename)
		else
			return false
		end
	end

end