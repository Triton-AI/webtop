# Set up steps
apt update
mkdir -p ~/projects/lib && cd ~/projects/lib

# Activate virtual environment
python3 -m virtualenv --system-site-packages ~/donkey
. ~/donkey/bin/activate

# Install donkeycar
git clone https://github.com/Triton-AI/donkeycar.git -b gk

cd donkeycar && pip3 install -e .[gk] && cd ..

# Depthai library
curl -fL https://docs.luxonis.com/install_dependencies.sh | bash
git clone https://github.com/luxonis/depthai.git && cd depthai && python3 install_requirements.py && cd ..
git clone https://github.com/luxonis/depthai-python.git && cd depthai-python/examples && python3 install_requirements.py && cd ../..
echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc
echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules

# Deactivate donkeycar environment
deactivate

# Delete apt cache
apt clean && rm -rf /var/lib/apt/lists/*