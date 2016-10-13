# Import CSV files
This app executes different tasks allowing to import CSV files.
You can find the tasks in lib/tasks/import_csv.rake.

## Clone the project
````shell
git clone git@github.com:ylloyd/inch-test.git
cd inch-test
rake db:migrate
````

##### Import CSV files containing people information
````shell
rake import_csv:people['people.csv']
````

##### Import CSV files containing buildings information
````shell
rake import_csv:buildings['buildings.csv']
````

##### Import CSV files containing any kind of information. The arguments of this task are :
- The type of data you want to import (Person or Building)
- The attributes requiring another level of updating options (separated with a space)
- The file you want to import
````shell
rake import_csv:any[Person,'email address home_phone_number mobile_phone_number','people.csv']
rake import_csv:any[Building,'manager_name','buildings.csv']
````

## CSV Examples
To test the different tasks, these are the CSV files included :
- Import people : people.csv, people2.csv, people3.csv
- Import buildings : buildings.csv, buildings2.csv, buildings3.csv