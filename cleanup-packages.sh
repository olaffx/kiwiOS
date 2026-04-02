#!/bin/bash
set -e

PACKAGES_FILE="packages/packages.x86_64"
BACKUP_FILE="packages/packages.x86_64.backup"

if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo -e "[\e[91m%\e[0m] Error: $PACKAGES_FILE not found!"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e "[\e[93m%\e[0m] Warning: Running without root. Database checks may be stale."
    echo ""
fi

echo -e "[\e[92m%\e[0m] Creating backup: $BACKUP_FILE"
cp "$PACKAGES_FILE" "$BACKUP_FILE"

temp_file=$(mktemp)
valid_count=0
invalid_count=0
comment_count=0

while IFS= read -r line; do
    if [[ -z "$line" ]]; then
        echo "" >> "$temp_file"
        continue
    fi
    
    if [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line" >> "$temp_file"
        ((comment_count++))
        continue
    fi
    
    package=$(echo "$line" | xargs)
    
    if pacman -Si "$package" &> /dev/null; then
        echo "$line" >> "$temp_file"
        echo -e "[\e[92m✓\e[0m] $package"
        ((valid_count++))
    else
        echo "# INVALID: $line" >> "$temp_file"
        echo -e "[\e[91m✗\e[0m] $package (Commented out)"
        ((invalid_count++))
    fi
done < "$PACKAGES_FILE"

echo ""
echo -e "[\e[92m%\e[0m] Summary:"
echo -e "  Valid: $valid_count | Invalid: $invalid_count | Meta: $comment_count"
echo ""

if [ $invalid_count -gt 0 ]; then
    read -p "Update $PACKAGES_FILE? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        mv "$temp_file" "$PACKAGES_FILE"
    else
        rm "$temp_file"
    fi
else
    rm "$temp_file"
fi
