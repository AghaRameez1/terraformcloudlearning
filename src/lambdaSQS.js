const AWS = require('aws-sdk');

exports.handler = async (event) => {
    console.log(event)
    const sns = new AWS.SNS({
        region: 'eu-west-1',
        endpoint: 'https://sns.eu-west-1.amazonaws.com' // Replace <YOUR_AWS_REGION> with your AWS region
    });
    const topicArn = process.env.SNS_TOPIC_ARN; // Replace with your SNS topic ARN
    // let user = JSON.parse(event.Records[0].body)
    const message = event.Records[0].body
    const params = {
        Message: `Entry Changed to ${message}`,
        TopicArn: topicArn,
    };

    try {
        await sns.publish(params).promise();
        console.log('SNS message sent successfully');
        return {
            statusCode: 200,
            body: 'SNS message sent successfully',
        };
    } catch (error) {
        console.error('Error sending SNS message:', error);
        return {
            statusCode: 500,
            body: 'Error sending SNS message',
        };
    }
};
