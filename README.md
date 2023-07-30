# moonlighting_project_backend


This is currently not fully automated.  After running build.sh. One still has to login to the AWS console and do 4 things:

1. In the AWS Gateway API go to the GET, and open section "Integration Request", and unclick the checkbox for "Use Lambda Proxy integration", and click save.

2. In the AWS Gateway API go to the POST, and open section "Integration Request", and unclick the checkbox for "Use Lambda Proxy integration", and click save.

3. In the AWS Gateway API enable CORS for the /api endpoint.  Click on "/api" then from the Actions drop down, select "Enable CORS".  After clicking through, all outputs should be green checks.

4. Redploy the API, and select "prod" as the staging. Now the React APP will work.
