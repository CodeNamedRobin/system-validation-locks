#!/bin/bash

# Start time
start_time=$(date +%s)

MODEL="controller_model_spec.mcrl2"
LPS="controller_model_spec.lps"
PROPERTIES_DIR="properties"   # Adjust if needed (folder name)
THREADS=12

echo "Step 1: Generating LPS from $MODEL..."
mcrl22lps "$MODEL" "$LPS"
if [ $? -ne 0 ]; then
  echo "Error: mcrl22lps failed."
  exit 1
fi

echo "Step 2 & 3: Processing property files..."
for prop in "$PROPERTIES_DIR"/*.mcf; do
  [ -e "$prop" ] || continue  # Skip if no .mcf files
  
  base_name=$(basename "$prop" .mcf)
  PBES="${base_name}.pbes"
  
  echo "----"
  echo "Processing $prop -> $PBES"
  
  # lps2pbes
  lps2pbes -f "$prop" "$LPS" "$PBES"
  if [ $? -ne 0 ]; then
    echo "Error: lps2pbes failed for $prop"
    continue
  fi
  
  # pbessolve
  echo "Solving $PBES..."
  pbessolve -v "$PBES" --threads="$THREADS" -rjitty
done

# End time
end_time=$(date +%s)
runtime=$((end_time - start_time))

echo "----"
echo "✅ Total time: $runtime seconds"
