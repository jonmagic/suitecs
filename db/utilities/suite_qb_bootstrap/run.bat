path %PATH%;C:\Program Files\SuiteCS\bin\
cd "C:\Program Files\SuiteCS\runtime"
ruby db/utilities/suite_qb_bootstrap/generate_bootstrap.rb
ruby script/runner import_clients_from_qb.rb RAILS_ENV=production
del import_clients_from_qb.rb
pause