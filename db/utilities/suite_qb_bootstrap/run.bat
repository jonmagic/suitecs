path %PATH%;C:\Program Files\SuiteCS\bin\
cd "C:\Program Files\SuiteCS\runtime"
ruby script/runner db/utilities/suite_qb_bootstrap/generate_bootstrap.rb -e production
ruby script/runner import_clients_from_qb.rb -e production
del import_clients_from_qb.rb
pause