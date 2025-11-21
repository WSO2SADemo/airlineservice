import ballerina/log;

// Retrieve customer information from customer service
function getCustomerInfo(string customerId) returns Customer|error {
    json response = check customerServiceClient->/customers/[customerId].get();
    Customer customer = check response.cloneWithType();
    return customer;
}

// Search for available flights
function searchFlights(string origin, string destination) returns Flight[]|error {
    json response = check flightServiceClient->/flights.get(origin = origin, destination = destination);
    Flight[] flights = check response.cloneWithType();
    return flights;
}

// Get specific flight details
function getFlightDetails(string flightNumber) returns Flight|error {
    json response = check flightServiceClient->/flights/[flightNumber].get();
    Flight flight = check response.cloneWithType();
    return flight;
}

// Create a new booking
function createBooking(BookingRequest bookingRequest) returns Booking|error {
    json response = check flightServiceClient->/bookings.post(bookingRequest);
    Booking booking = check response.cloneWithType();
    return booking;
}

// Process payment
function processPayment(PaymentRequest paymentRequest) returns PaymentResponse|error {
    json response = check paymentServiceClient->/payments.post(paymentRequest);
    PaymentResponse paymentResponse = check response.cloneWithType();
    return paymentResponse;
}

// Send notification to customer
function sendNotification(NotificationRequest notificationRequest) returns error? {
    json|error response = notificationServiceClient->/notifications.post(notificationRequest);
    if response is error {
        log:printError("Failed to send notification", 'error = response);
        return response;
    }
}

// Apply loyalty discount based on customer tier
function applyLoyaltyDiscount(decimal basePrice, string? loyaltyTier) returns decimal {
    if loyaltyTier is () {
        return basePrice;
    }

    decimal discountPercentage = 0.0;
    if loyaltyTier == "GOLD" {
        discountPercentage = 0.15;
    } else if loyaltyTier == "SILVER" {
        discountPercentage = 0.10;
    } else if loyaltyTier == "BRONZE" {
        discountPercentage = 0.05;
    }

    decimal discountAmount = basePrice * discountPercentage;
    decimal finalPrice = basePrice - discountAmount;
    return finalPrice;
}
