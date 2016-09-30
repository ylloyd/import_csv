class Person < ActiveRecord::Base
	has_paper_trail

	# If the current value of a record matches the CSV value, add true to the array (for a specific attribute version)
	def check_attr(array, version_value, csv_value)
      array.push(version_value == csv_value)
	end
end
