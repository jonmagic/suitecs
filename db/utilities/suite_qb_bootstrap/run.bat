@echo off
path %PATH%;C:\Program Files\SuiteCS\bin\
cd "C:\Program Files\SuiteCS\runtime"
echo ***************************************************
echo *    Running export of clients from QuickBoos     *
echo ***************************************************
ruby script/runner db/utilities/suite_qb_bootstrap/generate_bootstrap.rb -e production
pause
cls
echo ***************************************************
echo *       Running import of clients into Suite      *
echo ***************************************************
ruby script/runner import_clients_from_qb.rb -e production
pause