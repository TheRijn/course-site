module ApplicationHelper

	def page_done_icon(user, pset)
		if user && pset && Submit.where(:user_id => user.id, :pset_id => pset.id).count > 0
			" <span class='glyphicon glyphicon-thumbs-up'></span>".html_safe
		else
			""
		end
	end
	
	def date_span_with_title(date)
		"<span title=\"#{date.strftime("%A %d %b %Y %R")}\">#{time_ago_in_words(date)} #{t(:ago)}</span>".html_safe
	end

	def markdown(text, page_context)
		Kramdown::Document.new(text,
		                       :auto_ids => true,
		                       :asset_prefix => page_context.public_url,
		                       :cdn_prefix => Settings.cdn_prefix,
							   :parse_block_html => true,
							   :toc_levels => 2..3,
		                       :coderay_css => :class,
		                       :coderay_tab_width => 4,
		                       :enable_coderay => true,
		                       :coderay_line_numbers => nil).to_custom_html.html_safe
	end
	
	def simple_markdown(text)
		return text && Kramdown::Document.new(text,
		                       :auto_ids => true,
							   :parse_block_html => true,
							   :toc_levels => 2..3,
		                       :coderay_css => :class,
		                       :coderay_tab_width => 4,
		                       :enable_coderay => true,
		                       :coderay_line_numbers => nil).to_custom_html.html_safe
	end
	
	def title()
		@title || (@page && @page.title)
	end
	
	def class_if(condition, classes)
		condition ? " " + classes : ""
	end
	
	def class_if_else(condition, classes, else_classes)
		condition ? " " + classes : " " + else_classes
	end
	
	def form_tag_if(condition, url_for_options = {}, options = {}, &block)
		if condition
			form_tag(url_for_options, options, &block)
		else
			capture(&block)
		end
	end
	
	def is_local_ip?
		# begin
		# 	location = Resolv.getname(request.remote_ip)
		# rescue Resolv::ResolvError
		# 	location = "untraceable"
		# end
		# puts "loc" + location
		# return location =~ /^(wcw|1x).*uva.nl$/ || location == 'localhost'
		# puts request.remote_ip
		return !!(request.remote_ip =~ /^145\.18\..*$/) ||
		       !!(request.remote_ip =~ /^145\.109\..*$/) ||
			   !!(request.remote_ip =~ /^195\.169\..*$/) ||
			   !!(request.remote_ip =~ /^100\.70\..*$/) ||
			   request.remote_ip == '::1' ||
			   request.remote_ip == '127.0.0.1'
	end
	

end
