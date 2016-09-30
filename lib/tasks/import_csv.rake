require 'csv'

$priority_attr = []

# If one of the value in the array = 'true', add the attribute to $priority_attr for the update
def add_attr_to_array(array, attribute)
	if array.any?
		$priority_attr.push(attribute)
	end
end

# Method to check if the current record attribute matches the csv value
def add_to_array(field_name, current_value, csv_value)
	if not current_value == csv_value
		$priority_attr.push(field_name)
	end
end


namespace :import_csv do
  desc "Import new persons"
  task people: :environment do
		nb_new_rows = 0
		nb_updated_rows = 0

		CSV.foreach('people.csv', :headers => true) do |row|

			person_hash = row.to_hash
			person = Person.where(["reference = ?", person_hash['reference']])

			if person.count == 1
				person.each do |p|
				var = []
					# Check if a record has more than one version
					if p.versions.length > 1
						arr_email = []
						arr_address = []
						arr_home_phone_number = []
						arr_mobile_phone_number = []

						# Get the latest version of a record
						last_v = p.versions.last
				    p.check_attr(arr_email, last_v.reify.email, row['email'])
				    p.check_attr(arr_address, last_v.reify.address, row['address'])
				    p.check_attr(arr_home_phone_number, last_v.reify.home_phone_number, row['home_phone_number'])
				    p.check_attr(arr_mobile_phone_number, last_v.reify.mobile_phone_number, row['mobile_phone_number'])

				    # Loop over all the versions of a record
						p.versions.each do |version|
					    unless version.reify.nil?
					    	p.check_attr(arr_email, version.reify.email, row['email'])
					    	p.check_attr(arr_address, version.reify.address, row['address'])
					    	p.check_attr(arr_home_phone_number, version.reify.home_phone_number, row['home_phone_number'])
					    	p.check_attr(arr_mobile_phone_number, version.reify.mobile_phone_number, row['mobile_phone_number'])
					    end
						end
						# puts arr_email.any?
						# puts arr_address.any?
						# puts arr_home_phone_number.any?
						# puts arr_mobile_phone_number.any?

						# puts add_to_array(arr_email, 'email')
						# puts add_to_array(arr_address, 'address')
						# puts add_to_array(arr_home_phone_number, 'home_phone_number')
						# puts add_to_array(arr_mobile_phone_number, 'mobile_phone_number')

						# if arr_email.any?
						# 	var.push('email')
						# end
						# if arr_address.any?
						# 	var.push('address')
						# end
						# if not arr_home_phone_number.any?
						# 	var.push('home_phone_number')
						# end
						# if not arr_mobile_phone_number.any?
						# 	var.push('mobile_phone_number')
						# end


						add_attr_to_array(arr_email, 'email')
						add_attr_to_array(arr_address, 'address')
						add_attr_to_array(arr_home_phone_number, 'home_phone_number')
						add_attr_to_array(arr_mobile_phone_number, 'mobile_phone_number')

						# print $priority_attr.join(',')
					nb_updated_rows += 1
					print $priority_attr
					arr = $priority_attr
					person.first.update_attributes(person_hash.except!(*arr))
					$priority_attr.clear
					else
						add_to_array('email', p.email, person_hash['email'])
						add_to_array('address', p.address, person_hash['address'])
						add_to_array('home_phone_number', p.home_phone_number, person_hash['home_phone_number'])
						add_to_array('mobile_phone_number', p.mobile_phone_number, person_hash['mobile_phone_number'])

						# p.check_attr(arr_email, version.reify.email, row['email'])
			   #  	p.check_attr(arr_address, version.reify.address, row['address'])
			   #  	p.check_attr(arr_home_phone_number, version.reify.home_phone_number, row['home_phone_number'])
			   #  	p.check_attr(arr_mobile_phone_number, version.reify.mobile_phone_number, row['mobile_phone_number'])
					nb_updated_rows += 1
					# print $priority_attr
					arr = $priority_attr
					person.first.update_attributes(person_hash.except!(*arr))
					$priority_attr.clear
					end
				end
			else
				puts 'Doesn\'t exists'
				Person.create!(row.to_hash)
				nb_new_rows += 1
			end
		end
		puts 'COMPLETE'
		puts "#{nb_new_rows} new record(s)"
		puts "#{nb_updated_rows} record(s) updated"
  end

  desc "Import new buildings"
  task :building, [:filename] do |task, args|
  	if args.filename.blank?
  		puts "You didn't specify any CSV file"
  		puts "#{task}"
  	else
  		puts "#{args}"
  	end
  end

end
