# IP related

## function version of gips
function fgips() {
    cat "$1" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
}

## function version of orderips
function forderips() {
    cat "$1" | sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
}

########################################################################################################################

# AI Related

function create_report() {
    # Check if there are at least two arguments
    if [ $# -lt 2 ]; then
        echo "Usage: create_report <title> <description> [file_path]"
        return 1
    fi

    # Assign function arguments to variables
    title=$1
    description=$2
    file_path=$3

    # Begin the report content
    {
        echo "Title: $title"
        echo "Description: $description"
        echo ""

        # Check if an optional file path is provided and if it exists
        if [ -n "$file_path" ]; then
            if [ -f "$file_path" ]; then
                echo "Contents of the file:"
                cat "$file_path"  # Append the file content to the report
            else
                echo "Warning: File not found: $file_path"  # Warn if the file doesn't exist
            fi
        fi
    } | fabric -s -p create_report_finding -o ~/Documents/library/Job/current-wip-vuln.md
}

########################################################################################################################

# Decoders

function jwt-decode-info() {
    local token header payload iat exp date_time_issued date_time_exp time_difference expiry_date creation_date

    # Read token from clipboard and decode it
    if ! payload=$(jwt-decode 2>/dev/null); then
        printf "Error: Unable to decode JWT token.\n" >&2
        return 1
    fi

    # Output decoded payload
    printf "Decoded Payload: %s\n" "$payload"

    # Extract issued at (iat) and expiry (exp) times
    iat=$(printf '%s' "$payload" | jq '.iat')
    exp=$(printf '%s' "$payload" | jq '.exp')

    if [[ -z $iat || -z $exp ]]; then
        printf "Error: iat or exp not found in JWT payload.\n" >&2
        return 1
    fi

    # Convert iat (JWT creation time) to human-readable date and time
    creation_date=$(date -d @"$iat" '+%Y-%m-%d %H:%M:%S %Z')

    # Convert epoch to human-readable dates
    date_time_issued=$(date -d @"$iat" '+%Y-%m-%d %H:%M:%S %Z')
    date_time_exp=$(date -d @"$exp" '+%Y-%m-%d %H:%M:%S %Z')

    # Calculate time difference between expiration and creation (issued at)
    time_difference=$((exp - iat))
    local hours=$((time_difference / 3600))
    local minutes=$(( (time_difference % 3600) / 60 ))

    # Convert expiry date to local time and append GMT/BST
    expiry_date=$(date -d @"$exp" '+%Y-%m-%d %H:%M:%S %Z')

    # Output the results
    printf "JWT Creation Date: %s\n" "$creation_date"
    printf "Time difference: %02d hours, %02d minutes\n" "$hours" "$minutes"
    printf "Expiry date: %s\n" "$expiry_date"
}

# Function to decode JWT from clipboard using jq
function jwt-decode() {
    local jwt
    jwt=$(pbpaste)
    if [[ -z "$jwt" ]]; then
        printf "Error: No JWT found in clipboard\n" >&2
        return 1
    fi

    # Split JWT and decode payload
    printf "%s\n" "$jwt" | jq -R 'split(".") | .[1] | @base64d | fromjson'
}

########################################################################################################################

# Certificate

function gen-cert() {
    # Default settings
    local encryption="rsa:4096"
    local days=365
    local folder_path=""

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -path) folder_path="$2"; shift ;;
            -days) days="$2"; shift ;;
            *) echo "Unknown parameter passed: $1"; return 1 ;;
        esac
        shift
    done

    # Validate required parameters
    if [ -z "$folder_path" ]; then
        echo "Error: You must provide a folder path using the -path option."
        return 1
    fi

    # Ensure directory exists
    mkdir -p "$folder_path"

    # Paths for key and cert files
    local priv_path="$folder_path/key.pem"
    local pub_path="$folder_path/cert.pem"

    # Generate the key and certificate using openssl
    openssl req -x509 -nodes -days "$days" -newkey "$encryption" -keyout "$priv_path" -out "$pub_path" -subj "/CN=localhost"

    # Provide feedback on success
    if [ $? -eq 0 ]; then
        echo "Certificate and key successfully generated:"
        echo "Private key: $priv_path"
        echo "Certificate: $pub_path"
    else
        echo "Error generating certificate and key."
        return 1
    fi
}

########################################################################################################################

# String manipulation

function string-replace() {
    local search replace input result

    # Parse options for search (-s) and replace (-r)
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s)
                search="$2"
                shift 2
                ;;
            -r)
                # Set replacements for special strings
                case "$2" in
                    "new-line") replace=$'\n' ;;
                    "tab")      replace=$'\t' ;;
                    "space")    replace=" " ;;
                    *)          replace="$2" ;;
                esac
                shift 2
                ;;
            *)
                printf "Usage: string-replace -s <search> -r <replace>\n" >&2
                return 1
                ;;
        esac
    done

    # Ensure both search and replace are provided
    if [[ -z $search || -z $replace ]]; then
        printf "Error: Both -s <search> and -r <replace> are required.\n" >&2
        return 1
    fi

    # Read input, perform replacement, and output result
    if ! input=$(cat); then
        printf "Error: Failed to read input.\n" >&2
        return 1
    fi
    result="${input//"$search"/$replace}"
    printf "%s" "$result"
}

