#!/bin/bash

# Step 1: Create a Dockerfile that uses the public OpenROAD image and adds Xvfb + CRIU
cat > Dockerfile <<'EOF'
FROM theopenroad/openroad:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install additional tools
RUN apt update && apt install -y \
    xvfb \
    x11-utils \
    libgtk-3-0 \
    criu \
    sudo

EOF

# Step 2: Create run_openroad_gui.sh to launch Xvfb + OpenROAD GUI
#!/bin/bash
export DISPLAY=:99
Xvfb :99 &
sleep 2

# Launch OpenROAD GUI
openroad -gui &

# Keep container alive for CRIU checkpoint
sleep infinity
EOF

# Step 3: Build Docker image
docker build -t openroad-xvfb .

# Step 4: Run the container with CRIU capabilities
docker run -dit \
  --name openroad-test \
  --cap-add=CHECKPOINT_RESTORE \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  openroad-xvfb

# Step 5: Wait for GUI to initialize
sleep 10

# Step 6: Create checkpoint
docker checkpoint create openroad-test checkpoint1

# Step 7: Stop and restore container
docker stop openroad-test
sleep 2
docker start --checkpoint checkpoint1 openroad-test

# Done
