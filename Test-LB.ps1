<#
.SYNOPSIS
    Azure Load Balancer Traffic Distribution Test Script
.DESCRIPTION
    This script tests traffic distribution across multiple backend VMs
    for a Public or Internal Azure Load Balancer with session persistence = None.
.NOTES
    Author: Khushboo Sharma
    Date: 2026-01-01
#>

# Replace this with your actual Load Balancer IP
$LBIP = "172.174.36.89"

# Number of test requests
$RequestCount = 20

Write-Host "Testing Azure Load Balancer traffic distribution..." -ForegroundColor Cyan
Write-Host "Load Balancer IP: $LBIP" -ForegroundColor Yellow
Write-Host "Number of requests: $RequestCount`n" -ForegroundColor Yellow

# Loop to send requests
for ($i = 1; $i -le $RequestCount; $i++) {

    try {
        # Send request and force new TCP connection
        $response = Invoke-WebRequest `
            -Uri "http://$LBIP" `
            -DisableKeepAlive `
            -UseBasicParsing `
            -ErrorAction Stop

        # Display the response from backend VM
        Write-Host "Request $i: $($response.Content)" -ForegroundColor Green
    }
    catch {
        Write-Host "Request $i: Failed to reach LB" -ForegroundColor Red
    }

    # Optional: small pause to visualize traffic
    Start-Sleep -Milliseconds 200
}

Write-Host "`nTest completed. Verify that responses alternate between backend VMs." -ForegroundColor Cyan
