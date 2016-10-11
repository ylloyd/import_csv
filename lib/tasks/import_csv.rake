require 'csv'

# Array to store the attributes that we will note update
$priority_attr = []

# If one of the values in the array = 'true', it means that the value of the attribute
# already exists in the database for one of the versions
# It adds the attribute to scrub to $priority_attr
def add_attr_to_array(array, attribute)
	if array.any?
		$priority_attr.push(attribute)
	end
end

namespace :import_csv do
  desc "Import new persons"
  task :people, [:filename] => :environment do |task, args|
  	if args.filename.blank?
  		puts "You didn't specify any CSV file"
  	else
  		nb_new_rows = 0
			nb_updated_rows = 0

			CSV.foreach(args.filename, :headers => true) do |row|
				person_hash = row.to_hash
				person = Person.where(["reference = ?", person_hash['reference']])

				if person.count == 1
					person.each do |p|
						# Check if a record has more than one version
						if p.versions.length > 1
							array_email = []
							array_address = []
							array_home_phone_number = []
							array_mobile_phone_number = []

							# Get the latest version of a record
							last_v = p.versions.last
					    p.check_attr(array_email, last_v.reify.email, row['email'])
					    p.check_attr(array_address, last_v.reify.address, row['address'])
					    p.check_attr(array_home_phone_number, last_v.reify.home_phone_number, row['home_phone_number'])
					    p.check_attr(array_mobile_phone_number, last_v.reify.mobile_phone_number, row['mobile_phone_number'])

					    # Loop over all the versions of a record
							p.versions.each do |version|
						    unless version.reify.nil?
						    	p.check_attr(array_email, version.reify.email, row['email'])
						    	p.check_attr(array_address, version.reify.address, row['address'])
						    	p.check_attr(array_home_phone_number, version.reify.home_phone_number, row['home_phone_number'])
						    	p.check_attr(array_mobile_phone_number, version.reify.mobile_phone_number, row['mobile_phone_number'])
						    end
							end
							add_attr_to_array(array_email, 'email')
							add_attr_to_array(array_address, 'address')
							add_attr_to_array(array_home_phone_number, 'home_phone_number')
							add_attr_to_array(array_mobile_phone_number, 'mobile_phone_number')

							# print $priority_attr
							params_to_scrub = $priority_attr
							person.first.update_attributes(person_hash.except!(*params_to_scrub))
							nb_updated_rows += 1
							$priority_attr.clear
						else
							person.first.update_attributes(person_hash)
							nb_updated_rows += 1
							$priority_attr.clear
						end
					end
				else
					Person.create!(person_hash)
					nb_new_rows += 1
				end
			end
			puts 'COMPLETE'
			puts "#{nb_new_rows} new record(s)"
			puts "#{nb_updated_rows} record(s) updated"
  	end
  end

  desc "Import new buildings"
  task :buildings, [:filename] => :environment do |task, args|
  	if args.filename.blank?
  		puts "You didn't specify any CSV file"
  	else
  		nb_new_rows = 0
			nb_updated_rows = 0

			CSV.foreach(args.filename, :headers => true) do |row|
				building_hash = row.to_hash
				building = Building.where(["reference = ?", building_hash['reference']])

				if building.count == 1
					building.each do |b|
						# Check if a record has more than one version
						if b.versions.length > 1
							array_manager_name = []

							# Get the latest version of a record
							last_v = p.versions.last
					    b.check_attr(array_manager_name, last_v.reify.manager_name, row['manager_name'])

					    # Loop over all the versions of a record
							b.versions.each do |version|
						    unless version.reify.nil?
						    	b.check_attr(array_manager_name, version.reify.manager_name, row['manager_name'])
						    end
							end
							add_attr_to_array(array_manager_name, 'manager_name')

							# print $priority_attr
							params_to_scrub = $priority_attr
							building.first.update_attributes(building_hash.except!(*params_to_scrub))
							nb_updated_rows += 1
							$priority_attr.clear
						else
							building.first.update_attributes(building_hash)
							nb_updated_rows += 1
							$priority_attr.clear
						end
					end
				else
					Building.create!(building_hash)
					nb_new_rows += 1
				end
			end
			puts 'COMPLETE'
			puts "#{nb_new_rows} new record(s)"
			puts "#{nb_updated_rows} record(s) updated"
  	end
  end

  desc "Import any kind of data"
  task :any, [:type_of_data, :attributes_to_scrub, :filename] =>  :environment do |task, args|
  	if args.filename.blank?
  		puts "You didn't specify any CSV file"
  	elsif args.attributes_to_scrub.blank?
  		puts "You didn't specify any attributes for the priority update"
  	else
  		nb_new_rows = 0
			nb_updated_rows = 0
			attributes_to_scrub = args[:attributes_to_scrub].split ' '
			classname = args.type_of_data.constantize

			CSV.foreach(args.filename, :headers => true) do |row|
				query_hash = row.to_hash
				query = classname.where(["reference = ?", query_hash['reference']])

				if query.count == 1
					query.each do |q|
						# Check if a record has more than one version
						if q.versions.length > 1
							my_array = []
							attributes_to_scrub.each do |attribute|
								# Get the latest version of a record
								last_v = q.versions.last
						    q.check_attr(my_array, last_v.reify[attribute], row[attribute])

						    # Loop over all the versions of a record
								q.versions.each do |version|
							    unless version.reify.nil?
							    	q.check_attr(my_array, version.reify[attribute], row[attribute])
							    end
								end
								add_attr_to_array(my_array, attribute)
								my_array.clear
						  end
								# print $priority_attr
								params_to_scrub = $priority_attr
								query.first.update_attributes(query_hash.except!(*params_to_scrub))
								nb_updated_rows += 1
								$priority_attr.clear
						else
							query.first.update_attributes(query_hash)
							nb_updated_rows += 1
						end
					end
				else
					classname.create!(query_hash)
					nb_new_rows += 1
				end
			end
			puts 'COMPLETE'
			puts "#{nb_new_rows} new record(s)"
			puts "#{nb_updated_rows} record(s) updated"
  	end	
  end

end
