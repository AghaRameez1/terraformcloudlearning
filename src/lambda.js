const AWS = require("aws-sdk");
const sns = new AWS.SNS();
exports.handler = async function (event) {
    console.log(event)
    // if (event.Records[0].eventName == 'INSERT') {
    let user = JSON.stringify(event.Records[0].dynamodb.NewImage.user.S)
    console.log(user)
    try {
        await sns.publish({
            "Message": user,
            "TopicArn": process.env.SNS_TOPIC_ARN
        }).promise();
        console.log('Success')
    } catch (error) {
        console.log(error)

    }
    // }
};