########################################################################################################################

# Code related

## Create a new virtual environment in the current directory, defaulting to .venv
function mkvenv() {
    local name="${1:-.venv}"
    python3 -m venv "$name" && source "$name/bin/activate"
}

########################################################################################################################

# File related

## Compress a directory into a password-protected .zip file with password confirmation
function compress_dir() {
    local dir="$1"
    if [[ -z $dir || ! -d $dir ]]; then
        printf "Usage: compress_dir <directory>\n" >&2
        return 1
    fi

    # Prompt for password
    local password
    local password_confirm
    printf "Enter password: "
    read -s password
    printf "\nConfirm password: "
    read -s password_confirm
    printf "\n"

    # Check if passwords match
    if [[ "$password" != "$password_confirm" ]]; then
        printf "Error: Passwords do not match.\n" >&2
        return 1
    fi

    # Compress directory with password
    zip -r -P "$password" "${dir}.zip" "$dir" >/dev/null
    if [[ $? -eq 0 ]]; then
        printf "Directory '%s' compressed to '%s.zip' successfully.\n" "$dir" "$dir"
    else
        printf "Error: Failed to compress directory '%s'.\n" "$dir" >&2
        return 1
    fi
}

## Find a file by name, case insensitive, starting from current directory
function findfile() {
    local name="$1"
    if [[ -z $name ]]; then
        printf "Usage: findfile <file_name>\n" >&2
        return 1
    fi
    find . -iname "*$name*"
}

## Extract common archive formats
function extract() {
    local file="$1"
    if [[ -z $file || ! -f $file ]]; then
        printf "Usage: extract <file>\n" >&2
        return 1
    fi
    case "$file" in
        *.tar.gz|*.tgz) tar -xzvf "$file" ;;
        *.tar.bz2|*.tbz) tar -xjvf "$file" ;;
        *.zip) unzip "$file" ;;
        *.rar) unrar x "$file" ;;
        *) printf "Unsupported file type\n" >&2 ;;
    esac
}

## Count occurrences of a string in a file
function count_string() {
    local string="$1"
    local file="$2"
    if [[ -z $string || -z $file || ! -f $file ]]; then
        printf "Usage: count_string <string> <file>\n" >&2
        return 1
    fi
    grep -o "$string" "$file" | wc -l
}

## Replace a string in a file
function replace_string() {
    local search="$1"
    local replace="$2"
    local file="$3"
    if [[ -z $search || -z $replace || -z $file || ! -f $file ]]; then
        printf "Usage: replace_string <search> <replace> <file>\n" >&2
        return 1
    fi
    sed -i "s/$search/$replace/g" "$file"
}

## Convert spaces to underscores in filenames within a directory
function convert_spaces_to_underscores() {
    local dir="${1:-.}"
    find "$dir" -type f -name "* *" | while IFS= read -r file; do
        mv "$file" "${file// /_}"
    done
}

## Extract all URLs from a text file
function extract_urls() {
    local file="$1"
    if [[ -z $file || ! -f $file ]]; then
        printf "Usage: extract_urls <file>\n" >&2
        return 1
    fi
    grep -Eo '(http|https)://[^ ]+' "$file" | sort -u
}

########################################################################################################################

# HELPER

## Display a formatted list of aliases and functions from ~/.bash_aliases and ~/.bash_functions
function shell_help() {
    local alias_file="$HOME/.bash_aliases"
    local func_file="$HOME/.bash_functions"
    
    printf "\n\033[1m--- Aliases ---\033[0m\n"
    if [[ -f $alias_file ]]; then
        # Extract alias name and value, retaining quotes and formatting consistently
        grep -E '^alias ' "$alias_file" | sed -E "s/^alias ([^=]+)=(.*)$/\1 -> \2/" | while IFS= read -r line; do
            # Print alias name and its command, ensuring consistent alignment
            printf "%-20s %s\n" "${line%% ->*}" "${line#*-> }"
        done
    else
        printf "No aliases found in %s\n" "$alias_file"
    fi

    printf "\n\033[1m--- Functions ---\033[0m\n"
    if [[ -f $func_file ]]; then
        grep -E '^function ' "$func_file" | awk '{print $2}' | while IFS= read -r func; do
            printf "%s\n" "$func"
        done
    else
        printf "No functions found in %s\n" "$func_file"
    fi
    printf "\n"
}

########################################################################################################################
