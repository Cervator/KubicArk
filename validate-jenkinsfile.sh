#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Validating Jenkinsfile syntax using Jenkins REST API...${NC}"

# Generate a boundary for multipart/form-data
BOUNDARY=$(uuidgen)
LF="\n"

# Read the Jenkinsfile content
JENKINSFILE_CONTENT=$(cat start.Jenkinsfile)

# Create the multipart/form-data body
BODY="--${BOUNDARY}${LF}"
BODY+="Content-Disposition: form-data; name=\"jenkinsfile\"${LF}${LF}"
BODY+="${JENKINSFILE_CONTENT}${LF}"
BODY+="--${BOUNDARY}--${LF}"

# Make the API request
response=$(curl -s -X POST \
    -H "Content-Type: multipart/form-data; boundary=${BOUNDARY}" \
    --data-binary "${BODY}" \
    https://jenkins.terasology.io/pipeline-model-converter/validate)

if [[ $response == *"Jenkinsfile successfully validated"* ]]; then
    echo -e "\n${GREEN}Validation successful!${NC}"
    echo "$response"
else
    echo -e "\n${RED}Validation failed!${NC}"
    echo "$response"
fi 