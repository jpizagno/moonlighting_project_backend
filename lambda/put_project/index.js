const { DynamoDB, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const docClient = new DynamoDB({region: 'eu-central-1'});

exports.handler =  async function(project, ctx, callback) {
    try {
    
        const input = {
          "Item": {
            "id": {
              "S": project.id
            },
            "project": {
              "S": project.project
            }
          },
          "ReturnConsumedCapacity": "TOTAL",
          "TableName": "moonlighting-projects" 
        };

        const command = new PutItemCommand(input);
        const response = await docClient.send(command)
        try {
            const code = response.$metadata.httpStatusCode
            if (code === 200) {
                var httpResponse = {
                    statusCode: code,
                    headers: {
                      'Content-Type': 'text/html; charset=utf-8',
                      'Access-Control-Allow-Origin':'*'
                  },
                    body: '<p>Insert Table Success</p>'
                    }
                callback(null, httpResponse);
            } else {
                var httpResponse = {
                    statusCode: 500,
                    headers: {
                      'Content-Type': 'text/html; charset=utf-8',
                      'Access-Control-Allow-Origin':'*'
                  },
                    body: '<p>Could not update table</p>'
                    }
                callback(null, httpResponse);
            }
        
        } catch (err) {
        callback("error in response: project="+project)
    }
    } catch (err) {
      var httpResponse = {
          statusCode: 500,
          headers: {
            'Content-Type': 'text/html; charset=utf-8',
            'Access-Control-Allow-Origin':'*'
        },
          body: 'error parsing input body. project='+JSON.stringify(project)
          }
      callback(null, httpResponse);
    }
};
