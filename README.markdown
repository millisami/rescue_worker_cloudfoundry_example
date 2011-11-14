Description
-----------

Resque Worker is a simple Sinatra app that will run Resque Workers in their own threads and the Web front end mounted at the /resque endpoint.

This app is ideally suited for using Resque on [Cloudfoundry](http://cloudfoundry.com).

Usage
-----

1. Create app (vmc push)
2. Bind Redis service (vmc bind-service redis-service app)
3. Set USERNAME and PASSWORD env variables (vmc env-add USERNAME=admin)
4. Set WORKERS env variable (vmc env-add WORKERS=default,low;high)
5. Restart app (vmc restart app)
