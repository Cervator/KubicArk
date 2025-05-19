# PowerShell script to validate Jenkinsfile syntax

Write-Host "Validating Jenkinsfile syntax using Jenkins REST API..." -ForegroundColor Cyan

# Read the Jenkinsfile content
$jenkinsfileContent = Get-Content -Path "start.Jenkinsfile" -Raw

# Create the form data using multipart/form-data
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"jenkinsfile`"$LF",
    $jenkinsfileContent,
    "--$boundary--$LF"
) -join $LF

# Set headers
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

# Make the API request
try {
    $response = Invoke-WebRequest -Uri "https://jenkins.terasology.io/pipeline-model-converter/validate" -Method Post -Body $bodyLines -Headers $headers
    
    if ($response.Content -match "Jenkinsfile successfully validated") {
        Write-Host "`nValidation successful!" -ForegroundColor Green
        Write-Host $response.Content
    } else {
        Write-Host "`nValidation failed!" -ForegroundColor Red
        Write-Host $response.Content
    }
} catch {
    Write-Host "`nError occurred during validation:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        Write-Host "Response Status Code:" $_.Exception.Response.StatusCode.value__
        Write-Host "Response Status Description:" $_.Exception.Response.StatusDescription
    }
} 