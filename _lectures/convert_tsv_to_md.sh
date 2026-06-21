#!/bin/bash

# Initialize counters for each type
lecture_count=1
exam_count=1
review_count=1
noclass_count=1

# Function to convert date to the required format
convert_date() {
  input_date="$1"
  formatted_date=$(date -j -f "%m/%d/%Y" "$input_date" +"%Y-%m-%dT14:00:00-05:00")
  echo "$formatted_date"
}

# Read the TSV file and handle the last line
{
  while IFS=$'\t' read -r date topic note || [ -n "$date" ]; do

    # Determine the type based on the topic
    if [[ $topic == Lecture* ]]; then
      type="lecture"
      filename="${type}_$(printf "%02d" $lecture_count).md"
      ((lecture_count++))
    elif [[ $topic == *[eE]xam* ]]; then
      type="exam"
      filename="${type}_$(printf "%02d" $exam_count).md"
      ((exam_count++))
    elif [[ $topic == *[rR]eview* ]]; then
      type="review"
      filename="${type}_$(printf "%02d" $review_count).md"
      ((review_count++))
    elif [[ $topic == *"No Class"* ]]; then
      type="noclass"
      filename="${type}_$(printf "%02d" $noclass_count).md"
      ((noclass_count++))
    else
      echo "Skipping unknown type for topic: $topic"
      continue
    fi

    # Convert date to YAML format with time appended
    formatted_date=$(convert_date "$date")

    # Clean the note field by removing carriage returns
    clean_note=$(echo "$note" | tr -d '\r')

    # Create the markdown file with the specified format
    echo "---" > "$filename"
    echo "type: \"$type\"" >> "$filename"
    echo "date: \"$formatted_date\"" >> "$filename"
    echo "topic: '$topic'" >> "$filename"
    echo "---" >> "$filename"

    # Add the note field if it exists
    if [[ -n "$clean_note" ]]; then
      echo "$clean_note" >> "$filename"
    fi

  done
} < input.tsv
