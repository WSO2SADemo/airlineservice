import ballerina/http;
import ballerina/log;

// Unified API Service
listener http:Listener apiListener = new (airlineServicePort);

service /airline on apiListener {

    // Todo resources
    resource function get test() returns json {
        json todos = [
            {
                "id": 1,
                "name": "Test Service Response",
                "status": "OPEN"
            }
        ];
        return todos;
    }

    // Get customer profile with loyalty information
    resource function get customers/[string customerId]() returns Customer|http:NotFound|http:InternalServerError {
        Customer|error customer = getCustomerInfo(customerId);
        
        if customer is error {
            log:printError("Error retrieving customer", 'error = customer);
            return <http:InternalServerError>{body: "Failed to retrieve customer information"};
        }
        
        return customer;
    }

    // Search flights between origin and destination
    resource function get flights(string origin, string destination) returns Flight[]|http:InternalServerError {
        Flight[]|error flights = searchFlights(origin, destination);
        
        if flights is error {
            log:printError("Error searching flights", 'error = flights);
            return <http:InternalServerError>{body: "Failed to search flights"};
        }
        
        return flights;
    }

    // Complete booking workflow: validate customer, check flight, create booking, process payment, send notification
    resource function post bookings(@http:Payload BookingRequest bookingRequest) returns ApiResponse|http:BadRequest|http:InternalServerError {
        
        // Step 1: Validate customer
        Customer|error customer = getCustomerInfo(bookingRequest.customerId);
        if customer is error {
            log:printError("Customer validation failed", 'error = customer);
            return <http:BadRequest>{body: {success: false, message: "Invalid customer ID"}};
        }
        
        // Step 2: Get flight details
        Flight|error flight = getFlightDetails(bookingRequest.flightNumber);
        if flight is error {
            log:printError("Flight not found", 'error = flight);
            return <http:BadRequest>{body: {success: false, message: "Invalid flight number"}};
        }
        
        // Step 3: Check seat availability
        if flight.availableSeats <= 0 {
            return <http:BadRequest>{body: {success: false, message: "No seats available"}};
        }
        
        // Step 4: Apply loyalty discount
        decimal finalPrice = applyLoyaltyDiscount(flight.price, customer.loyaltyTier);
        
        // Step 5: Create booking
        Booking|error booking = createBooking(bookingRequest);
        if booking is error {
            log:printError("Booking creation failed", 'error = booking);
            return <http:InternalServerError>{body: {success: false, message: "Failed to create booking"}};
        }
        
        // Step 6: Process payment
        PaymentRequest paymentRequest = {
            bookingId: booking.bookingId,
            customerId: bookingRequest.customerId,
            amount: finalPrice,
            paymentMethod: "CREDIT_CARD"
        };
        
        PaymentResponse|error paymentResponse = processPayment(paymentRequest);
        if paymentResponse is error {
            log:printError("Payment processing failed", 'error = paymentResponse);
            return <http:InternalServerError>{body: {success: false, message: "Payment processing failed"}};
        }
        
        if paymentResponse.status != "SUCCESS" {
            return <http:BadRequest>{body: {success: false, message: "Payment declined"}};
        }
        
        // Step 7: Send confirmation notification
        NotificationRequest notificationRequest = {
            customerId: customer.customerId,
            email: customer.email,
            subject: "Booking Confirmation",
            message: string `Your booking ${booking.bookingId} for flight ${flight.flightNumber} is confirmed!`
        };
        
        error? notificationResult = sendNotification(notificationRequest);
        if notificationResult is error {
            log:printWarn("Notification sending failed but booking is successful", 'error = notificationResult);
        }
        
        // Return success response
        ApiResponse response = {
            success: true,
            message: "Booking completed successfully",
            data: booking.toJson()
        };
        
        return response;
    }

    // Health check endpoint
    resource function get health() returns json {
        return {status: "UP", serviceName: "Unified API Service"};
    }
}

// Mock backend services for demonstration purposes
listener http:Listener mockServicesListener = new (9091);

// Mock Customer Service
service /customers on mockServicesListener {
    
    resource function get [string customerId]() returns Customer|http:NotFound {
        // Mock customer data
        if customerId == "C001" {
            return {
                customerId: "C001",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@email.com",
                phoneNumber: "+1234567890",
                loyaltyTier: "GOLD"
            };
        } else if customerId == "C002" {
            return {
                customerId: "C002",
                firstName: "Jane",
                lastName: "Smith",
                email: "jane.smith@email.com",
                phoneNumber: "+1234567891",
                loyaltyTier: "SILVER"
            };
        }
        
        return <http:NotFound>{body: "Customer not found"};
    }
}

// Mock Flight Service
service /flights on mockServicesListener {
    
    resource function get .(string origin, string destination) returns Flight[] {
        // Mock flight data
        Flight[] flights = [
            {
                flightNumber: "AA101",
                origin: origin,
                destination: destination,
                departureTime: "2024-03-15T10:00:00Z",
                arrivalTime: "2024-03-15T14:00:00Z",
                price: 350.00,
                availableSeats: 45
            },
            {
                flightNumber: "AA102",
                origin: origin,
                destination: destination,
                departureTime: "2024-03-15T16:00:00Z",
                arrivalTime: "2024-03-15T20:00:00Z",
                price: 420.00,
                availableSeats: 30
            }
        ];
        
        return flights;
    }
    
    resource function get [string flightNumber]() returns Flight|http:NotFound {
        // Mock flight details
        if flightNumber == "AA101" {
            return {
                flightNumber: "AA101",
                origin: "JFK",
                destination: "LAX",
                departureTime: "2024-03-15T10:00:00Z",
                arrivalTime: "2024-03-15T14:00:00Z",
                price: 350.00,
                availableSeats: 45
            };
        }
        
        return <http:NotFound>{body: "Flight not found"};
    }
    
    resource function post bookings(@http:Payload BookingRequest bookingRequest) returns Booking {
        // Mock booking creation
        Booking booking = {
            bookingId: "BK" + bookingRequest.customerId + "001",
            customerId: bookingRequest.customerId,
            flightNumber: bookingRequest.flightNumber,
            seatNumber: "12A",
            status: "CONFIRMED",
            totalAmount: 350.00,
            bookingDate: "2024-03-10T09:00:00Z"
        };
        
        log:printInfo("Booking created", bookingId = booking.bookingId);
        return booking;
    }
}

// Mock Payment Service
service /payments on mockServicesListener {
    
    resource function post .(@http:Payload PaymentRequest paymentRequest) returns PaymentResponse {
        // Mock payment processing
        PaymentResponse response = {
            transactionId: "TXN" + paymentRequest.bookingId,
            status: "SUCCESS",
            message: "Payment processed successfully"
        };
        
        log:printInfo("Payment processed", transactionId = response.transactionId);
        return response;
    }
}

// Mock Notification Service
service /notifications on mockServicesListener {
    
    resource function post .(@http:Payload NotificationRequest notificationRequest) returns http:Ok {
        // Mock notification sending
        log:printInfo("Notification sent", 
            customerId = notificationRequest.customerId, 
            email = notificationRequest.email,
            subject = notificationRequest.subject);
        
        return <http:Ok>{body: "Notification sent"};
    }
}
