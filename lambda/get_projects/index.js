const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const docClient = new DynamoDB({region: 'eu-central-1'});

exports.handler =  async function(e, ctx, callback) {
  /*
    This method will return all items in the DynamoDB table "moonlighting-projects".
  */
    try {
    
        const params = {
          "TableName": "moonlighting-projects" 
        };
        
        
        let scanResults = [];
        let items;
    
        
        try {
            do {
                items = await docClient.scan(params);
                items.Items.forEach((item) => scanResults.push(item));
                params.ExclusiveStartKey = items.LastEvaluatedKey;
            } while (typeof items.LastEvaluatedKey != "undefined");
        
          var httpResponse = {
              statusCode: 200,
              headers: {
                  'Content-Type': 'text/html; charset=utf-8'
              },
              body: JSON.stringify(items),
              "isBase64Encoded": false
          }
          callback(null, httpResponse);
            
        } catch (err) {
            var httpResponse = {
                statusCode: 500,
                headers: {
                    'Content-Type': 'text/html; charset=utf-8'
                },
                body: JSON.stringify(e),
                "isBase64Encoded": false
            }
            callback(null, httpResponse);
        }      


    } catch (err) {
      callback("error parsing input body. err="+err)
    }
};
