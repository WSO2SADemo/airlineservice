import ballerina/http;

// HTTP clients for backend services
final http:Client customerServiceClient = check new (customerServiceUrl);
final http:Client flightServiceClient = check new (flightServiceUrl);
final http:Client paymentServiceClient = check new (paymentServiceUrl);
final http:Client notificationServiceClient = check new (notificationServiceUrl);
