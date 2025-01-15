#!/bin/bash

count=$1
templates_dir="assets/world-templates"
map_pool_dir="${templates_dir}/map-pool"

write_output() {
  GITHUB_OUTPUT="COMMIT_MSG<<EOF\n$1\nEOF"
  export GITHUB_OUTPUT
}

# Find all template files excluding lobby.zip
templates_files=($(find "${templates_dir}" -maxdepth 1 -type f | grep -v "lobby.zip"))

if [ ! -d "$map_pool_dir" ]; then
  mkdir -p "$map_pool_dir"
  populate_pool=($(shuf -e "${templates_files[@]}" -n $((count < ${#templates_files[@]} / 2 ? count : ${#templates_files[@]} / 2))))
  for template in "${populate_pool[@]}"; do
    mv "$template" "$map_pool_dir"
  done
  
  templates_left=($(find "${templates_dir}" -maxdepth 1 -type f | grep -v "lobby.zip"))
  templates_str=$(IFS=", "; echo "${templates_left[*]}")
  write_output "Initialized map pool with ${templates_str}"
  exit 0
fi

map_pool_files=($(find "$map_pool_dir" -maxdepth 1 -type f))

activate_count=$((count < ${#map_pool_files[@]} ? count : ${#map_pool_files[@]}))
deactivate_count=$((count < ${#templates_files[@]} ? count : ${#templates_files[@]}))

to_activate=($(shuf -e "${map_pool_files[@]}" -n "$activate_count"))
to_deactivate=($(shuf -e "${templates_files[@]}" -n "$deactivate_count"))

for active in "${to_activate[@]}"; do
  mv "$active" "$templates_dir"
done
for inactive in "${to_deactivate[@]}"; do
  mv "$inactive" "$map_pool_dir"
done

removed=$(printf "\n* %s" "${to_deactivate[@]}")
added=$(printf "\n* %s" "${to_activate[@]}")
commit_message="Swap maps\n\n*Added*:${added}\n\n*Removed*:${removed}"
write_output "$commit_message"
