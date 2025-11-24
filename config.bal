// Configuration for external services
import ballerina/os;

string envMockApiUrl = os:getEnv("MOCK_API_BASE_URL");
string mockApiBaseUrl = envMockApiUrl.length() > 0 ? envMockApiUrl : "https://61038a4279ed680017482530.mockapi.io/sample-service";
configurable string customerServiceUrl = "http://localhost:9091";
configurable string flightServiceUrl = "http://localhost:9091";
configurable string paymentServiceUrl = "http://localhost:9091";
configurable string notificationServiceUrl = "http://localhost:9091";
configurable int airlineServicePort = 8080;
