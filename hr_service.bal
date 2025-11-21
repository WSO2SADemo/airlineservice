import ballerina/http;
import ballerina/log;

// Helper function to get employee by ID
function getEmployeeById(string employeeId) returns Employee|error {
    if employeeId == "E001" {
        return {
            employeeId: "E001",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice.johnson@company.com",
            department: "Engineering",
            position: "Senior Developer",
            joinDate: "2020-01-15",
            salary: 85000.00,
            status: "ACTIVE"
        };
    } else if employeeId == "E002" {
        return {
            employeeId: "E002",
            firstName: "Bob",
            lastName: "Williams",
            email: "bob.williams@company.com",
            department: "HR",
            position: "HR Manager",
            joinDate: "2019-03-20",
            salary: 75000.00,
            status: "ACTIVE"
        };
    } else if employeeId == "E003" {
        return {
            employeeId: "E003",
            firstName: "Carol",
            lastName: "Davis",
            email: "carol.davis@company.com",
            department: "Finance",
            position: "Accountant",
            joinDate: "2021-06-10",
            salary: 65000.00,
            status: "ACTIVE"
        };
    }
    
    return error("Employee not found");
}

// HR Service on the same listener as airline service
service /hr on apiListener {

    // Get all employees
    resource function get employees() returns Employee[] {
        Employee[] employees = [
            {
                employeeId: "E001",
                firstName: "Alice",
                lastName: "Johnson",
                email: "alice.johnson@company.com",
                department: "Engineering",
                position: "Senior Developer",
                joinDate: "2020-01-15",
                salary: 85000.00,
                status: "ACTIVE"
            },
            {
                employeeId: "E002",
                firstName: "Bob",
                lastName: "Williams",
                email: "bob.williams@company.com",
                department: "HR",
                position: "HR Manager",
                joinDate: "2019-03-20",
                salary: 75000.00,
                status: "ACTIVE"
            },
            {
                employeeId: "E003",
                firstName: "Carol",
                lastName: "Davis",
                email: "carol.davis@company.com",
                department: "Finance",
                position: "Accountant",
                joinDate: "2021-06-10",
                salary: 65000.00,
                status: "ACTIVE"
            }
        ];
        
        return employees;
    }

    // Get employee by ID
    resource function get employees/[string employeeId]() returns Employee|http:NotFound {
        Employee|error employee = getEmployeeById(employeeId);
        
        if employee is error {
            return <http:NotFound>{body: "Employee not found"};
        }
        
        return employee;
    }

    // Get employees by department
    resource function get employees/department/[string department]() returns Employee[] {
        Employee[] allEmployees = [
            {
                employeeId: "E001",
                firstName: "Alice",
                lastName: "Johnson",
                email: "alice.johnson@company.com",
                department: "Engineering",
                position: "Senior Developer",
                joinDate: "2020-01-15",
                salary: 85000.00,
                status: "ACTIVE"
            },
            {
                employeeId: "E002",
                firstName: "Bob",
                lastName: "Williams",
                email: "bob.williams@company.com",
                department: "HR",
                position: "HR Manager",
                joinDate: "2019-03-20",
                salary: 75000.00,
                status: "ACTIVE"
            },
            {
                employeeId: "E003",
                firstName: "Carol",
                lastName: "Davis",
                email: "carol.davis@company.com",
                department: "Finance",
                position: "Accountant",
                joinDate: "2021-06-10",
                salary: 65000.00,
                status: "ACTIVE"
            }
        ];
        
        Employee[] filteredEmployees = [];
        foreach Employee emp in allEmployees {
            if emp.department == department {
                filteredEmployees.push(emp);
            }
        }
        
        return filteredEmployees;
    }

    // Submit leave request
    resource function post leave/request(@http:Payload LeaveRequestInput leaveInput) returns HrApiResponse|http:BadRequest {
        // Validate employee exists
        Employee|error employee = getEmployeeById(leaveInput.employeeId);
        
        if employee is error {
            return <http:BadRequest>{body: {success: false, message: "Invalid employee ID"}};
        }
        
        // Create leave request
        LeaveRequest leaveRequest = {
            leaveId: "LV" + leaveInput.employeeId + "001",
            employeeId: leaveInput.employeeId,
            leaveType: leaveInput.leaveType,
            startDate: leaveInput.startDate,
            endDate: leaveInput.endDate,
            reason: leaveInput.reason,
            status: "PENDING"
        };
        
        log:printInfo("Leave request submitted", leaveId = leaveRequest.leaveId);
        
        HrApiResponse response = {
            success: true,
            message: "Leave request submitted successfully",
            data: leaveRequest.toJson()
        };
        
        return response;
    }

    // Get leave requests by employee
    resource function get leave/requests/[string employeeId]() returns LeaveRequest[]|http:NotFound {
        if employeeId == "E001" {
            LeaveRequest[] leaves = [
                {
                    leaveId: "LVE001001",
                    employeeId: "E001",
                    leaveType: "ANNUAL",
                    startDate: "2024-04-01",
                    endDate: "2024-04-05",
                    reason: "Family vacation",
                    status: "APPROVED"
                },
                {
                    leaveId: "LVE001002",
                    employeeId: "E001",
                    leaveType: "SICK",
                    startDate: "2024-03-15",
                    endDate: "2024-03-16",
                    reason: "Medical appointment",
                    status: "PENDING"
                }
            ];
            return leaves;
        }
        
        return <http:NotFound>{body: "No leave requests found"};
    }

    // Get payroll for employee
    resource function get payroll/[string employeeId]() returns PayrollRecord|http:NotFound {
        if employeeId == "E001" {
            return {
                payrollId: "PR001202403",
                employeeId: "E001",
                month: "2024-03",
                basicSalary: 85000.00,
                allowances: 5000.00,
                deductions: 8500.00,
                netSalary: 81500.00,
                paymentStatus: "PAID"
            };
        } else if employeeId == "E002" {
            return {
                payrollId: "PR002202403",
                employeeId: "E002",
                month: "2024-03",
                basicSalary: 75000.00,
                allowances: 4000.00,
                deductions: 7500.00,
                netSalary: 71500.00,
                paymentStatus: "PAID"
            };
        } else if employeeId == "E003" {
            return {
                payrollId: "PR003202403",
                employeeId: "E003",
                month: "2024-03",
                basicSalary: 65000.00,
                allowances: 3000.00,
                deductions: 6500.00,
                netSalary: 61500.00,
                paymentStatus: "PENDING"
            };
        }
        
        return <http:NotFound>{body: "Payroll record not found"};
    }

    // Get attendance records for employee
    resource function get attendance/[string employeeId]() returns AttendanceRecord[] {
        AttendanceRecord[] records = [
            {
                attendanceId: "ATT" + employeeId + "001",
                employeeId: employeeId,
                date: "2024-03-10",
                checkIn: "09:00:00",
                checkOut: "18:00:00",
                status: "PRESENT"
            },
            {
                attendanceId: "ATT" + employeeId + "002",
                employeeId: employeeId,
                date: "2024-03-11",
                checkIn: "09:15:00",
                checkOut: "18:30:00",
                status: "PRESENT"
            },
            {
                attendanceId: "ATT" + employeeId + "003",
                employeeId: employeeId,
                date: "2024-03-12",
                checkIn: "09:00:00",
                checkOut: "17:45:00",
                status: "PRESENT"
            }
        ];
        
        return records;
    }

    // Mark attendance
    resource function post attendance(@http:Payload AttendanceRecord attendanceRecord) returns HrApiResponse {
        log:printInfo("Attendance marked", 
            employeeId = attendanceRecord.employeeId, 
            date = attendanceRecord.date,
            status = attendanceRecord.status);
        
        HrApiResponse response = {
            success: true,
            message: "Attendance marked successfully",
            data: attendanceRecord.toJson()
        };
        
        return response;
    }

    // Get department statistics
    resource function get departments/stats() returns json {
        json stats = {
            "Engineering": {
                "totalEmployees": 15,
                "activeEmployees": 14,
                "avgSalary": 82000.00
            },
            "HR": {
                "totalEmployees": 5,
                "activeEmployees": 5,
                "avgSalary": 68000.00
            },
            "Finance": {
                "totalEmployees": 8,
                "activeEmployees": 7,
                "avgSalary": 71000.00
            },
            "Sales": {
                "totalEmployees": 12,
                "activeEmployees": 11,
                "avgSalary": 65000.00
            }
        };
        
        return stats;
    }

    // Health check for HR service
    resource function get health() returns json {
        return {status: "UP", serviceName: "HR Service"};
    }
}
