# Colors for output
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$CYAN = [System.ConsoleColor]::Cyan

Write-Host "Validating Job DSL syntax using Jenkins REST API..." -ForegroundColor $CYAN

# Generate a boundary for multipart/form-data
$BOUNDARY = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

# Read the Job DSL content
$JOBDSL_CONTENT = Get-Content -Path "jobs.dsl" -Raw

# Create the multipart/form-data body
$BODY = "--${BOUNDARY}${LF}"
$BODY += "Content-Disposition: form-data; name=`"script`"${LF}${LF}"
$BODY += "${JOBDSL_CONTENT}${LF}"
$BODY += "--${BOUNDARY}--${LF}"

# Make the API request
$response = Invoke-WebRequest -Uri "https://jenkins.terasology.io/scriptText" `
    -Method Post `
    -ContentType "multipart/form-data; boundary=${BOUNDARY}" `
    -Body $BODY

if ($response.Content -match "Script1.groovy") {
    Write-Host "`nValidation successful!" -ForegroundColor $GREEN
    Write-Host $response.Content
} else {
    Write-Host "`nValidation failed!" -ForegroundColor $RED
    Write-Host $response.Content
} 