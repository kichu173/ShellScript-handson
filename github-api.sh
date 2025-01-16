#!/bin/bash

API_URL="https://api.github.com"

# env variable
USERNAME=$username
TOKEN=$token

REPO_OWNER=$1

function helper {
    expected_cmd_args=1
    if [[ $# -ne $expected_cmd_args ]]; then
        echo "Please execute the script with the required command arguments ${expected_cmd_args} and they are repo-org."
        exit 1
    fi
}

helper "$@"

function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to calculate contributions for a given repository and time period
function calculate_contributions {
    local repo_owner="$1"
    local repo_name="$2"
    local start_date="$3"
    local end_date="$4"

    local endpoint="repos/${repo_owner}/${repo_name}/commits?since=${start_date}&until=${end_date}"
    local commits=$(github_api_get "$endpoint")

    # echo "Commits JSON response for ${repo_owner}/${repo_name}:"
    # echo "$commits" | jq .

    local total_additions=0
    local total_deletions=0

    for sha in $(echo "$commits" | jq -r '.[].sha'); do
        local commit_endpoint="repos/${repo_owner}/${repo_name}/commits/${sha}"
        local commit=$(github_api_get "$commit_endpoint")

        # echo "Commit JSON response for ${repo_owner}/${repo_name}:"
        # echo "$commit" | jq .

        local additions=$(echo "$commit" | jq -r '.stats.additions')
        local deletions=$(echo "$commit" | jq -r '.stats.deletions')

        total_additions=$((total_additions + additions))
        total_deletions=$((total_deletions + deletions))
    done

    echo "Repository: ${repo_owner}/${repo_name}"
    echo "Total additions: $total_additions"
    echo "Total deletions: $total_deletions"
}

# Main script
REPO_LIST=("dsg-cirium-laminar-catalog-notam-geojson-publisher" "dsg-cirium-laminar-catalog-notam-geojson-denormaliser" "dsg-cirium-laminar-catalog-nmb2b-connector")
START_DATE="2024-01-01T00:00:00Z"
END_DATE="2024-12-31T23:59:59Z"

for repo in "${REPO_LIST[@]}"; do
    calculate_contributions "$REPO_OWNER" "$repo" "$START_DATE" "$END_DATE"
done
